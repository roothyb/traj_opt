% to generate periodic traj with optimal stability
% aircraft should have VR, N and params set
function [aircraft, sol] = optimize_stability(aircraft, x0, p, M, params, type, stab_type)    
    % dec vec = [ax0, ... , ax1_N,ax2_1, ... , ax2_N, ay0, ... , ay2_N, az0, ... ,az2_N, tf]
    % a$1_i corresponds to teh coefficient of the i'th cosine harmonic
    % a$2_i corresponds to teh coefficient of the i'th sine harmonic
    xguess = x0;
    aircraft.p = p; N = aircraft.N;
   
    % if x0 was empty, it means we are running for first time
    if isempty(xguess)
        xguess = get_init_guess('circle', N);
        %xguess = [xguess(1:end-2);xguess(end,1)];
    end
    
    if strcmp(type{2}, 'stability') 
        lb = ones(3*(2*N+1)+1,1); ub = ones(3*(2*N+1)+1,1);
        % bounds on coefficients
        lb(1:3*(2*N+1),1) = -500*lb(1:3*(2*N+1),1);
        ub(1:3*(2*N+1),1) = 500*ub(1:3*(2*N+1),1);
        % bounds on tf
        lb(end,1) = 0; ub(end,1) = 150;
    else
        lb = ones(3*(2*N+1)+2,1); ub = ones(3*(2*N+1)+2,1);
        % bounds on coefficients
        lb(1:3*(2*N+1),1) = -500*lb(1:3*(2*N+1),1);
        ub(1:3*(2*N+1),1) = 500*ub(1:3*(2*N+1),1);
        % bounds on tf
        lb(end-1,1) = 0; ub(end-1,1) = aircraft.VR*1.5;
        lb(end,1) = 0; ub(end,1) = 150;
    end
    
    options = optimoptions('fmincon', 'Display', 'Iter', 'Algorithm', 'sqp', 'UseParallel', true);
    options.MaxFunctionEvaluations = 100000;
    options.StepTolerance = 1e-12;
    options.MaxIterations = 10000;
    sol = fmincon(@(x) objfun(x, aircraft, type{1}, params, stab_type), xguess, [], [], [], [], lb, ub, @(x) constFun_traj(x, aircraft, type{2}, M), options);
    
    n = (2*N+1);
    aircraft.coeffs = [sol(1:n,1), sol(n+1:2*n,1), sol(2*n+1:3*n,1)];
    aircraft.tf = sol(3*n+1,1);
end