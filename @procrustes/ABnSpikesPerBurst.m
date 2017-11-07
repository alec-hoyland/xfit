function n = ABnSpikesPerBurst(self,V,Ca)
  bm = self.findBurstMetrics(V(:,1),Ca(:,1));
  n = burst_metrics(2);
end
