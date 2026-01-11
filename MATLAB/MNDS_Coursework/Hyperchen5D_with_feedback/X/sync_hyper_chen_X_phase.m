%% Hyper-Chen 5D+FB — FB map(score_end) with time-shift IC (x-only coupling)
clear; close all; clc

%% ================= PARAMETERS =================
TT = 1000;
CT = 50;
y_decim = 1;

% FB
itrs_map = 800;
epsR = 1e-14;

% 4D Hyper-Chen parameters
a = 36; b = 3; c = 28; d = 16; g = 0.2;

% 5D parameters (NEW SYSTEM)
e   = 1.0;     % w damping
rho = 0.5;     % feedback into y: +rho*w

% (your chosen params)
h  = 0.005;
WT = 0.400;
s  = 0.5;

% ===== x-only coupling in 5D =====
Kx = 140.0;
Kf = [Kx; 0; 0; 0; 0];
Kb = Kf;

% Master initial (before transient) 5D
X = [3; 3; 0; 0; 0];

% Time-shift IC for slave (instead of offset)
t_shift = 5.0;    % seconds shift along master trajectory
shift_idx = max(1, round(t_shift / (h*y_decim)));

% Color scale fixed for comparison (like paper)
CAX = [-14 2];

%% ================= TRANSIENT =================
for i = 1:ceil(TT/h)
    X = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
end

%% ================= MASTER TRAJECTORY =================
M = ceil(CT/h/y_decim);
Xwrite = zeros(5, M);
m = 0;

for i = 1:ceil(CT/h)
    X = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
    if mod(i,y_decim) == 0
        m = m + 1;
        Xwrite(:,m) = X;
    end
end
Xwrite = Xwrite(:,1:m);

% for time-shift IC we can only score kk up to m-shift_idx
m_valid = m - shift_idx;
if m_valid < 2
    error('CT too small for chosen t_shift at given h/y_decim. Increase CT or reduce t_shift.');
end

fprintf('time-shift: t_shift=%.3f s -> shift_idx=%d samples, m_valid=%d/%d\n', ...
    t_shift, shift_idx, m_valid, m);

%% ================= FB MAP (score_end) =================
WT_iter = ceil(WT/h);
WT_forward = zeros(5, WT_iter);

score_end = zeros(1, m_valid);

hw = waitbar(0,'Computing FB map (score_end) 5D+FB...');

for kk = 1:m_valid
    waitbar(kk/m_valid, hw, sprintf('%d/%d', kk, m_valid));

    Xc = Xwrite(:,kk);             % master point
    Xs = Xwrite(:,kk + shift_idx); % SLAVE time-shift IC

    % master window
    Xm = Xc;
    for ii = 1:WT_iter
        WT_forward(:,ii) = Xm;
        Xm = hyperchen5fb_step(Xm,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
    end
    WT_backward = fliplr(WT_forward);

    buffer_rms = zeros(1,itrs_map);

    for it = 1:itrs_map
        bn = zeros(1, WT_iter-1);

        for j = 1:(WT_iter-1)
            bn(j) = norm(Xs - WT_forward(:,j)); % 5D norm
            Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho,  h,s, WT_forward(:,j), Kf);
        end
        for j = 1:(WT_iter-1)
            Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho, -h,s, WT_backward(:,j), -Kb);
        end

        buffer_rms(it) = rms(bn);
    end

    rms_safe = max(buffer_rms, epsR);
    s0 = log10(rms_safe(1));
    se = log10(rms_safe(end)) - s0;

    score_end(kk) = min(max(se, CAX(1)), CAX(2));
end
close(hw);

score_end(~isfinite(score_end)) = CAX(2);

%% ================= PLOT (XYZ only) =================
Xw = Xwrite(:,1:m_valid);

figure
surface([Xw(1,:);Xw(1,:)],[Xw(2,:);Xw(2,:)],[Xw(3,:);Xw(3,:)],...
        [score_end;score_end], 'FaceColor','none','EdgeColor','interp','LineWidth',1.2);
xlabel('x'); ylabel('y'); zlabel('z');
colorbar; colormap(turbo); caxis(CAX);
grid on; view(3)
title(sprintf('5D+FB FB map(score\\_end) in x-y-z | h=%.4f WT=%.3f Kx=%.1f | rho=%.2f e=%.2f | shift=%.2fs', ...
    h, WT, Kx, rho, e, t_shift));

%% =================================================================
function Xn = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,S,K)
% Time-symmetric 2-stage step (explicit h1 + semi-implicit h2 reverse),
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

% -------- stage 1 (explicit) --------
x = x + h1*( a*(y - x) + N(1) );
y = y + h1*( -x*z + d*x + c*y - q + rho*w + N(2) );
z = z + h1*( x*y - b*z + N(3) );
q = q + h1*( x + g + N(4) );

% w' = -e*w + x*z
w = w + h1*( -e*w + x*z + N(5) );

% -------- stage 2 (reverse order) --------
% w has -e*w -> implicit
w = ( w + h2*( x*z + N(5) ) ) / (1 + e*h2);

q = q + h2*( x + g + N(4) );
z = ( z + h2*( x*y + N(3) ) ) / (1 + b*h2);

% y has +c*y -> implicit; include feedback rho*w (w already stage2-updated)
y = ( y + h2*( -x*z + d*x - q + rho*w + N(2) ) ) / (1 - c*h2);

x = ( x + h2*( a*y + N(1) ) ) / (1 + a*h2);

Xn = [x; y; z; q; w];
end
