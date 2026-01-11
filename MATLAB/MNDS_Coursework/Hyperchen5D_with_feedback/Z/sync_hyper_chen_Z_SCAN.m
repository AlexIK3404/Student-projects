%% Hyper-Chen 5D (with feedback) — FB phase map (z-only) + GRID SEARCH over (h, WT, Kz)
% 5D MODIFICATION (feedback):
%   x' = a*(y - x)
%   y' = -x*z + d*x + c*y - q + rho*w
%   z' = x*y - b*z
%   q' = x + g
%   w' = -e*w + x*z
%
% Integrator: symmetric 2-stage (explicit h1 forward order + semi-implicit h2 reverse order),
% coupling N = K.*(S - X) computed ONCE per step (time-symmetric style).
%
% IC: TIME-SHIFT (slave starts from master trajectory shifted by t_shift)

clear; close all; clc

%% ================= BASE PARAMETERS =================
TT = 1000;          % transient time
CT = 50;            % computation time (attractor coverage)
s  = 0.5;           % symmetry coefficient
y_decim = 5;        % master decimation
itrs_search = 800;  % FB iterations during grid search
itrs_full   = 800;  % FB iterations for final maps
use_points  = 80;   % number of attractor points to score in search

epsR = 1e-14;       % for safe logs

% ===== 5D Hyper-Chen parameters (4D + extra e + feedback rho) =====
a = 36;
b = 3;
c = 28;
d = 16;
g = 0.2;

e   = 1.0;          % w linear damping
rho = 0.5;          % feedback strength: y gets +rho*w

% Initial condition for master (before transient) 5D
X0 = [3; 3; 0; 0; 0];

% TIME-SHIFT settings (slave IC)
t_shift = 5.0;      % seconds shift along master trajectory (recommended: 1..10)

% Plot color scale fixed for comparisons
CAX = [-14 2];

%% ================= GRID TO SEARCH (z-only coupling) =================
h_list  = [0.0025 0.005];
WT_list = [0.15 0.18 0.22 0.25 0.28 0.30 0.35 0.40 0.50 0.60 0.80 1.00];
Kz_list = [2.5 5 10 15 20 30 40 60 80 100 120 140 160 200];

strong_thr = -3;    % score_min < -3 => at least 1e3 drop at some iter

%% ================= PRECOMPUTE MASTER TRAJECTORY FOR EACH h =================
masterTraj = struct();  % .h, .Xwrite, .idx, .shift_idx, .m_valid

for ih = 1:numel(h_list)
    h = h_list(ih);

    % transient
    X = X0;
    for i = 1:ceil(TT/h)
        X = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
    end

    % master trajectory
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

    % shift in samples (trajectory index space)
    shift_idx = max(1, round(t_shift / (h*y_decim)));

    % only points where k+shift_idx exists
    m_valid = m - shift_idx;
    if m_valid < 2
        error('CT too small for chosen t_shift at h=%.4f. Increase CT or reduce t_shift.', h);
    end

    idx = round(linspace(1, m_valid, min(use_points, m_valid)));

    masterTraj(ih).h = h;
    masterTraj(ih).Xwrite = Xwrite;
    masterTraj(ih).idx = idx;
    masterTraj(ih).shift_idx = shift_idx;
    masterTraj(ih).m_valid = m_valid;
end

%% ================= GRID SEARCH =================
best.metric = -Inf;
best.h = NaN; best.WT = NaN; best.Kz = NaN;
best.fracStrong = NaN; best.medMin = NaN;

results = []; % [h WT Kz fracStrong medMin medEnd fracEndNeg]

fprintf('Grid search: %d h * %d WT * %d Kz = %d configs\n', ...
    numel(h_list), numel(WT_list), numel(Kz_list), numel(h_list)*numel(WT_list)*numel(Kz_list));

