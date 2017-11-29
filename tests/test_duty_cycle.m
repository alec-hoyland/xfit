% testing script


% first, set up a Xolotl object

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

x.I_ext = 0;
x.dt = 100e-3;
x.t_end = 20e3;

x.transpile;
x.compile;
V = x.integrate;


p = procrustes;
p.x = x;

p.parameter_names = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar'};

p.seed = [1000 25 60 500 50 1000 .1];
p.lb = 0*p.seed;
p.ub = 2e3*ones(1,length(p.parameter_names));


p.sim_func = @test_ext_func;
p.plot_func = @test_plot_func;

return

tic
g = p.fit;
toc
p.updateParams(g);


x = p.x;

I_ext = linspace(0,1,10);
duty_cycle = NaN*I_ext;
burst_period = NaN*I_ext;
n_spikes_per_burst = NaN*I_ext;

for i = 1:length(I_ext)
	x.I_ext = I_ext(i);
	[V,Ca] = x.integrate;


	transient_cutoff = floor(length(V)/2);
	Ca = Ca(transient_cutoff:end,1);
	V = V(transient_cutoff:end);


	bm = psychopomp.findBurstMetrics(V,Ca);
	duty_cycle(i) = (bm(4)-bm(3))/bm(1);
	burst_period(i) = bm(1);
	n_spikes_per_burst(i) = bm(2);
end





