% procrustes is a toolbox that attempts
% to change parameters in a Xolotl object
% so that it fits some arbitrary set of conditions

classdef procrustes

properties
	x@xolotl
	weights

	f@cell 
	targets


	parameter_names@cell
	seed
	lb
	ub

	use_cache = true
	purge_cache = false
	use_parallel = true
	nsteps = 300;
	display_type = 'iter';
	max_fun_evals = 2e4;
	minimise_r2 = false;
	engine = 'patternsearch';
	tol_mesh = 1e-6;
	tol_x = 1e-6;


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


	function c = evaluate(self,x)
		% update parameters in the xolotl object using x

		for i = 1:length(self.parameter_names)
			eval(['self.x.' self.parameter_names{i} '= x(' mat2str(i) ');'])
			% is there a way around this eval? I don't think so
		end

		% run the xolotl simulation, run the functions and evaluate the cost
		V = self.x.integrate;

		% run functions on this
		c = zeros(1,length(self.f));
		for i = 1:length(self.f)
			c(i) = self.f{i}(V);
		end
		c = sum(((c - self.targets).*self.weights).^2);

		
		
	end
	function x = fit(self)

		psoptions = psoptimset('UseParallel',self.use_parallel, 'Vectorized', 'off','Cache','on','CompletePoll','on','Display',self.display_type,'MaxIter',self.nsteps,'MaxFunEvals',self.max_fun_evals,'TolMesh',self.tol_mesh,'TolX',self.tol_x);

		assert(~isempty(self.weights),'Weights cannot be empty')

		x = patternsearch(@(x) self.evaluate(x),self.seed,[],[],[],[],self.lb,self.ub,psoptions);

	end



end % end methods


end % end classdef