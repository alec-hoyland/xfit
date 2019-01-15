%                                      _            
%  _ __  _ __ ___   ___ _ __ _   _ ___| |_ ___  ___ 
% | '_ \| '__/ _ \ / __| '__| | | / __| __/ _ \/ __|
% | |_) | | | (_) | (__| |  | |_| \__ \ ||  __/\__ \
% | .__/|_|  \___/ \___|_|   \__,_|___/\__\___||___/
% |_|  
%
% fits a xolotl model 

function x = fit(self)

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

% now update the parameters of the xolotl object
self.x.set(self.parameter_names,self.seed)