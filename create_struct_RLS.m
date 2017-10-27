function [F] =  create_struct_RLS(L,mu0,k)
%creates the struct for RLS (third form)
%   L = length of the filter
%   lambda = forgetting factor 

phi = zeros (L,1); %regression (input) vector 
theta = zeros (L,1); % AF taps

delta = 1e-2;
V = (1.0/delta)*eye(L);

MSE_length = 100;
MSE_prev = zeros(MSE_length,1);
MSE_act = zeros(MSE_length,1);

F = struct('L',L,'w',theta,'x',phi,'mu0',mu0,'V',V,'k',k,'defaultV',V,'MSE_prev',MSE_prev,'MSE_act',MSE_act,'MSE_length',MSE_length,'count',1);
end
