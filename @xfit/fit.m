%{
       __ _ _   
__  __/ _(_) |_ 
\ \/ / |_| | __|
 >  <|  _| | |_ 
/_/\_\_| |_|\__|
                

### fit

**Syntax**

```matlab
best_fit_params = fit(self);
```

**Description**

Runs the optimization algorithm in an effort to minimze
the cost function. Returns a vector of the best-fit
parameters. Only the last (best-fit) value is returned. 

The best-fit value is also used to update the seed

%}

function fit(self)

assert(~isempty(self.parameter_names),'No parameter names defined')
assert(~isempty(self.x),'Xolotl object not configured')
assert(~isempty(self.sim_func),'Simulation function not set')

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

	best_fit_params = patternsearch(@(params) self.evaluate(params),self.seed,[],[],[],[],self.lb,self.ub,self.options);
	self.seed = best_fit_params;

case 'particleswarm'
	
	self.options.InitialSwarmMatrix = self.seed(:)';
	best_fit_params = particleswarm(@(params) self.evaluate(params),length(self.ub),self.lb,self.ub,self.options);
	self.seed = best_fit_params;
case 'ga'
	self.options.InitialPopulationMatrix = self.seed;
	best_fit_params = ga(@(params) self.evaluate(params), length(self.ub), [], [], [], [], self.lb, self.ub, [], self.options);
	self.seed = best_fit_params;

end

% now update the parameters of the xolotl object
self.x.set(self.parameter_names,self.seed)