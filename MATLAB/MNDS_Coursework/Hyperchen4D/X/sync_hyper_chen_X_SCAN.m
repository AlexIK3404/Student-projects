%% Hyper-Chen — FB phase map (x-only) + GRID SEARCH over (h, WT, Kx)
% System:
%   x' = a (y - x)
%   y' = -x z + d x + c y - q
%   z' = x y - b z
%   q' = x + g
%
% Integrator: symmetric 2-stage (explicit h1 forward order + semi-implicit h2 reverse order),
% with coupling N = K.*(S - X) computed ONCE per step (keeps time-symmetry).
%
% Outputs:
%   - Finds best (h, WT, Kx) for x-only coupling by maximizing "strong capture" fraction
%   - Plots full phase maps for score_min and score_end using the best params
%
% Notes:
%   - score_min  = min_i [log10(rms_i) - log10(rms_1)]  (shows "it captured at least once")
%   - score_end  = log10(rms_end) - log10(rms_1)        (strict, may stay near 0 for hyperchaos)
%   - Robust to log10(0) and NaN/Inf via epsilon clamp + isfinite cleanup

clear; close all; clc

%% ================= BASE PARAMETERS =================
TT = 1000;          % transient time
CT = 50;            % computation time to cover attractor (increase to 100..200 if you can)
s  = 0.5;           % symmetry coefficient
y_decim = 5;        % master decimation
itrs_search = 800;  % FB iterations during grid search (speed)
itrs_full   = 800; % FB iterations for final full map (quality)
use_points  = 80;   % number of attractor points to score in search (speed/coverage)

% Hyper-Chen parameters (YOUR system)
a = 36;
b = 3;
c = 28;
d = 16;
g = 0.2;

% Initial condition for master (before transient)
X0 = [3; 3; 0; 0];

% Epsilon for safe logs
epsR = 1e-14;

%% ================= GRID TO SEARCH (x-only coupling) =================
h_list  = [0.001 0.0025 0.005];
WT_list = [0.15 0.18 0.22 0.25 0.28 0.3 0.35 0.4];
Kx_list = [2 5 6.5 10 15 20 30 40 60 80 100];

% Threshold for "strong capture" in score_min
% score_min < -3 => at least 10^3 reduction at some iteration
strong_thr = -3;

%% ================= PRECOMPUTE MASTER TRAJECTORY FOR EACH h =================
% We'll store master trajectories per h to avoid recomputing in inner loops.
masterTraj = struct();  % masterTraj(i).h, .Xwrite, .idx

