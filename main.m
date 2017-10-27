clear;
close all;
clc;

disp('AEC Compare algorithm demo');


n_IR = 4;
manip = 1;
voice = 0;

disp('load input file...');
if voice==1
	[x,fs] = audioread('this is the water.wav');
	Lx = floor(size(x,1)/4);				% number of samples	
else
	Lx = 80000;
	x = randn(Lx,1);
	fs = 48000;
end

%% Parameters
L = 200;							% Filter length
P = 20;								% number of considered vector for APA
k = 0.9;							% constant trace of S for RLS
delta = 1e-2;						% regularization term for NLMS and APA 
mu0 = 1;                 		    % RLS minimum forgetting factor (=1 -> plain RLS)

mu = [0.0005,1.0,1.0,mu0];			% Learning rate


%% Target
disp('load impulse responses...');
RIR_path = fullfile(pwd,'air_database_release_1_4','AIR_1_4');
addpath(RIR_path);
airpar1 = struct('fs',fs,'rir_type',2,'mock_up_type',1,'room',2,'channel',0,'phone_pos',2,'azimuth',90);
airpar2 = struct('fs',fs,'rir_type',2,'mock_up_type',1,'room',3,'channel',0,'phone_pos',2,'azimuth',90);
airpar3 = struct('fs',fs,'rir_type',2,'mock_up_type',1,'room',4,'channel',0,'phone_pos',2,'azimuth',90);
airpar4 = struct('fs',fs,'rir_type',2,'mock_up_type',1,'room',9,'channel',0,'phone_pos',2,'azimuth',90);

[h1,air_info] = load_air(airpar1);	% office impulse response
[h2,air_info] = load_air(airpar2);	% meeting impulse response
[h3,air_info] = load_air(airpar3);	% lecture impulse response
[h4,air_info] = load_air(airpar4);	% bathroom impulse response

begin = 68;

if manip == 1
	fin = 400;

	h1 = h1(begin:fin)/max(h1);
	h2 = h2(begin:fin)/max(h2);
	h3 = h3(begin:fin)/max(h3);
	h4 = h4(begin:fin)/max(h4);
else
	h1 = h1(begin:end);
	h2 = h2(begin:end);
	h3 = h3(begin:end);
	h4 = h4(begin:end);
end
%% Desired response
disp('calculate desired response...');

if n_IR==1	% single impulse response
	d = conv(x,h1);
	sL = Lx;
else		% multiple impulse response
	d = zeros(size(x));
	sL = floor(Lx/4);	%segment length
	d1 = conv(x(1:sL),h1);
	d2 = conv(x(sL+1:2*sL),h2);
	d3 = conv(x(2*sL+1:3*sL),h3);
	d4 = conv(x(3*sL+1:end),h4);

	d(1:sL) = d1(1:sL);
	d(sL+1:2*sL) = d2(1:sL);
	d(2*sL+1:3*sL) = d3(1:sL);
	d(3*sL+1:4*sL) = d4(1:sL);
end

%% Filter definition
F1 = create_struct_LMS(L, mu(1,1));				% LMS 
F2 = create_struct_NLMS(L, mu(1,2), delta);		% NLMS
F3 = create_struct_APA(L, P, mu(1,3), delta);	% APA
F4 = create_struct_RLS(L, mu0(1,1), k);			% RLS

% initialization 
e1  = zeros(Lx,1);  % error LMS
e2  = zeros(Lx,1);  % error NLMS
e3  = zeros(Lx,1);  % error APA
e4  = zeros(Lx,1);  % error RLS
em1 = zeros(Lx,1);  % mean error LMS 
em2 = zeros(Lx,1);  % mean error NLMS  
em3 = zeros(Lx,1);  % mean error APA 
em4 = zeros(Lx,1);  % mean error RLS

%% Main loop
disp('AEC Compare algorithm start ...');

