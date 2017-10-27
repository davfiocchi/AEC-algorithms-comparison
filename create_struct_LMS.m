function [ F ] = create_struct_LMS(L, mu)
%creates the structfor LMS 
%   L = length of the filter
%   mu = step size

x  = zeros(L,1);    % input vector
w  = zeros(L,1);    % w AF taps

F = struct('L',L,'mu',mu,'w',w,'x',x);
end

