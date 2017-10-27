function [F, y, e] = APA(F, x, d)
%Implements the LMS adaptive filter algorithm
%   F = filter struct
%	x = filter input signal
%	d = desired filter output

F.x(2:F.L) = F.x(1:F.L-1);					% shift input
F.x(1) = x;										% load new input
for i = 2:F.P									% shift X
	F.X(i-1,1:F.L) = F.X(i,1:F.L); 
end
F.X(1,1:F.L) = F.x(1:F.L);						% load new vector into X 
F.d(2:F.P) = F.d(1:F.P-1);						% shift desired output
F.d(1) = d ;									% load new desired output 
        
yy = F.X*F.w;									% get output vector
ee = F.d-yy;									% error vector
F.w = F.w + F.mu*(F.X'/(F.dI + F.X*F.X'))*ee;	% compute APA update
y = yy(1);										% output  sample
e = ee(1);										% error sample

end