for n = 1 : size(mu,1)
    fprintf('Test with mu_LMS=%f, mu_NLMS=%f, mu_APA=%f, mu0_RLS=%f\n', mu(n,1), mu(n,2), mu(n,3), mu(n,4));
       
    % Filters initialization --------------------------------------------
    F1.w (:)  = 0;  F1.w  (1) = 1; F1.mu = mu(n,1);			% Set filter 1 i.c.
    F2.w (:)  = 0;  F2.w  (1) = 1; F2.mu = mu(n,2);			% Set filter 2 i.c.
    F3.w (:)  = 0;  F3.w  (1) = 1; F3.mu = mu(n,3);			% Set filter 3 i.c.
    F4.w (:)  = 0;  F4.w  (1) = 0;							% Set filter 4 i.c.
        
    % Adaptive filtering ----------------------------------------------
	
    for t = 1 : Lx
		if mod(t,sL)==0
			display(['Analized ', num2str(t), '/', num2str(Lx), ' input samples...'])
			%F4.V = F4.defaultV;
		end
		[F1, y1, e1(t)] =  LMS(F1, x(t), d(t) );	% LMS
		[F2, y2, e2(t)] =  NLMS(F2, x(t), d(t) );	% NLMS      
		[F3, y3, e3(t)] =  APA(F3, x(t), d(t) );	% APA
		[F4, y4, e4(t)] =  RLS(F4, x(t), d(t) );	% RLS
    end
    em1  = em1 + (e1.^2);
    em2  = em2 + (e2.^2);
    em3  = em3 + (e3.^2);
    em4  = em4 + (e4.^2);
end

em1  = em1/length(mu);
em2  = em2/length(mu);
em3  = em3/length(mu);
em4  = em4/length(mu);

%% Plot
disp('Display values');

t = (1:Lx)/fs;
maxMSE = max([em1;em2;em3;em4]);

% MSE
figure
subplot(2,2,1)
plot(t,em1,'-k');
axis([1/fs Lx/fs 0 maxMSE])
yL=get(gca,'ylim');
line([sL sL]/fs,ylim,'LineStyle',':')
line(2*[sL sL]/fs,ylim,'LineStyle',':')
line(3*[sL sL]/fs,ylim,'LineStyle',':')
xlabel('time [seconds]')
title('MSE for LMS')
subplot(2,2,2)
plot(t,em2,'-r');
axis([1/fs Lx/fs 0 maxMSE])
yL=get(gca,'ylim');
line([sL sL]/fs,ylim,'LineStyle',':')
line(2*[sL sL]/fs,ylim,'LineStyle',':')
line(3*[sL sL]/fs,ylim,'LineStyle',':')
xlabel('time [seconds]')
title('MSE for NLMS')
subplot(2,2,3)
plot(t,em3,'-g');
axis([1/fs Lx/fs 0 maxMSE])
yL=get(gca,'ylim');
line([sL sL]/fs,ylim,'LineStyle',':')
line(2*[sL sL]/fs,ylim,'LineStyle',':')
line(3*[sL sL]/fs,ylim,'LineStyle',':')
xlabel('time [seconds]')
title('MSE for APA')
subplot(2,2,4)
plot(t,em4,'-b');
axis([1/fs Lx/fs 0 maxMSE])
yL=get(gca,'ylim');
line([sL sL]/fs,ylim,'LineStyle',':')
line(2*[sL sL]/fs,ylim,'LineStyle',':')
line(3*[sL sL]/fs,ylim,'LineStyle',':')
xlabel('time [seconds]')
title('MSE for RLS')

% Normalized MSE
figure
title('Normalized MSE for LMS,NLMS,APA,RLS');
hold on;hold('all');
plot(1:Lx,em1/max(em1),'-k');
plot(1:Lx,em2/max(em2),'-r');
plot(1:Lx,em3/max(em3),'-g');
plot(1:Lx,em4/max(em4),'--c');
yL=get(gca,'ylim');
line([sL sL],ylim,'LineStyle',':')
line(2*[sL sL],ylim,'LineStyle',':')
line(3*[sL sL],ylim,'LineStyle',':')
legend('LMS','NLMS','APA','RLS')


figure
plot(t,em2-em3)
title('Difference between NLMS and APA')
yL=get(gca,'ylim');
line([sL sL],ylim,'LineStyle',':')
line(2*[sL sL],ylim,'LineStyle',':')
line(3*[sL sL],ylim,'LineStyle',':')
axis([1/fs Lx/fs -1 1])
axis 'auto y'
xlabel('time [seconds]')

% figure 
% plot(d)

