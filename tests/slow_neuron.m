% this function is an example of something that you 
% would feed to Procrustes to optimize. 
% within this function, you can run arbitrary commands
% on xolotl objects, and measure whatever you want,
% and even vary parameters on the object. 
% as long as this returns a cost, it's all good. 

function C = slow_neuron(x)


C = 0;

% specify our targets
target_freq = 1;
target_dc = .2;
max_n_spikes = Inf;
min_n_spikes = 3; 

% run the xolotl simulation, run the functions and evaluate the cost
try
	[V,Ca] = x.integrate;
catch
	C = Inf;
	return
end

% skip some transient
transient_cutoff = floor(length(V)/2);
Ca = Ca(transient_cutoff:end,1);
V = V(transient_cutoff:end);

bm = psychopomp.findBurstMetrics(V,Ca);

dc = 10;
if bm(2) > 0
	dc = (bm(4)-bm(3))/bm(1);
else
	% no spikes
	C = Inf;
	return
end

if bm(2) > max_n_spikes
	C = C + 10*(bm(2) - max_n_spikes)^2;
end

if bm(2) < min_n_spikes
	C = C + 10*(bm(2) - min_n_spikes)^2;
end

this_freq = 1e3/(bm(1)*x.dt);

this_freq_cost = ((this_freq - target_freq)/target_freq)^2;
dc_cost = ((dc - target_dc)/target_dc)^2;

C =  C + this_freq_cost + dc_cost;
C = C*100;

if isnan(C)
	C = 1e3;
end