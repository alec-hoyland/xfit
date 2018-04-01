% procrustes is a toolbox that attempts
% to change parameters in a Xolotl object
% so that it fits some arbitrary set of conditions

classdef procrustes < handle

properties
	x@xolotl

	% manual, interactive optimization
	plot_func@function_handle
	handles
	puppeteer_obj@puppeteer

	% function to minimize
	sim_func@function_handle

	% parameters to optimize
	parameter_names@cell
	seed
	lb
	ub

	options

	display_type = 'iter'
	minimise_r2 = false
	engine 


	% logging
	timestamp
	best_cost


end % end props

methods
	function self = procrustes(engine)
		% check for optimisation toolbox
		v = ver;
		gcp;
		assert(any(strcmp('Optimization Toolbox', {v.Name})),'optimisation toolbox is required')
		assert(any(strcmp('Global Optimization Toolbox', {v.Name})),'Global Optimization Toolbox is required')
		self.engine = engine;

	end % end constructor

	function self = set.x(self,value)
		value.closed_loop = false;
		assert(length(value) == 1,'Only one Xolotl object at a time')
		self.x = value;
	end

	function updateParams(self,params)
		for i = 1:length(self.parameter_names)
			self.x.set(self.parameter_names{i},params(i))
		end
	end

	function c = evaluate(self,params)
		% update parameters in the xolotl object using x
		self.updateParams(params);
		c = self.sim_func(self.x);
	end

	function manipulate(self)

		assert(~isempty(self.parameter_names),'No parameter names defined')

		if isempty(self.plot_func)
			disp('not coded yet')
		else
			% call the plot_func to make the figure
			self.handles = self.plot_func();

			% make a puppeteer object 

			S = struct;
			L = struct;
			U = struct;
			for i = 1:length(self.parameter_names)
				S.(strrep(self.parameter_names{i},'.','_')) = self.seed(i);
				L.(strrep(self.parameter_names{i},'.','_')) = self.lb(i);
				U.(strrep(self.parameter_names{i},'.','_')) = self.ub(i);
			end

			self.puppeteer_obj = puppeteer(S,L,U);
			self.puppeteer_obj.callback_function = @self.puppeteerCallback;
		end

	end

	function puppeteerCallback(self,params)
		self.updateParams(struct2vec(params));

		self.plot_func(self.handles,self.x);
	end

	function x = fit(self)

		self.x.skip_hash_check = true;

		assert(~isempty(self.parameter_names),'No parameter names defined')

		if isempty(self.seed) && ~isempty(self.ub) && ~isempty(self.lb)
			% pick a random seed within bounds
			self.ub = self.ub(:);
			self.lb = self.lb(:);
			self.seed = (rand(length(self.ub),1).*(self.ub - self.lb) + self.lb);
		end

		% reset logging
		self.timestamp = NaN(1e3,1);
		self.best_cost = NaN(1e3,1);


		assert(length(unique([length(self.seed), length(self.lb), length(self.ub)])) == 1, 'Length of lower bounds, upper bounds and seed should be the same')

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

	end % end fit

	function self = set.engine(self,value)
		pool = gcp;
		switch value 
		case 'patternsearch'
			self.engine = 'patternsearch';
			self.options = optimoptions('patternsearch');
			self.options.UseParallel = true;
			self.options.Display = 'iter';
			self.options.MaxTime = 100;
			self.options.OutputFcn = @self.pattern_logger;
		case 'particleswarm'
			self.engine = 'particleswarm';
			self.options = optimoptions('particleswarm');
			self.options.UseParallel = true;
			self.options.ObjectiveLimit = 0;
			self.options.Display = 'iter';
			self.options.MaxTime = 100;
			self.options.OutputFcn = @self.swarm_logger;
			self.options.SwarmSize = 2*pool.NumWorkers;
		case 'ga'
			self.engine = 'ga';
			self.options = optimoptions('ga');
			self.options.UseParallel = true;
			self.options.FitnessLimit = 0;
			self.options.Display = 'iter';
			self.options.MaxTime = 100;
			self.options.OutputFcn = @self.ga_logger;
		otherwise 
			error('Unknown engine')
		end
	end % set engine

	function stop = swarm_logger(self,optimValues,~)
		stop = false;

		self.best_cost(optimValues.iteration+1) = optimValues.bestfval;
		self.timestamp(optimValues.iteration+1) = now;

	end

	function [stop, options, optchanged] = pattern_logger(self,optimValues,options,~)
		stop = false;
		optchanged = false;
		self.best_cost(optimValues.iteration+1) = optimValues.fval;
		self.timestamp(optimValues.iteration+1) = now;
	end

	function [state, options, optchanged] = ga_logger(self, options, state, flag)
		optchanged = false;
		self.best_cost(state.Generation + 1) = min(state.Score);
		self.timestamp(state.Generation + 1) = now;
	end % end ga logger

end % end methods


end % end classdef