for ih = 1:numel(h_list)
    h = masterTraj(ih).h;
    Xwrite = masterTraj(ih).Xwrite;
    idx = masterTraj(ih).idx;
    shift_idx = masterTraj(ih).shift_idx;

    for WT = WT_list
        WT_iter = ceil(WT/h);
        if WT_iter < 8
            continue
        end

        WT_forward = zeros(5, WT_iter);

        for Kz = Kz_list
            % z-only coupling in 5D
            Kforward  = [0; 0; Kz; 0; 0];
            Kbackward = Kforward; % keep equal

            scoreMin = nan(1,numel(idx));
            scoreEnd = nan(1,numel(idx));

            for t = 1:numel(idx)
                k = idx(t);

                Xc = Xwrite(:,k);
                Xs = Xwrite(:,k + shift_idx); % TIME-SHIFT IC (slave)

                % build master window from Xc
                Xm = Xc;
                for ii = 1:WT_iter
                    WT_forward(:,ii) = Xm;
                    Xm = hyperchen5fb_step(Xm,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
                end
                WT_backward = fliplr(WT_forward);

                buffer_rms = zeros(1, itrs_search);

                for it = 1:itrs_search
                    bn = zeros(1, WT_iter-1);

                    % forward
                    for j = 1:(WT_iter-1)
                        bn(j) = norm(Xs - WT_forward(:,j)); % 5D norm
                        Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho, h,s, WT_forward(:,j), Kforward);
                    end
                    % backward (paper style: -h and -Kbackward)
                    for j = 1:(WT_iter-1)
                        Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho, -h,s, WT_backward(:,j), -Kbackward);
                    end

                    buffer_rms(it) = rms(bn);
                end

                rms_safe = max(buffer_rms, epsR);
                s0 = log10(rms_safe(1));

                scEnd = log10(rms_safe(end)) - s0;
                scMin = min(log10(rms_safe) - s0);

                scEnd = min(max(scEnd, -20), 5);
                scMin = min(max(scMin, -20), 5);

                scoreEnd(t) = scEnd;
                scoreMin(t) = scMin;
            end

            fracStrong = mean(scoreMin < strong_thr, 'omitnan');
            medMin     = median(scoreMin, 'omitnan');
            medEnd     = median(scoreEnd, 'omitnan');
            fracEndNeg = mean(scoreEnd < 0, 'omitnan');

            results(end+1,:) = [h WT Kz fracStrong medMin medEnd fracEndNeg]; %#ok<SAGROW>

            metric = fracStrong*10 + (-medMin);
            if metric > best.metric
                best.metric = metric;
                best.h = h; best.WT = WT; best.Kz = Kz;
                best.fracStrong = fracStrong;
                best.medMin = medMin;
                fprintf('BEST: h=%.4f WT=%.3f Kz=%.1f | strong=%.2f medMin=%.2f medEnd=%.2f endNeg=%.2f | rho=%.3f e=%.3f\n', ...
                    h,WT,Kz,fracStrong,medMin,medEnd,fracEndNeg,rho,e);
            end
        end
    end
end

fprintf('\nBest found: h=%.4f WT=%.3f Kz=%.1f | strong=%.2f medMin=%.2f | rho=%.3f e=%.3f\n', ...
    best.h, best.WT, best.Kz, best.fracStrong, best.medMin, rho, e);

%% ================= FULL MAP WITH BEST PARAMS =================
h  = best.h;
WT = best.WT;
Kz = best.Kz;

ih = find(abs([masterTraj.h] - h) < 1e-12, 1);
Xwrite = masterTraj(ih).Xwrite;
shift_idx = masterTraj(ih).shift_idx;
m_valid = masterTraj(ih).m_valid;

Kforward  = [0; 0; Kz; 0; 0];
Kbackward = Kforward;

WT_iter = ceil(WT/h);
WT_forward = zeros(5, WT_iter);

score_end = zeros(1,m_valid);
score_min = zeros(1,m_valid);

hw = waitbar(0,'Computing full phase maps (5D+feedback time-shift IC)...');

