% this function is an example of something that you 
% would feed to Procrustes to optimize. 
% within this function, you can run arbitrary commands
% on xolotl objects, and measure whatever you want,
% and even vary parameters on the object. 
% as long as this returns a cost, it's all good. 

function C = example_func(x)

inf_cost = 1;
C = inf_cost;

try

	C = 0;

	% specify our targets
	target_freq = .5;
	target_dc = .3;
	min_n_spikes = 3; 

	target_V_min = -70;
	target_V_max = -40;

	% run the xolotl simulation, run the functions and evaluate the cost
	try
		[V,Ca] = x.integrate;
	catch
		C = inf_cost;
		return
	end

	T = floor(50/x.dt);
	Vf = fastFiltFilt(ones(T,1),T,V);

	% skip some transient
	transient_cutoff = floor(length(V)/4);
	Ca = Ca(transient_cutoff:end,1);
	V = V(transient_cutoff:end);
	Vf = Vf(transient_cutoff:end);

	bm = psychopomp.findBurstMetrics(V,Ca);

	dc = bm(9);
	if bm(2) == 0
		% no spikes
		C = inf_cost;
		return
	end


	% make sure we have at least min_n_spikes/burst
	if bm(2) < min_n_spikes
		C = inf_cost;
	end

	this_freq = 1e3/(bm(1)*x.dt);
	this_freq_cost = ((this_freq - target_freq)/target_freq)^2;
	dc_cost = ((dc - target_dc)/target_dc)^2;

	% make sure the slow wave looks nice
	V_min_cost = ((min(Vf) - target_V_min)/target_V_min)^2;
	V_max_cost = ((max(Vf) - target_V_max)/target_V_max)^2;

	C =  C + this_freq_cost + dc_cost + V_min_cost + V_max_cost;

	% penalize spikes that go below slow wave
	if min(Vf) > min(V)
		C = C + (min(V) - min(Vf))^2;
	end
 
catch
	return
end