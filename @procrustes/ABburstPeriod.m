function ABburstPeriod(self,V,Ca)

    bm = self.findBurstMetrics(V(:,1),Ca(:,1));

    r = Inf;
    if bm(2) > 0
        r = bm(1)*self.x.dt;
    end
end
