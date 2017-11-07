function r = PDdutyCycle(self,V,Ca)

bm = self.findBurstMetrics(V(:,2),Ca(:,2));

r = Inf;
if bm(2) > 0
	r = (bm(4)-bm(3))/bm(1);
end
