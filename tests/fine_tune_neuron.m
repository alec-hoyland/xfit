%%
% in this example script, we take an example neuron
% and fine tune its parameters so that it has 
% a specific:
% 1) burst frequency
% 2) duty cycle
% 3) slow wave voltage minimum
% 4) slow wave voltage maximum  



vol = 1; % this can be anything, doesn't matter
f = 14.96; % uM/nA
tau_Ca = 200;
F = 96485; % Faraday constant in SI units
phi = (2*f*F*vol)/tau_Ca;

x = xolotl;
x.cleanup;

x.add('AB','compartment','V',-65,'Ca',0.02,'Cm',10,'A',0.0628,'vol',vol,'phi',phi,'Ca_out',3000,'Ca_in',0.05,'tau_Ca',tau_Ca);

x.AB.add('prinz-approx/NaV','gbar',1000,'E',50);
x.AB.add('prinz-approx/CaT','gbar',25,'E',30);
x.AB.add('prinz-approx/CaS','gbar',60,'E',30);
x.AB.add('prinz-approx/ACurrent','gbar',500,'E',-80);
x.AB.add('prinz-approx/KCa','gbar',50,'E',-80);
x.AB.add('prinz-approx/Kd','gbar',1000,'E',-80);
x.AB.add('prinz-approx/HCurrent','gbar',.1,'E',-20);
x.AB.add('Leak','gbar',.3,'E',-50);

x.sim_dt = .1;
x.dt = .1;
x.t_end = 20e3;

x.transpile;
x.compile;

V = x.integrate;


p = procrustes('particleswarm');
p.x = x;

p.parameter_names = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar','AB.Leak.gbar'};

p.lb = 1e-3 + zeros(1,8);
p.ub = 1500*ones(1,8);

p.sim_func = @example_func;

% figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
% t = x.dt*(1:length(V))*1e-3;
% c = lines;
% for i = 1:6
% 	p.seed = rand(8,1)*10;
% 	subplot(2,3,i); hold on
% 	p.fit;
% 	p.updateParams(p.seed);
% 	V = p.x.integrate;
% 	plot(t,V,'Color',c(i,:))
% end