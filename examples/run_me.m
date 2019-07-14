% in this example script, we take a neuron
% and optimize its maximal conductances so that it has a
% desired period

% first, we create our xolotl object
x = xolotl.examples.BurstingNeuron('prefix','prinz');

% we instantiate the xfit object
% and specify the particle swarm engine
p = xfit('particleswarm');

% we assign a cost function
p.sim_func = @example_func;

% we assign the xolotl object
p.x = x;

% we optimzie over all maximal conductances
p.parameter_names = x.find('*gbar');
% lower bound values
p.lb = [100 0 0 0 0 500 500];
% upper bound values
p.ub = [1e3 100 100 10 500 2000 2000];

% display the results before optimization
figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on

subplot(2,1,1); hold on

x.t_end = 10e3;
V = x.integrate;
time = (1:length(V))*1e-3*x.dt;
plot(time,V,'k')
title('Before optimization')

% perform the optimization procedure
p.fit;

% the best fit is stored in p.seed
% set the existing xolotl object to match
x.set('*gbar',p.seed)


% visualize the results of the optimization
subplot(2,1,2); hold on

x.t_end = 10e3;
V = x.integrate;
time = (1:length(V))*1e-3*x.dt;
plot(time,V,'r')
title('After optimization')

figlib.pretty('LineWidth', 1, 'PlotlineWidth', 1, 'PlotBuffer', 0.2)
