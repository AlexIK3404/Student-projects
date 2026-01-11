%% Hyper-Chen 5D+FB — FB error vs iteration (TIME-SHIFT IC, with Option B) — w-only coupling
% NEW SYSTEM (variant 1 feedback):
%   x' = a*(y - x)
%   y' = -x*z + d*x + c*y - q + rho*w
%   z' = x*y - b*z
%   q' = x + g
%   w' = -e*w + x*z
%
% Measures RMS error between slave and master WINDOW trajectory
% at each FB iteration (after forward pass), per variable and total.
%
% Slave IC is NOT offset: it is a time-shifted version of master IC:
%   Xs0 = Phi(tau_shift, Xc)
%
% Option A: fixed IC
% Option B: point on attractor (k_pick)

clear; close all; clc

%% ===== SYSTEM & FB PARAMS =====
a=36; b=3; c=28; d=16; g=0.2;

% 5D params
e   = 1.0;   % w damping
rho = 0.5;   % feedback into y: +rho*w

h  = 0.005;
WT = 1.000;
s  = 0.5;

itrs = 100;
epsR = 1e-14;

% ===== w-only coupling (5D) =====
Kw = 10.0;
Kf = [0; 0; 0; 0; Kw];
Kb = Kf;

%% ===== TIME-SHIFT SETTINGS =====
tau_shift = 5.0;                        % time shift (seconds) for slave IC
Nshift    = max(1, round(tau_shift/h)); % steps for the shift

%% ===== PICK ONE MASTER POINT =====
use_optionB = false;  % <<< switch: true = Option B, false = Option A

if ~use_optionB
    %% Option A: fixed IC (5D)
    Xc = [1; 1; 1; 1; 1];

else
    %% Option B: point on attractor (5D)
    TT = 1000;        % transient
    CT = 50;          % collect attractor segment
    y_decim = 1;      % keep smooth
    k_pick = 200;     % which point from the stored segment

    % initial before transient (5D)
    X = [3; 3; 0; 0; 0];

    % transient
    for i=1:ceil(TT/h)
        X = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
    end

    % collect segment
    M = ceil(CT/h/y_decim);
    Xwrite = zeros(5,M); m=0;

    for i=1:ceil(CT/h)
        X = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
        if mod(i,y_decim)==0
            m=m+1;
            Xwrite(:,m)=X;
        end
    end
    Xwrite = Xwrite(:,1:m);

    k = max(1, min(m, k_pick));
    Xc = Xwrite(:,k);

    fprintf('Picked attractor point k=%d: x=%.4f y=%.4f z=%.4f q=%.4f w=%.4f\n', ...
        k, Xc(1),Xc(2),Xc(3),Xc(4),Xc(5));
end

%% ===== SLAVE IC: TIME-SHIFT OF MASTER IC =====
Xs = Xc;
for i=1:Nshift
    Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1)); % free run, no coupling
end

%% ===== BUILD MASTER WINDOW ONCE =====
WT_iter = ceil(WT/h);

W  = zeros(5, WT_iter);
Xm = Xc;
for j = 1:WT_iter
    W(:,j) = Xm;
    Xm = hyperchen5fb_step(Xm,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
end
Wb = fliplr(W);

%% ===== ARRAYS FOR ERROR CURVES =====
RMSx   = zeros(1,itrs);
RMSy   = zeros(1,itrs);
RMSz   = zeros(1,itrs);
RMSq   = zeros(1,itrs);
RMSw   = zeros(1,itrs);
RMSall = zeros(1,itrs);

%% ===== FB ITERATIONS =====
for it = 1:itrs

    % forward pass: record slave trajectory along window
    Xsf = zeros(5, WT_iter-1);

    for j = 1:(WT_iter-1)
        Xsf(:,j) = Xs;  % aligned with W(:,j)
        Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho, h,s, W(:,j), Kf);
    end

    % RMS error over the window (per variable)
    E = Xsf - W(:,1:WT_iter-1);
    RMSx(it) = sqrt(mean(E(1,:).^2));
    RMSy(it) = sqrt(mean(E(2,:).^2));
    RMSz(it) = sqrt(mean(E(3,:).^2));
    RMSq(it) = sqrt(mean(E(4,:).^2));
    RMSw(it) = sqrt(mean(E(5,:).^2));
    RMSall(it)= sqrt(mean(sum(E.^2,1)));

    % backward pass: return slave back along reversed window
    for j = 1:(WT_iter-1)
        Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho, -h,s, Wb(:,j), -Kb);
    end
end

%% ===== PLOT =====
figure
semilogy(max(RMSx,epsR),'LineWidth',1.3); hold on
semilogy(max(RMSy,epsR),'LineWidth',1.3);
semilogy(max(RMSz,epsR),'LineWidth',1.3);
semilogy(max(RMSq,epsR),'LineWidth',1.3);
semilogy(max(RMSw,epsR),'LineWidth',1.3);
semilogy(max(RMSall,epsR),'k--','LineWidth',1.3);
grid on
xlim([1 itrs])
xlabel('FB iteration')
ylabel('RMS error over window (log scale)')
legend('RMS_x','RMS_y','RMS_z','RMS_q','RMS_w','RMS_{all}','Location','southwest')
title(sprintf('5D FB error vs iteration | h=%.4f WT=%.3f Kw=%.1f | shift=%.2fs', ...
    h, WT, Kw, tau_shift))
hold off

%% ===== PRINT FINAL =====
fprintf('Final RMS: x=%.3e y=%.3e z=%.3e q=%.3e w=%.3e all=%.3e\n', ...
    RMSx(end), RMSy(end), RMSz(end), RMSq(end), RMSw(end), RMSall(end));

%% =================================================================
function Xn = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,S,K)
% 5D time-symmetric 2-stage step (explicit h1 + semi-implicit h2 reverse),
% coupling N computed ONCE per step.
%
% NEW SYSTEM:
%   x' = a*(y - x)
%   y' = -x*z + d*x + c*y - q + rho*w
%   z' = x*y - b*z
%   q' = x + g
%   w' = -e*w + x*z

h1 = h*s;
h2 = h*(1-s);

N = K .* (S - X);

x = X(1); y = X(2); z = X(3); q = X(4); w = X(5);

% -------- stage 1 --------
x = x + h1*( a*(y - x) + N(1) );
y = y + h1*( -x*z + d*x + c*y - q + rho*w + N(2) );
z = z + h1*( x*y - b*z + N(3) );
q = q + h1*( x + g + N(4) );
w = w + h1*( -e*w + x*z + N(5) );

% -------- stage 2 (reverse order) --------
w = ( w + h2*( x*z + N(5) ) ) / (1 + e*h2);
q = q + h2*( x + g + N(4) );
z = ( z + h2*( x*y + N(3) ) ) / (1 + b*h2);
y = ( y + h2*( -x*z + d*x - q + rho*w + N(2) ) ) / (1 - c*h2);
x = ( x + h2*( a*y + N(1) ) ) / (1 + a*h2);

Xn = [x; y; z; q; w];
end
