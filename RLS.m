function [F, y, e] = RLS(F, x, d)
%Implements the LMS adaptive filter algorithm
%   F = filter struct
%	x = filter input signal
%	d = desired filter output

F.x(2:F.L) = F.x(1:F.L-1);								% shift input    
F.x(1) = x;												% load new input
y = F.w'*F.x;											% get output
e = d - y;												% error


F.MSE_prev(2:F.MSE_length)=F.MSE_prev(1:F.MSE_length-1);
F.MSE_prev(1)=F.MSE_act(F.MSE_length);

F.MSE_act(2:F.MSE_length)=F.MSE_act(1:F.MSE_length-1);
F.MSE_act(1)=e^2;


% if mod(F.count, F.MSE_length)==0
% 	mean_act = mean(F.MSE_act);
% 	mean_prev = mean(F.MSE_prev);
% 	if (mean_act/mean_prev)>100000
% 		F.V = F.defaultV;
% 	else
% 		mu = max(F.mu0, 1-((norm(F.x)^2)/F.k));				% anti-burst remedies
% 
% 		beta = mu + F.x'*F.V*F.x;							% beta
% 		F.V = (1/mu)*(F.V-(1/beta)*F.V*F.x*F.x'*F.V');		% auxiliary recursion
% 	end
% else
	mu = max(F.mu0, 1-((norm(F.x)^2)/F.k));				% anti-burst remedies

	beta = mu + F.x'*F.V*F.x;							% beta
	F.V = (1/mu)*(F.V-(1/beta)*F.V*F.x*F.x'*F.V');		% auxiliary recursion
%end

F.count = F.count+1;
K = F.V*F.x;											% gain

F.w = F.w + K*e;										% compute RLS update

end