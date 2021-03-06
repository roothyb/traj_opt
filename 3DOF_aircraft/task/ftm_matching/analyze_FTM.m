function D = analyze_FTM(ac, div_tol, type)
    %% time evolution
    options = odeset('AbsTol', 1e-11, 'RelTol', 1e-11, 'Events', @(t,y) z_event(t,y));
    data = simulate_traj(ac, 2000, options);
    
    %% calculating average values for V and gamma
    t = linspace(0, ac.tf, 1000);
    V_avg = 0;
    for i = 1:length(t)
        sig = get_traj(t(i), ac.tf, ac.coeffs, ac.N);
        ac = ac.get_xu(sig);
        V_avg = V_avg + ac.x(1);
    end
    V_avg = V_avg/length(t);
    
    %% find point of loss of nonlinearity
     t = data.t; y = data.y;
    n_max = floor(t(end)/ac.tf);
    for i = 1:n_max-1
        [~,j] = min(abs(t - i*ac.tf));
        [~,k] = min(abs(t - (i+1)*ac.tf));
        V_div = abs((y(j,1) - y(k,1))/V_avg);
        gam_div = abs(y(j,3) - y(k,3));
        if(V_div >= div_tol(1) || gam_div >= div_tol(2)),  break; end
    end
%     j = 1; [~,k] = min(abs(t-ac.tf));
       
    switch(type)
        case 'expo'
            %% exponentials
            t_expo = linspace(t(k), t(j), 1000);
            y_expo = interp1(t(j:k), y(j:k,:), t_expo);
            FTM = eye(3); del_t = t_expo(1)-t_expo(2);
            for i = 1:length(t_expo)
                Jk = get_A(ac, t_expo(i), y_expo(i,:)'); Jk = Jk(1:3,1:3);
                FTM = FTM*expm(Jk*del_t);
            end
            
        case 'time-march-ode'
        %% adaptive time march
            % state at almost periodic time period
            div_state = y(j:k,:);

            y_0 = eye(6); tspan = t(j:k); y_T = zeros(6,6);
            for i = 1:6
                [~,y] = ode45(@(t,y) model(t, y, ac, div_state, tspan), [tspan(1), tspan(end)], y_0(:,i));
                y_T(:,i) = y(end,:)';
            end
            FTM = y_T(1:3, 1:3);

        case 'time-march-fs'
        %% fixed step time march
            div_state = y(j:k,:);
            
        % fixed step time march (RK4)
            y_0 = eye(6); tspan = t(j:k); y_T = zeros(6,6);
            for i = 1:6
                [~,y] = RK4(@(t,y) model(t, y, ac, div_state, tspan), [tspan(1), tspan(end)], y_0(:,i), 1e-3);
                y_T(:,i) = y(end,:)';
            end
            FTM = y_T(1:3, 1:3);
            
        case 'time-march-ode-aug'
        %% augemented time march
            I = eye(6); tspan = [t(j), t(k)];
            y0 = zeros(7*6,1);
            for kk = 1:6
                kkk = (kk-1)*6 + 1;
                y0(kkk:kkk+5,1) = I(:,kk);
            end
            y0(6*6+1:7*6,1) = y(j,:)';
            [~, y_FTM] = ode45(@(t,y) augmented_model(t, y, ac), tspan, y0);
            FTM = zeros(3,3);
            for kk = 1:3
                kkk = (kk-1)*6 + 1;
                FTM(:,kk) = y_FTM(end, kkk:kkk+2)';
            end
            
        case 'friedmann'
        %% FTM by Friedmann's approach
            orbit_info.t = t(j:k); orbit_info.y = y(j:k,:);
            t_FTM = linspace(t(j), t(k), 1000);
            t_expo = linspace(t(k), t(j), 1000);
            h = t_FTM(2) - t_FTM(1);
            FTM_diff = zeros(1,1000);
            FTM = eye(6); FTM2 = eye(3);
            for i = 1:length(t_FTM)-2
                y_expo = interp1(orbit_info.t, orbit_info.y, t_expo(i));
                Jk = get_A(ac, t_expo(i), y_expo'); Jk = Jk(1:3,1:3);
                FTM2 = FTM2*expm(Jk*h);

                K = friedmann_K(h, (t_FTM(end) - i*h), orbit_info, ac);
                FTM = FTM*K;

                FTM_diff(i) = norm(FTM(1:3,1:3)-FTM2);
            end

            FTM = FTM(1:3, 1:3);
            
        otherwise
            "Wrong type entered!"
    end
    
   %% return Floquet Multipliers
    D = eig(FTM);
    
    %% friedmann method
    function K = friedmann_K(h, t, orbit_info, ac)
        X = interp1(orbit_info.t, orbit_info.y, t);
        A_psi = get_A(ac, t, X');
        A_psi_h_by_2 = get_A(ac, t+0.5*h, interp1(orbit_info.t, orbit_info.y, t+0.5*h)');
        A_psi_h = get_A(ac, t+h, interp1(orbit_info.t, orbit_info.y, t+h)');
        E = A_psi_h_by_2*(eye(6) + 0.5*h*A_psi);
        F = A_psi_h_by_2*(eye(6) + (-0.5 + 2^(-0.5))*h*A_psi + (1 - 2^(-0.5))*h*E);
        G = A_psi_h*(eye(6) - h*(2^(-0.5))*E + (1 + 2^(-0.5))*h*F);       
        K = eye(6) + (h/6)*(A_psi + 2*(1 - 2^(-0.5))*E + 2*(1 + 2^(-0.5))*F + G);
    end
    
%% linearised state model
    function ydot = model(t, y, ac, div_state, tspan)
        state = interp1(tspan, div_state, t);
        X = state';
        A = get_A(ac, t, X);
            ydot = A*y;
    end

%% augmented state model
    function ydot = augmented_model(t, y, ac)
        % actual state
        x = y(6*6+1:6*6+6,1);
        
        % propagating linearised equations
        J = get_A(ac, t, x);
        ydot = zeros(7*6,1);
        for ii = 1:6
            jj = (ii-1)*6 + 1;
            ydot(jj:jj+5,1) = J*y(jj:jj+5,1);
        end
        
        % propagating nonlinear equations
        ydot(6*6+1:7*6,1) = ac.non_flat_model(t, x);
    end
end