for ih = 1:numel(h_list)
    h = h_list(ih);

    % transient
    X = X0;
    for i = 1:ceil(TT/h)
        X = hyperchen_step(X,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
    end

    % master trajectory
    M = ceil(CT/h/y_decim);
    Xwrite = zeros(4, M);
    m = 0;
    for i = 1:ceil(CT/h)
        X = hyperchen_step(X,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
        if mod(i,y_decim) == 0
            m = m + 1;
            Xwrite(:,m) = X;
        end
    end
    Xwrite = Xwrite(:,1:m);

    idx = round(linspace(1,m,min(use_points,m)));

    masterTraj(ih).h = h;
    masterTraj(ih).Xwrite = Xwrite;
    masterTraj(ih).idx = idx;
end

%% ================= GRID SEARCH =================
best.metric = -Inf;
best.h = NaN; best.WT = NaN; best.Kx = NaN;
best.fracStrong = NaN; best.medMin = NaN;

results = []; % [h WT Kx fracStrong medMin medEnd fracEndNeg]

fprintf('Grid search: %d h * %d WT * %d Kx = %d configs\n', ...
    numel(h_list), numel(WT_list), numel(Kx_list), numel(h_list)*numel(WT_list)*numel(Kx_list));

for ih = 1:numel(h_list)
    h = h_list(ih);
    Xwrite = masterTraj(ih).Xwrite;
    idx = masterTraj(ih).idx;

    for WT = WT_list
        WT_iter = ceil(WT/h);
        if WT_iter < 8
            continue
        end

        WT_forward = zeros(4, WT_iter);

        for Kx = Kx_list
            Kf = [Kx; 0; 0; 0];
            Kb = Kf;  % start symmetric for x-only

            scoreMin = nan(1,numel(idx));
            scoreEnd = nan(1,numel(idx));

            for t = 1:numel(idx)
                k = idx(t);
                Xc = Xwrite(:,k);
                Xs = Xc + [5;5;5;5];

                % build master window
                Xm = Xc;
                for ii = 1:WT_iter
                    WT_forward(:,ii) = Xm;
                    Xm = hyperchen_step(Xm,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
                end
                WT_backward = fliplr(WT_forward);

                buffer_rms = zeros(1, itrs_search);

                for it = 1:itrs_search
                    bn = zeros(1, WT_iter-1);

                    % forward
                    for j = 1:(WT_iter-1)
                        bn(j) = norm(Xs - WT_forward(:,j));
                        Xs = hyperchen_step(Xs,a,b,c,d,g, h,s, WT_forward(:,j), Kf);
                    end
                    % backward
                    for j = 1:(WT_iter-1)
                        Xs = hyperchen_step(Xs,a,b,c,d,g, -h,s, WT_backward(:,j), -Kb);
                    end

                    buffer_rms(it) = rms(bn);
                end

                rms_safe = max(buffer_rms, epsR);
                s0 = log10(rms_safe(1));

                scEnd = log10(rms_safe(end)) - s0;
                scMin = min(log10(rms_safe) - s0);

                % clip for robustness
                scEnd = min(max(scEnd, -20), 5);
                scMin = min(max(scMin, -20), 5);

                scoreEnd(t) = scEnd;
                scoreMin(t) = scMin;
            end

            fracStrong = mean(scoreMin < strong_thr, 'omitnan');
            medMin     = median(scoreMin, 'omitnan');
            medEnd     = median(scoreEnd, 'omitnan');
            fracEndNeg = mean(scoreEnd < 0, 'omitnan');

            results(end+1,:) = [h WT Kx fracStrong medMin medEnd fracEndNeg]; %#ok<SAGROW>

            % Metric: prioritize having many strongly-captured points,
            % then better (more negative) median min-score
            metric = fracStrong*10 + (-medMin);

            if metric > best.metric
                best.metric = metric;
                best.h = h; best.WT = WT; best.Kx = Kx;
                best.fracStrong = fracStrong;
                best.medMin = medMin;
                fprintf('BEST: h=%.4f WT=%.3f Kx=%.1f | strong=%.2f medMin=%.2f medEnd=%.2f endNeg=%.2f\n', ...
                    h,WT,Kx,fracStrong,medMin,medEnd,fracEndNeg);
            end
        end
    end
end

fprintf('\nBest found: h=%.4f WT=%.3f Kx=%.1f | strong=%.2f medMin=%.2f\n', ...
    best.h, best.WT, best.Kx, best.fracStrong, best.medMin);

%% ================= FULL MAP WITH BEST PARAMS =================
h  = best.h;
WT = best.WT;
Kx = best.Kx;

% get corresponding master trajectory for this h
ih = find(abs([masterTraj.h] - h) < 1e-12, 1);
Xwrite = masterTraj(ih).Xwrite;
m = size(Xwrite,2);

Kf = [Kx; 0; 0; 0];
Kb = Kf;

WT_iter = ceil(WT/h);
WT_forward = zeros(4, WT_iter);

score_end = zeros(1,m);
score_min = zeros(1,m);

hw = waitbar(0,'Computing full phase maps...');

for k = 1:m
    waitbar(k/m, hw, sprintf('%d/%d',k,m));

    Xc = Xwrite(:,k);
    Xs = Xc + [5;5;5;5];

    % build window
    Xm = Xc;
    for ii = 1:WT_iter
        WT_forward(:,ii) = Xm;
        Xm = hyperchen_step(Xm,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
    end
    WT_backward = fliplr(WT_forward);

    buffer_rms = zeros(1, itrs_full);

    for it = 1:itrs_full
        bn = zeros(1, WT_iter-1);

        for j = 1:(WT_iter-1)
            bn(j) = norm(Xs - WT_forward(:,j));
            Xs = hyperchen_step(Xs,a,b,c,d,g, h,s, WT_forward(:,j), Kf);
        end
        for j = 1:(WT_iter-1)
            Xs = hyperchen_step(Xs,a,b,c,d,g, -h,s, WT_backward(:,j), -Kb);
        end

        buffer_rms(it) = rms(bn);
    end

    rms_safe = max(buffer_rms, epsR);
    s0 = log10(rms_safe(1));

    se = log10(rms_safe(end)) - s0;
    sm = min(log10(rms_safe) - s0);

    score_end(k) = min(max(se, -20), 5);
    score_min(k) = min(max(sm, -20), 5);
end
close(hw);

% cleanup
score_end(~isfinite(score_end)) = 5;
score_min(~isfinite(score_min)) = 5;

%% ================= PLOTS =================
% score_min map (more informative for hyperchaos)
figure
surface([Xwrite(1,:);Xwrite(1,:)],[Xwrite(2,:);Xwrite(2,:)],[Xwrite(3,:);Xwrite(3,:)],...
        [score_min;score_min], 'FaceColor','none','EdgeColor','interp','LineWidth',1.3);
xlabel('x'); ylabel('y'); zlabel('z');
colorbar; colormap(turbo);
caxis([-14 2]); grid on; view(3)
title(sprintf('FB map (score\\_min), h=%.4f WT=%.3f Kx=%.2f', h, WT, Kx))

% score_end map (strict)
figure
surface([Xwrite(1,:);Xwrite(1,:)],[Xwrite(2,:);Xwrite(2,:)],[Xwrite(3,:);Xwrite(3,:)],...
        [score_end;score_end], 'FaceColor','none','EdgeColor','interp','LineWidth',1.3);
xlabel('x'); ylabel('y'); zlabel('z');
colorbar; colormap(turbo);
caxis([-14 2]); grid on; view(3)
title(sprintf('FB map (score\\_end), h=%.4f WT=%.3f Kx=%.2f', h, WT, Kx))

%% ================= SHOW TOP CONFIGS =================
[~,ord] = sort(results(:,5), 'ascend'); % sort by medMin (more negative is better)
topN = min(15, size(results,1));
disp('Top configs sorted by medMin: [h WT Kx fracStrong medMin medEnd fracEndNeg]');
disp(results(ord(1:topN),:));

%% =================================================================
%% ================= SYMMETRIC STEP FOR YOUR SYSTEM =================
%% =================================================================
function Xn = hyperchen_step(X,a,b,c,d,g,h,s,S,K)
% Time-symmetric 2-stage step (explicit h1 + semi-implicit h2 reverse),
% with coupling N computed ONCE per step to preserve time symmetry.

h1 = h*s;
h2 = h*(1-s);

N = K .* (S - X);

x = X(1); y = X(2); z = X(3); q = X(4);

% Stage 1 (explicit, x y z q)
x = x + h1*( a*(y - x) + N(1) );
y = y + h1*( -x*z + d*x + c*y - q + N(2) );
z = z + h1*( x*y - b*z + N(3) );
q = q + h1*( x + g + N(4) );

% Stage 2 (reverse, q z y x)
q = q + h2*( x + g + N(4) );                            % q' = x + g
z = ( z + h2*( x*y + N(3) ) ) / (1 + b*h2);             % z' = xy - b z
y = ( y + h2*( -x*z + d*x - q + N(2) ) ) / (1 - c*h2);  % y' = ... + c y
x = ( x + h2*( a*y + N(1) ) ) / (1 + a*h2);             % x' = a(y-x)

Xn = [x; y; z; q];
end
