% this function is an example of something that you 
% would feed to Procrustes to optimize. 
% within this function, you can run arbitrary commands
% on xolotl objects, and measure whatever you want,
% and even vary parameters on the object. 
% as long as this returns a cost, it's all good. 

function C = example_func(x,data)

inf_cost = 1e3;
C = inf_cost;

V = x.integrate;

M = procrustes.V2matrix(V,[-80 50],[-20 30]);

C = 1e3*procrustes.matrixCost(data.LeMassonMatrix,M);


