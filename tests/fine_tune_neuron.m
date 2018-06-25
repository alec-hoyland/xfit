%%
% in this example script, we take an example neuron
% and fine tune its parameters so that it has 
% a specific:
% 1) burst frequency
% 2) duty cycle
% 3) slow wave voltage minimum
% 4) slow wave voltage maximum  


% conversion from Prinz to phi
A = 0.0628;

channels = {'NaV','CaT','CaS','ACurrent','KCa','Kd','HCurrent'};
prefix = 'prinz/';
gbar = [1000 25  60 500  50  1000 .1];
E =    [50   30  30 -80 -80 -80   -20];
lb =   [100  1   1  1    1   100   0];
ub =   gbar*2;


x = xolotl;

x.add('compartment','AB','Cm',10,'A',A,'vol',A,'phi',906);


for i = 1:length(channels)
	x.AB.add([prefix channels{i}],'gbar',gbar(i),'E',E(i));
end


x.dt = .1;
x.sim_dt = .1;

x.integrate;
V = x.integrate;




p = procrustes('particleswarm');
p.x = x;

p.data.LeMassonMatrix = procrustes.V2matrix(V,[-80 50],[-20 30]);



p.parameter_names = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar'};
N = length(p.parameter_names);

p.lb = lb;
p.ub = ub;

p.sim_func = @example_func;

p.seed = [];


figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
t = x.dt*(1:length(V))*1e-3;
c = lines;
for i = 1:6
	p.seed = [];
	subplot(2,3,i); hold on
	p.fit;
	V = p.x.integrate;
	plot(t,V,'Color',c(i,:))
	drawnow
end