for k = 1:m_valid
    waitbar(k/m_valid, hw, sprintf('%d/%d',k,m_valid));

    Xc = Xwrite(:,k);
    Xs = Xwrite(:,k + shift_idx); % TIME-SHIFT IC

    % build window
    Xm = Xc;
    for ii = 1:WT_iter
        WT_forward(:,ii) = Xm;
        Xm = hyperchen5fb_step(Xm,a,b,c,d,g,e,rho,h,s,zeros(5,1),zeros(5,1));
    end
    WT_backward = fliplr(WT_forward);

    buffer_rms = zeros(1, itrs_full);

    for it = 1:itrs_full
        bn = zeros(1, WT_iter-1);

        for j = 1:(WT_iter-1)
            bn(j) = norm(Xs - WT_forward(:,j));
            Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho, h,s, WT_forward(:,j), Kforward);
        end
        for j = 1:(WT_iter-1)
            Xs = hyperchen5fb_step(Xs,a,b,c,d,g,e,rho, -h,s, WT_backward(:,j), -Kbackward);
        end

        buffer_rms(it) = rms(bn);
    end

    rms_safe = max(buffer_rms, epsR);
    s0 = log10(rms_safe(1));

    se = log10(rms_safe(end)) - s0;
    sm = min(log10(rms_safe) - s0);

    score_end(k) = min(max(se, CAX(1)), CAX(2));
    score_min(k) = min(max(sm, CAX(1)), CAX(2));
end
close(hw);

score_end(~isfinite(score_end)) = CAX(2);
score_min(~isfinite(score_min)) = CAX(2);

%% ================= PLOTS (xyz projection; w affects dynamics + norm) =================
Xw = Xwrite(:,1:m_valid);

figure
surface([Xw(1,:);Xw(1,:)],[Xw(2,:);Xw(2,:)],[Xw(3,:);Xw(3,:)],...
        [score_min;score_min], 'FaceColor','none','EdgeColor','interp','LineWidth',1.2);
xlabel('x'); ylabel('y'); zlabel('z');
colorbar; colormap(turbo); caxis(CAX);
grid on; view(3)
title(sprintf('5D+FB FB map(score\\_min) | time-shift IC | h=%.4f WT=%.3f Kz=%.1f | rho=%.3f e=%.3f', ...
    h, WT, Kz, rho, e))

figure
surface([Xw(1,:);Xw(1,:)],[Xw(2,:);Xw(2,:)],[Xw(3,:);Xw(3,:)],...
        [score_end;score_end], 'FaceColor','none','EdgeColor','interp','LineWidth',1.2);
xlabel('x'); ylabel('y'); zlabel('z');
colorbar; colormap(turbo); caxis(CAX);
grid on; view(3)
title(sprintf('5D+FB FB map(score\\_end) | time-shift IC | h=%.4f WT=%.3f Kz=%.1f | rho=%.3f e=%.3f', ...
    h, WT, Kz, rho, e))

%% ================= SHOW TOP CONFIGS =================
[~,ord] = sort(results(:,5), 'ascend'); % by medMin
topN = min(15, size(results,1));
disp('Top configs sorted by medMin: [h WT Kz fracStrong medMin medEnd fracEndNeg]');
disp(results(ord(1:topN),:));

%% =================================================================
function Xn = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,S,K)
% 5D symmetric 2-stage step, coupling computed once per step
% Feedback: y' includes +rho*w

h1 = h*s;
h2 = h*(1-s);

N = K .* (S - X);

x = X(1); y = X(2); z = X(3); q = X(4); w = X(5);

% ===== Stage 1 (explicit order: x y z q w) =====
x = x + h1*( a*(y - x) + N(1) );
y = y + h1*( -x*z + d*x + c*y - q + rho*w + N(2) );
z = z + h1*( x*y - b*z + N(3) );
q = q + h1*( x + g + N(4) );

% w' = -e*w + x*z
w = w + h1*( -e*w + x*z + N(5) );

% ===== Stage 2 (reverse order: w q z y x) =====
w = ( w + h2*( x*z + N(5) ) ) / (1 + e*h2);
q = q + h2*( x + g + N(4) );
z = ( z + h2*( x*y + N(3) ) ) / (1 + b*h2);
y = ( y + h2*( -x*z + d*x - q + rho*w + N(2) ) ) / (1 - c*h2);
x = ( x + h2*( a*y + N(1) ) ) / (1 + a*h2);

Xn = [x; y; z; q; w];
end
