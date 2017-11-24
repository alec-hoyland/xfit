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

	use_cache = true
	purge_cache = false
	use_parallel = true
	nsteps = 300
	display_type = 'iter'
	max_fun_evals = 2e4
	minimise_r2 = false
	engine = 'patternsearch'
	tol_mesh = 1e-6
	tol_x = 1e-6


end % end props

methods
	function self = procrustes()
		% check for optimisation toolbox
		v = ver;
		assert(any(strcmp('Optimization Toolbox', {v.Name})),'optimisation toolbox is required')
		assert(any(strcmp('Global Optimization Toolbox', {v.Name})),'Global Optimization Toolbox is required')
	end % end constructor

	function self = set.x(self,value)
		value.closed_loop = false;
		assert(length(value)==1,'Only one Xolotl object at a time')
		value.skip_hash_check = true;
		self.x = value;
	end

	function updateParams(self,params)
		for i = 1:length(self.parameter_names)
			eval(['self.x.' self.parameter_names{i} '= params(' mat2str(i) ');'])
			% is there a way around this eval? I don't think so
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

		assert(~isempty(self.parameter_names),'No parameter names defined')

		self.x.transpile;
		self.x.compile;

		psoptions = psoptimset('UseParallel',self.use_parallel, 'Vectorized', 'off','Cache','on','CompletePoll','on','Display',self.display_type,'MaxIter',self.nsteps,'MaxFunEvals',self.max_fun_evals,'TolMesh',self.tol_mesh,'TolX',self.tol_x);


		if isempty(self.seed) && ~isempty(self.ub) && ~isempty(self.lb)
			% pick a random seed within bounds
			self.ub = self.ub(:);
			self.lb = self.lb(:);
			self.seed = (rand(length(self.ub),1).*(self.ub - self.lb) + self.lb);
		end

		assert(length(unique([length(self.seed), length(self.lb), length(self.ub)])) == 1, 'Length of lower bounds, upper bounds and seed should be the same')

		x = patternsearch(@(params) self.evaluate(params),self.seed,[],[],[],[],self.lb,self.ub,psoptions);
	end

end % end methods


end % end classdef
