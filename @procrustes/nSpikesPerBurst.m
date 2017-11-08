function n = nSpikesPerBurst(self,V,Ca)

[burst_metrics] = findBurstMetrics(self,V,Ca);

n = burst_metrics(2);
