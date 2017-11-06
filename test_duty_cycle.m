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

x.I_ext = 0;

figure('outerposition',[300 300 1200 600],'PaperUnits','points','PaperSize',[1200 600]); hold on
time = x.dt:x.dt:x.t_end;
plot(time,x.integrate,'k')


p = procrustes;
p.x = x;

% configure 
p.f = {@p.dutyCycle};

p.parameters_to_vary = {'I_ext'};
p.parameter_values = linspace(0,1,5);

p.targets = [0.0516]; 
p.weights = [100];



p.parameter_names = {'AB.NaV.gbar','AB.CaT.gbar','AB.CaS.gbar','AB.ACurrent.gbar','AB.KCa.gbar','AB.Kd.gbar','AB.HCurrent.gbar'};

p.seed = [1830 23 27 246 980 610 10];
p.lb = 0*p.seed;
p.ub = 2e3*ones(1,7);

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
	bm = p.findBurstMetrics(V,Ca);
	duty_cycle(i) = (bm(4)-bm(3))/bm(1);
	burst_period(i) = bm(1);
	n_spikes_per_burst(i) = bm(2);
end


figure('outerposition',[300 300 1800 600],'PaperUnits','points','PaperSize',[1800 600]); hold on
subplot(1,3,1); hold on
plot(I_ext,p.targets + 0*I_ext,'r--')
plot(I_ext,duty_cycle,'ko-')
set(gca,'YLim',[0 1])
xlabel('I_{ext} (nA)')
ylabel('Duty cycle')

subplot(1,3,2); hold on
plot(I_ext,burst_period*x.dt,'ko-')
ylabel('Burst period (ms)')
xlabel('I_{ext} (nA)')
set(gca,'YLim',[0 400])

subplot(1,3,3); hold on
plot(I_ext,n_spikes_per_burst,'ko-')
ylabel('# spikes/burst')
xlabel('I_{ext} (nA)')
set(gca,'YLim',[0 5])

prettyFig();

if being_published
	snapnow
	delete(gcf)
end




