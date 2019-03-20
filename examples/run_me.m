% in this example script, we take a neuron
% and optimize its maximal conductances so that it has a 
% desired period

x = xolotl.examples.BurstingNeuron('prinz');

p = xfit;

p.sim_func = @example_func;

p.x = x;


p.parameter_names = x.find('*gbar');
p.lb = [100 0 0 0 0 500 500];
p.ub = [1e3 100 100 10 500 2000 2000];



figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(2,1,1); hold on

x.t_end = 10e3;
V = x.integrate;
time = (1:length(V))*1e-3*x.dt;
plot(time,V,'k')
title('Before optimization')


p.fit;

x.set('*gbar',p.seed)

subplot(2,1,2); hold on

x.t_end = 10e3;
V = x.integrate;
time = (1:length(V))*1e-3*x.dt;
plot(time,V,'r')
title('After optimization')

figlib.pretty('plw',1,'lw',1)