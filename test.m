% testing scrupt


vol = 0.0628; % this can be anything, doesn't matter
f = 1.496; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;
Ca_target = 0; % used only when we add in homeostatic control 

x = xolotl;
x.addCompartment('AB',-60,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,Ca_target);

% set up a relational parameter
x.AB.vol = @() x.AB.A;

x.addConductance('AB','liu/NaV',1830,30);
x.addConductance('AB','liu/CaT',@() 1.44/x.AB.A,30);
x.addConductance('AB','liu/CaS',@() 1.7/x.AB.A,30);
x.addConductance('AB','liu/ACurrent',@() 15.45/x.AB.A,-80);
x.addConductance('AB','liu/KCa',@() 61.54/x.AB.A,-80);
x.addConductance('AB','liu/Kd',@() 38.31/x.AB.A,-80);
x.addConductance('AB','liu/HCurrent',@() .6343/x.AB.A,-20);
x.addConductance('AB','Leak',@() 0.0622/x.AB.A,-50);


figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
time = x.dt:x.dt:x.t_end;
plot(time,x.integrate,'k')


p = procrustes;
p.x = x;

% configure 
p.f = {@p.burstPeriod, @p.nSpikesPerBurst};
p.targets = [714, 4]; 
p.weights = [100, 100];



p.parameter_names = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar'};

p.seed = [1830 23 27 246 980 610 10];
p.lb = 0*p.seed;
p.ub = 2e3*ones(1,7);

tic
g = p.fit;
toc
p.updateParams(g);

x = p.x;
plot(time,x.integrate,'r')

