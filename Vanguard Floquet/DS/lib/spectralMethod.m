function [FE, eigE, AM, groupSizes] = spectralMethod(trajData)
    % change this parameter according to model
    d = 4;
    % spectral method runs on same number of grid points as trajectory
    D = trajData.D; N = trajData.N; T = trajData.T;
    
    Dmat = zeros(d*N); Mmat = zeros(d*N);
    for i = 1:N
        A = sysModel(trajData.p, trajData.X(i,:), [trajData.U(i,:), trajData.VR]);
        for j = 1:d
           for k = 1:d
                Mmat(i+(j-1)*N,(k-1)*N+i) = A(j,k); 
           end
           Dmat((j-1)*N+1:j*N,(j-1)*N+1:j*N) = D*(2*pi/T);
           enda
    end
    
    eigE = eig(Dmat - Mmat);
    eigE = -1*eigE;
    
    [FE,groupSizes,AM] = identifyFloquet(eigE, N, trajData.T);
end

function A = sysModel(p, Z, U)
    prm.m = 4.5;
    prm.S = 0.473;
    prm.CD0 = 0.0173;
    prm.CD1 = -0.0337;
    prm.CD2 = 0.0517;
    prm.p_exp = p;
    % evaluate jacobian
    A = JacEval(Z, U, prm);
    A = [A(1:3,1:3), A(1:3,6); A(6,1:3), A(6,6)];
end