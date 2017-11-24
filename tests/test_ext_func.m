% this function is an example of something that you 
% would feed to Procrustes to optimize. 
% within this function, you can run arbitrary commands
% on xolotl objects, and measure whatever you want,
% and even vary parameters on the object. 
% as long as this returns a cost, it's all good. 

function [C, duty_cycle, freq, n_spikes_per_burst, example_V] = test_ext_fun(x)




% specify our targets
target_duty_cycle = .2;
I_ext = linspace(0,1,5);
target_burst_freq = linspace(1,3,5); % Hz
min_n_spikes = 3;

% make placeholders for outputs
C = 0;
duty_cycle = NaN*I_ext;
freq = NaN*I_ext;
n_spikes_per_burst = NaN*I_ext;
example_V = NaN;


for i = 1:length(I_ext)
    x.I_ext = I_ext(i);

    try
		% run the xolotl simulation, run the functions and evaluate the cost
		[V,Ca] = x.integrate;
	catch
		C = Inf;
		return
	end

	% skip some transient
	transient_cutoff = floor(length(V)/2);
	Ca = Ca(transient_cutoff:end,1);
	V = V(transient_cutoff:end);

	if i == 2 & nargout > 1
		example_V = V;
	end

	bm = psychopomp.findBurstMetrics(V,Ca);

	n_spikes_per_burst(i) = bm(2);
	duty_cycle(i) = 10;

	if bm(2) > 0
		duty_cycle(i) = (bm(4)-bm(3))/bm(1);
	end

	if bm(2) < min_n_spikes
		C = Inf;
		return
	end

	freq(i) = 1e3/(bm(1)*x.dt);

	this_dc_cost = ((duty_cycle(i) - target_duty_cycle).^2)/(target_duty_cycle^2);
	this_freq_cost = ((freq(i) - target_burst_freq(i))/target_burst_freq(i))^2;

	C = C + this_dc_cost + this_freq_cost;

end	

C = C*100;

if isnan(C)
	C = 1e3;
end