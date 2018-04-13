function x = fit(self)

assert(~isempty(self.parameter_names),'No parameter names defined')
assert(~isempty(self.x),'Xolotl object not configured')


if isempty(self.seed) && ~isempty(self.ub) && ~isempty(self.lb)
	% pick a random seed within bounds
	self.ub = self.ub(:);
	self.lb = self.lb(:);
	self.seed = (rand(length(self.ub),1).*(self.ub - self.lb) + self.lb);
end

% reset logging
self.timestamp = NaN(1e3,1);
self.best_cost = NaN(1e3,1);


assert(length(unique([length(self.seed),length(self.parameter_names) , length(self.lb), length(self.ub)])) == 1, 'Length of lower bounds, upper bounds, parameter_names, and seed should be the same')

switch self.engine
case 'patternsearch'

	x = patternsearch(@(params) self.evaluate(params),self.seed,[],[],[],[],self.lb,self.ub,self.options);
	self.seed = x;

case 'particleswarm'
	
	self.options.InitialSwarmMatrix = self.seed(:)';
	x = particleswarm(@(params) self.evaluate(params),length(self.ub),self.lb,self.ub,self.options);
	self.seed = x;
case 'ga'
	self.options.InitialPopulationMatrix = self.seed;
	x = ga(@(params) self.evaluate(params), length(self.ub), [], [], [], [], self.lb, self.ub, [], self.options);
	self.seed = x;

end

