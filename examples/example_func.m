function C = example_func(x,~,~)

x.reset;
x.t_end = 10e3;
x.approx_channels = 1;
x.sim_dt = .1;
x.dt = .1;
x.closed_loop = true;

x.integrate;
V = x.integrate;

metrics = xtools.V2metrics(V,'sampling_rate',10);

C = xfit.binCost([950 1050],metrics.burst_period);

C = C + xfit.binCost([7 10],metrics.n_spikes_per_burst_mean);

if isnan(C)
	C = 1e3;
end