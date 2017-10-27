function [F, y, e] = NLMS(F, x, d)
%Implements the LMS adaptive filter algorithm
%   F = filter struct
%	x = filter input signal
%	d = desired filter output

F.x(2 : F.L) = F.x(1 : F.L-1);			% shift input
F.x(1) = x;								% load new input  
P = F.x'*F.x;							% compute signal power
y = F.w'*F.x;							% get output
e = d - y;								% error
F.w = F.w + F.mu*(e'*F.x)/(P+F.delta);	% compute NLMS update 

end