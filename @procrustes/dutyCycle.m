function r = dutyCycle(self,V,Ca)

bm = self.findBurstMetrics(V,Ca);

r = Inf;
if bm(2) > 0
	r = (bm(4)-bm(3))/bm(1);
end