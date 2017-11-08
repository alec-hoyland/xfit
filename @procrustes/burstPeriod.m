function r = burstPeriod(self,V,Ca)

[burst_metrics] = self.findBurstMetrics(V,Ca);

r = 1000;
if burst_metrics(2) > 0
	r = burst_metrics(1)*self.x.dt;
end
