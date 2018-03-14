%%
% in this example script, we take an example neuron
% and fine tune its parameters so that it has 
% a specific:
% 1) burst frequency
% 2) duty cycle
% 3) slow wave voltage minimum
% 4) slow wave voltage maximum  


% conversion from Prinz to phi
vol = 1; % this can be anything, doesn't matter
f = 14.96; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;

x = xolotl;
x.cleanup;
x.addCompartment('AB',-65,0.02,10,0.0628,vol,phi,3000,0.05,tau_Ca,0);

x.addConductance('AB','prinz/NaV',1000,50);
x.addConductance('AB','prinz/CaT',25,30);
x.addConductance('AB','prinz/CaS',60,30);
x.addConductance('AB','prinz/ACurrent',500,-80);
x.addConductance('AB','prinz/KCa',50,-80);
x.addConductance('AB','prinz/Kd',1000,-80);
x.addConductance('AB','prinz/HCurrent',.1,-20);
x.addConductance('AB','Leak',.3,-50);

x.dt = 100e-3;
x.t_end = 20e3;

x.transpile;
x.compile;
x.I_ext = 0;
V = x.integrate;


p = procrustes('ga');
p.x = x;

p.parameter_names = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar','AB.Leak.gbar'};

p.seed = [1000 25 60 500 50 1000 .1 .3];
p.lb = 1e-3*p.seed;
p.ub = 10*p.seed;

p.sim_func = @example_func;