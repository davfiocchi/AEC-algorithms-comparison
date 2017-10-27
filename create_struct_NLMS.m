function [F] =  create_struct_NLMS(L, mu, delta)
%creates the struct for NLMS
%   L = length of the filter
%   mu = step size
%   delta = regularization factor (for NLMS and APA)

x  = zeros(L,1);    % input vector
w  = zeros(L,1);    % w AF taps

F = struct('L',L,'mu',mu,'w',w, 'delta',delta,'x',x);
end

