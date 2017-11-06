% procrustes is a toolbox that attempts
% to change parameters in a Xolotl object
% so that it fits some arbitrary set of conditions

classdef procrustes

properties
	x@xolotl
	
	% function to minimize 
	f@cell 
	targets
	weights

	% parameters to optimize 
	parameter_names@cell
	seed
	lb
	ub

	% parameters to vary while optimizing 
	parameters_to_vary@cell
	parameter_values
	

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

	transient_length = 0.5


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
		

		% vary additional params if need be
		if isempty(self.parameters_to_vary)

			% run the xolotl simulation, run the functions and evaluate the cost
			[V,Ca] = self.x.integrate;

			% skip some transient
			z = floor(length(V)*self.transient_length);
			V(1:z,:) = [];
			Ca(1:z,:) = [];

			% run functions on this
			n_comp = length(self.x.compartment_names);
			c = zeros(n_comp,length(self.f));
			for i = 1:length(self.f)
				for j = 1:n_comp
					c(j,i) = self.f{i}(V(:,j),Ca(:,j));
				end
			end


			c = (((c - self.targets).^2)./(self.targets.^2)).*self.weights;
			c = sum(c);
			if isnan(c)
				c = Inf;
			end

		else
			C = 0;
			assert(length(self.parameters_to_vary) == 1,'More than one parameter to vary while optimizing not supported yet')
			for i = 1:length(self.parameter_values)
				self.x.(self.parameters_to_vary{1}) = self.parameter_values(i);

				% run the xolotl simulation, run the functions and evaluate the cost
				[V,Ca] = self.x.integrate;

				% skip some transient
				z = floor(length(V)*self.transient_length);
				V(1:z,:) = [];
				Ca(1:z,:) = [];

				% run functions on this
				n_comp = length(self.x.compartment_names);
				c = zeros(n_comp,length(self.f));
				for i = 1:length(self.f)
					for j = 1:n_comp
						c(j,i) = self.f{i}(V(:,j),Ca(:,j));
					end
				end


				c = (((c - self.targets).^2)./(self.targets.^2)).*self.weights;
				c = sum(c);
				if isnan(c)
					c = Inf;
					break
				end
				C = C + c;
			end
			c = C;

		end

		
		
	end
	function x = fit(self)

		self.x.transpile;
		self.x.compile;

		psoptions = psoptimset('UseParallel',self.use_parallel, 'Vectorized', 'off','Cache','on','CompletePoll','on','Display',self.display_type,'MaxIter',self.nsteps,'MaxFunEvals',self.max_fun_evals,'TolMesh',self.tol_mesh,'TolX',self.tol_x);

		assert(~isempty(self.weights),'Weights cannot be empty')
		assert(length(unique([length(self.f), length(self.targets), length(self.weights)])) == 1, 'Length of targets, weights, and functions should be the same')

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