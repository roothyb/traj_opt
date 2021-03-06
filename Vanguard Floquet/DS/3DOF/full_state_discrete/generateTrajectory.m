%L - 100 - 4700

clearvars
addpath('../lib')

type = 'circle';
% load('solutions\L60.mat');
N = 60;
p = 0.25;
% X0 = sol;
X0 = init_guess(N, type, p);
% X0(N+1:2*N) = unwrap(X0(N+1:2*N));
% load('solutions\EE50.mat')
% X0 = sol;

[D, fourierGrid] = fourierdiff(N);
column2 = [-(N^2)/12-1/6, -((-1).^(1:(N-1)))./(2*(sin((1:(N-1))*pi/N)).^2)];
DD = toeplitz(column2,column2([1, N:-1:2])); % second derivative matrix

[lb, ub] = optimbounds(N, type);
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp', 'UseParallel', true);
options.MaxIterations = 10000;
options.MaxFunctionEvaluations = 100000000;
% options.StepTolerance = 1e-12;
sol = fmincon(@(X) objectiveFunctionFSD(X, 'traj', type), X0, [], [], [], [], lb, ub, @(X) constrainFunctionFSD(X,p,D,DD,fourierGrid,type), options);
rmpath('../lib')

function X0 = init_guess(N, type, p)
    if strcmp(type, 'circle') 
        VR_0 = 0.1; tf_0 = 10;
        [~, x] = fourierdiff(N);
        t = tf_0*x/(2*pi);
        x = 20*(-1 + cos(2*pi*t/tf_0));
        y = -20*(2^0.5)*sin(2*pi*t/tf_0);
        z = -20*(1 - cos(2*pi*t/tf_0)) - 0.15;    
    elseif strcmp(type, 'eight')
        VR_0 = 0.1; tf_0 = 20;
        [~, x] = fourierdiff(N);
        t = tf_0*x/(2*pi);
        x = -20*sin(4*pi*t/tf_0);
        y = -40*sqrt(2)*sin(2*pi*t/tf_0);
        z = -20*(sin(4*pi*t/tf_0) + 1) - 0.11; 
    end
    [x,u] = getTrajFFT([x', y',z'], tf_0, VR_0, p);
    X0 = [x(:,1); x(:,2); x(:,3); x(:,4); x(:,5); x(:,6); u(:,1); u(:,2); tf_0; VR_0];
    if strcmp(type, 'circle')
        X0(8*N+3) = 0;
    end
end

function [lb, ub] = optimbounds(N, type)
    if strcmp(type, 'circle')
        lb = zeros(8*N+3,1); ub = zeros(8*N+3,1);
    else
        lb = zeros(8*N+2,1); ub = zeros(8*N+2,1);
    end
    lbounds = [10, -2*pi, -pi/4, -200, -200, -200,  -0.2, -pi/3];
    ubounds = [80,  2*pi,  pi/4,  200,  200,-0.01,  1.17,  pi/3];
    for i = 1:8
        j = (i-1)*N; 
        lb(j+1:j+N,1) = lbounds(i)*ones(N,1);
        ub(j+1:j+N,1) = ubounds(i)*ones(N,1);
    end
    lb(8*N+1,1) = 0; ub(8*N+1,1) = 150;
    lb(8*N+2,1) = 0; ub(8*N+2,1) = 150;
    if strcmp(type, 'circle')
        lb(8*N+3) = -Inf; ub(8*N+3) = Inf;
    end
end