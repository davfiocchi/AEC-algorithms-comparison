function [F] =  create_struct_APA(L, P, mu, delta)
%creates the struct for APA
%   L = length of the filter
%   P = length of the considered vectors ( =1 for NLMS, RLS, LMS)
%   mu = step size
%   delta = regularization factor (for NLMS and APA)

x  = zeros(L,1);    % input vector
X = zeros(P,L);     % matrix of the last P input vector
d = zeros(P,1);     % vector of the last P desired outputs
w  = zeros(L,1);    % w AF taps
dI = delta*eye(P);  % Regularizing diagonal matrix

F = struct('L',L,'P',P,'mu',mu,'dI',dI,'w',w,'x',x,'X',X,'delta',delta,'d',d);
end


