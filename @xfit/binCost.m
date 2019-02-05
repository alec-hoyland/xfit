function c = binCost(allowed_range,actual_value)


if isnan(actual_value)
	c = 1;
	return
end

w = (allowed_range(2) - allowed_range(1))/2;
m = (allowed_range(2) + allowed_range(1))/2;

if actual_value < allowed_range(1)
	d = m - actual_value;
	c = (1- (w/d));
elseif actual_value > allowed_range(2)
	d = actual_value - m;
	c = (1- (w/d));
else
	% no cost
	c = 0;
end

