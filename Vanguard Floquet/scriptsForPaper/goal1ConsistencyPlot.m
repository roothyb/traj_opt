global fonttype
global fontsize

load('loiterExp_001.mat')
d = 10;

prm.model = '3dof';
prm.p = p;
prm.loiter = true; prm.correctChi = false;
trajData = getTrajData(sol, N, prm);

tFE = timeMarchMethodGen(trajData, @sysModel, d);
tFE = sortrows(tFE, 'descend');
temp = tFE(3); tFE(3) = tFE(4); tFE(4) = temp;

N = linspace(40, 500, 47);
discrepData = zeros(d, length(N));
for i = 1:length(N)
    FE = spectralMethodInterp(trajData, @jac6DoF, N(i), d);
    FE = sortrows(FE, 'descend');
    for j = 1:d
        discrepData(j,i) = abs(FE(j)-tFE(j))/abs(tFE(j));
    end
end

figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto');
grid minor
hold on
plot(N, discrepData(1,:), '--om')
plot(N, discrepData(2,:), '--sb')
plot(N, discrepData(3,:), '--xr')
plot(N, discrepData(4,:), '--dk')
legend({'$\lambda_1$', '$\lambda_2$', '$\lambda_3$', '$\lambda_4$'}, 'Interpreter', 'latex')
xlabel('$N$', 'Interpreter', 'latex', 'FontSize', fontsize, 'FontName', fonttype)
ylabel('Relative error', 'FontSize', fontsize, 'FontName', fonttype)
saveas(gcf, 'plots\consistencyVDP.jpg', 'jpg')

function A = sysModel(t, trajData)
    prm.m = 4.5;
    prm.S = 0.473;
    prm.CD0 = 0.0173;
    prm.CD1 = -0.0337;
    prm.CD2 = 0.0517;
    prm.p_exp = trajData.p;
    % get state and control vector for jacobian
    tt  = trajData.T*trajData.fourierGrid/(2*pi);
    V     = interp_sinc(tt, trajData.X(:,1), t);
    chi   = interp_sinc(tt, trajData.X(:,2), t);
    chi = chi + trajData.chiLinearTerm*t;
    gamma = interp_sinc(tt, trajData.X(:,3), t);
    x     = interp_sinc(tt, trajData.X(:,4), t);
    y     = interp_sinc(tt, trajData.X(:,5), t);
    z     = interp_sinc(tt, trajData.X(:,6), t);
    CL = interp_sinc(tt, trajData.U(:,1), t);
    mu = interp_sinc(tt, trajData.U(:,2), t);
    CT = 0;
%     if strcmp(trajData.type, 'diff-flat')
%         CT = interp_sinc(tt, trajData.U(:,3), t);
%     else
%         CT = 0;
%     end
    Z = [V, chi, gamma, x, y, z];
    U = [CL, mu, CT, trajData.VR];
    % evaluate jacobian
    A = JacEval(Z, U, prm);
    A = [A(1:3,1:3), A(1:3,6); A(6,1:3), A(6,6)];
%     A = A(1:3, 1:3);
end