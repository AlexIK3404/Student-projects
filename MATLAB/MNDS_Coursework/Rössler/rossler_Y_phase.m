%% Rössler — FB map(score_end)
% Rössler:
%   x' = -y - z
%   y' =  x + a*y
%   z' =  b + z*(x - c)
%
% Paper-like settings (from the article text/captions):
%   a=0.2, b=0.2, c=5.7
%   h=0.01
%   WT=1 s
%   K=5 (y-coupling)
%   slave IC = master state shifted by +5 seconds (time-shift)

clear; close all; clc

%% ===== Simulation (trajectory for map) =====
TT = 1000;
CT = 2000;
y_decim = 1;   % smooth map

%% ===== FB settings =====
itrs_map = 300;
epsR = 1e-14;
CAX  = [-14 2];

%% ===== Rössler params (paper) =====
a = 0.2;
b = 0.2;
c = 5.7;

h  = 0.01;
WT = 1.0;

% y-only coupling (paper)
Kf = [0; 2; 0];
Kb = [0; 10; 0];

% master IC (paper)
X = [3; -3; 0];

% slave is taken from master trajectory at +5 seconds (paper)
use_time_shift = true;
t_shift = 5.0;  % seconds

% fallback if you want old "offset vector" method
slave_offset = [5; 5; 5];

%% ===== Transient =====
for i = 1:ceil(TT/h)
    X = rossler_step_cd(X,a,b,c,h,0.5,[0;0;0],[0;0;0]); % no coupling in master
end

%% ===== Master trajectory =====
M = ceil(CT/h/y_decim);
Xwrite = zeros(3,M);  m = 0;

for i = 1:ceil(CT/h)
    X = rossler_step_cd(X,a,b,c,h,0.5,[0;0;0],[0;0;0]); % no coupling
    if mod(i,y_decim)==0
        m = m+1;
        Xwrite(:,m) = X;
    end
end
Xwrite = Xwrite(:,1:m);

%% ===== FB map(score_end) =====
WT_iter = ceil(WT/h);
Wf = zeros(3, WT_iter);

score_end = zeros(1,m);

% time shift in indices (because y_decim=1, one sample per step)
shift_idx = round(t_shift / (h*y_decim));

hw = waitbar(0,'Computing Rössler FB map (score_end)...');

for kk = 1:m
    waitbar(kk/m, hw, sprintf('%d/%d', kk, m));

    Xc = Xwrite(:,kk);

    % --- slave initial condition (paper) ---
    if use_time_shift
        kk2 = min(m, kk + shift_idx);
        Xs = Xwrite(:,kk2);
    else
        Xs = Xc + slave_offset;
    end

    % build master window from Xc
    Xm = Xc;
    for ii = 1:WT_iter
        Wf(:,ii) = Xm;
        Xm = rossler_step_cd(Xm,a,b,c,h,0.5,[0;0;0],[0;0;0]);
    end
    Wb = fliplr(Wf);

    buffer_rms = zeros(1,itrs_map);

    for it = 1:itrs_map
        bn = zeros(1, WT_iter-1);

        % forward sync
        for j = 1:(WT_iter-1)
            bn(j) = norm(Xs - Wf(:,j));
            Xs = rossler_step_cd(Xs,a,b,c, h,0.5, Wf(:,j), Kf);
        end

        % backward sync
        for j = 1:(WT_iter-1)
            Xs = rossler_step_cd(Xs,a,b,c, -h,0.5, Wb(:,j), -Kb);
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

%% ===== Plot =====
figure
surface([Xwrite(1,:);Xwrite(1,:)], [Xwrite(2,:);Xwrite(2,:)], [Xwrite(3,:);Xwrite(3,:)], ...
        [score_end;score_end], ...
        'FaceColor','none','EdgeColor','interp','LineWidth',1.2);

xlabel('x'); ylabel('y'); zlabel('z');
colormap(turbo); colorbar;
caxis(CAX);
grid on; view(3);
title(sprintf('R\\ddot{o}ssler FB map(score\\_end), h=%.3f WT=%.1f K+=%.1f K-=%.1f itrs=%d', h, WT, Kf(2), Kb(2), itrs_map));

%% =================================================================
function Xn = rossler_step_cd(X,a,b,c,h,s,S,K)
% 2-stage symmetric step (like your Hyper-Chen code style)
% Coupling: N = K .* (S - X), typically only on y

h1 = h*s;
h2 = h*(1-s);

N = K .* (S - X);

x = X(1); y = X(2); z = X(3);

% ---- stage 1 (explicit) ----
x = x + h1*( -y - z + N(1) );
y = y + h1*(  x + a*y + N(2) );
z = z + h1*(  b + z*(x - c) + N(3) );

% ---- stage 2 (reverse, semi-implicit where it makes sense) ----
% z: solve z_new = z + h2*(b + z_new*(x - c) + N3)
den = (1 - h2*(x - c));
if abs(den) < 1e-12
    % avoid blow-up at rare singularity, fallback to explicit
    z = z + h2*( b + z*(x - c) + N(3) );
else
    z = ( z + h2*( b + N(3) ) ) / den;
end

% y: implicit for linear a*y: y_new = y + h2*(x + a*y_new + N2)
den = (1 - a*h2);
if abs(den) < 1e-12
    y = y + h2*( x + a*y + N(2) );
else
    y = ( y + h2*( x + N(2) ) ) / den;
end

% x: explicit (no x self-term)
x = x + h2*( -y - z + N(1) );

Xn = [x; y; z];
end
