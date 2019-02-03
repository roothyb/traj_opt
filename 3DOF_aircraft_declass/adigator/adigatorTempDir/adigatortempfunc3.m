function [adigatorFunInfo, adigatorOutputs] = adigatortempfunc3(adigatorFunInfo,adigatorInputs)
[flag, adigatorFunInfo, adigatorInputs] = adigatorFunctionInitialize(3,adigatorFunInfo,adigatorInputs);
if flag; adigatorOutputs = adigatorInputs; return; end;
sigma = adigatorInputs{1};
VR = adigatorInputs{2};
nargin = 2; nargout = 2;m = 4.5;
m = adigatorVarAnalyzer('m = 4.5;',m,'m',0);
rho = 1.225;
rho = adigatorVarAnalyzer('rho = 1.225;',rho,'rho',0);
S = 0.473;
S = adigatorVarAnalyzer('S = 0.473;',S,'S',0);
g = 9.806;
g = adigatorVarAnalyzer('g = 9.806;',g,'g',0);
Cd0 = 0.0173;
Cd0 = adigatorVarAnalyzer('Cd0 = 0.0173;',Cd0,'Cd0',0);
Cd1 = -0.0337;
Cd1 = adigatorVarAnalyzer('Cd1 = -0.0337;',Cd1,'Cd1',0);
Cd2 = 0.0517;
Cd2 = adigatorVarAnalyzer('Cd2 = 0.0517;',Cd2,'Cd2',0);
b = 3;
b = adigatorVarAnalyzer('b = 3;',b,'b',0);
z = sigma(3);
z = adigatorVarAnalyzer('z = sigma(3);',z,'z',0);
zdot = sigma(6);
zdot = adigatorVarAnalyzer('zdot = sigma(6);',zdot,'zdot',0);
xdot = sigma(4);
xdot = adigatorVarAnalyzer('xdot = sigma(4);',xdot,'xdot',0);
ydot = sigma(5);
ydot = adigatorVarAnalyzer('ydot = sigma(5);',ydot,'ydot',0);
zddot = sigma(9);
zddot = adigatorVarAnalyzer('zddot = sigma(9);',zddot,'zddot',0);
xddot = sigma(7);
xddot = adigatorVarAnalyzer('xddot = sigma(7);',xddot,'xddot',0);
yddot = sigma(8);
yddot = adigatorVarAnalyzer('yddot = sigma(8);',yddot,'yddot',0);
adigatorVarAnalyzer('% wind model');
p_exp = 1;
p_exp = adigatorVarAnalyzer('p_exp = 1;',p_exp,'p_exp',0);
Wx = VR*(-z)^p_exp;
Wx = adigatorVarAnalyzer('Wx = VR*(-z)^p_exp;',Wx,'Wx',0);
Wxz = (p_exp*VR)*((-z)^p_exp)/z;
Wxz = adigatorVarAnalyzer('Wxz = (p_exp*VR)*((-z)^p_exp)/z;',Wxz,'Wxz',0);
adigatorVarAnalyzer('% non flat outputs');
V = ((xdot - Wx)^2 + ydot^2 + zdot^2)^0.5;
V = adigatorVarAnalyzer('V = ((xdot - Wx)^2 + ydot^2 + zdot^2)^0.5;',V,'V',0);
Vdot = (xdot*xddot - xdot*zdot*Wxz - xddot*Wx + Wx*Wxz*zdot + ydot*yddot + zdot*zddot)/V;
Vdot = adigatorVarAnalyzer('Vdot = (xdot*xddot - xdot*zdot*Wxz - xddot*Wx + Wx*Wxz*zdot + ydot*yddot + zdot*zddot)/V;',Vdot,'Vdot',0);
gamma = -asin(zdot/V);
gamma = adigatorVarAnalyzer('gamma = -asin(zdot/V);',gamma,'gamma',0);
gammadot = (zdot*Vdot - V*zddot)/(V*(V^2 - zdot^2)^0.5);
gammadot = adigatorVarAnalyzer('gammadot = (zdot*Vdot - V*zddot)/(V*(V^2 - zdot^2)^0.5);',gammadot,'gammadot',0);
chi = atan2(ydot,(xdot - Wx));
chi = adigatorVarAnalyzer('chi = atan2(ydot,(xdot - Wx));',chi,'chi',0);
chidot = (xdot*yddot - yddot*Wx - ydot*xddot + ydot*zdot*Wxz)/(ydot^2 + xdot^2 + Wx^2 - 2*xdot*Wx);
chidot = adigatorVarAnalyzer('chidot = (xdot*yddot - yddot*Wx - ydot*xddot + ydot*zdot*Wxz)/(ydot^2 + xdot^2 + Wx^2 - 2*xdot*Wx);',chidot,'chidot',0);
nu = atan((V*cos(gamma)*chidot - Wxz*zdot*sin(chi))/(V*gammadot + g*cos(gamma) - Wxz*cos(chi)*sin(gamma)*zdot));
nu = adigatorVarAnalyzer('nu = atan((V*cos(gamma)*chidot - Wxz*zdot*sin(chi))/(V*gammadot + g*cos(gamma) - Wxz*cos(chi)*sin(gamma)*zdot));',nu,'nu',0);
Cl = (m*V*cos(gamma)*chidot - m*Wxz*zdot*sin(chi))/(0.5*rho*S*sin(nu)*V^2);
Cl = adigatorVarAnalyzer('Cl = (m*V*cos(gamma)*chidot - m*Wxz*zdot*sin(chi))/(0.5*rho*S*sin(nu)*V^2);',Cl,'Cl',0);
adigatorVarAnalyzer('%             if(nu == 0 && (chidot == 0 || zdot == 0 || chi == 0))');
adigatorVarAnalyzer('%                 Cl = 0;');
adigatorVarAnalyzer('%             end');
adigatorVarAnalyzer('% aerodynamic forces');
Cd = Cd0 + Cd1*Cl + Cd2*Cl^2;
Cd = adigatorVarAnalyzer('Cd = Cd0 + Cd1*Cl + Cd2*Cl^2;',Cd,'Cd',0);
D = 0.5*rho*S*V^2*Cd;
D = adigatorVarAnalyzer('D = 0.5*rho*S*V^2*Cd;',D,'D',0);
T = m*Vdot + D + m*g*sin(gamma) + m*Wxz*zdot*cos(gamma)*cos(chi);
T = adigatorVarAnalyzer('T = m*Vdot + D + m*g*sin(gamma) + m*Wxz*zdot*cos(gamma)*cos(chi);',T,'T',0);
CT = T/(0.5*rho*S*V^2);
CT = adigatorVarAnalyzer('CT = T/(0.5*rho*S*V^2);',CT,'CT',0);
x = [V, gamma, chi];
x = adigatorVarAnalyzer('x = [V, gamma, chi];',x,'x',0);
u = [Cl, nu, CT];
u = adigatorVarAnalyzer('u = [Cl, nu, CT];',u,'u',0);
adigatorOutputs = {x;u};
[adigatorFunInfo, adigatorOutputs] = adigatorFunctionEnd(3,adigatorFunInfo,adigatorOutputs);