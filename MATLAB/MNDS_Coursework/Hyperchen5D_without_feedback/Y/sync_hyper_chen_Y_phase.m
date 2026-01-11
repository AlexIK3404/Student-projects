%% Hyper-Chen 5D — FB map(score_end) with time-shift IC (y-only coupling)
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

% 5D extra parameter (for w dynamics)
e = 1.0;

% Found best params (from your run)
h  = 0.0025;
WT = 0.300;
s  = 0.5;

% ===== y-only coupling in 5D =====
Ky = 5.0;
Kf = [0; Ky; 0; 0; 0];
Kb = Kf;

% Master initial (before transient) 5D
X = [3; 3; 0; 0; 0];

% Time-shift IC for slave (instead of offset)
t_shift = 5.0;    % seconds shift along master trajectory
shift_idx = max(1, round(t_shift / (h*y_decim)));

% Color scale fixed for comparison (like paper)
CAX = [-14 2];

% Plot controls
plot_all_3D = true;   % все 10 трёхмерных проекций
plot_all_2D = false;  % опционально: все 10 двумерных проекций

%% ================= TRANSIENT =================
for i = 1:ceil(TT/h)
    X = hyperchen5_step(X,a,b,c,d,g,e,h,s,zeros(5,1),zeros(5,1));
end

%% ================= MASTER TRAJECTORY =================
M = ceil(CT/h/y_decim);
Xwrite = zeros(5, M);
m = 0;

for i = 1:ceil(CT/h)
    X = hyperchen5_step(X,a,b,c,d,g,e,h,s,zeros(5,1),zeros(5,1));
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

hw = waitbar(0,'Computing FB map (score_end) 5D...');

for kk = 1:m_valid
    waitbar(kk/m_valid, hw, sprintf('%d/%d', kk, m_valid));

    Xc = Xwrite(:,kk);             % master point
    Xs = Xwrite(:,kk + shift_idx); % SLAVE time-shift IC

    % master window
    Xm = Xc;
    for ii = 1:WT_iter
        WT_forward(:,ii) = Xm;
        Xm = hyperchen5_step(Xm,a,b,c,d,g,e,h,s,zeros(5,1),zeros(5,1));
    end
    WT_backward = fliplr(WT_forward);

    buffer_rms = zeros(1,itrs_map);

    for it = 1:itrs_map
        bn = zeros(1, WT_iter-1);

        for j = 1:(WT_iter-1)
            bn(j) = norm(Xs - WT_forward(:,j)); % 5D norm
            Xs = hyperchen5_step(Xs,a,b,c,d,g,e,  h,s, WT_forward(:,j), Kf);
        end
        for j = 1:(WT_iter-1)
            Xs = hyperchen5_step(Xs,a,b,c,d,g,e, -h,s, WT_backward(:,j), -Kb);
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

%% ================= PLOTS =================
% Use only valid part (where time-shift exists)
Xw = Xwrite(:,1:m_valid);

names  = {'x','y','z','q','w'};
pairs3 = nchoosek(1:5, 3);   % 10 triplets
pairs2 = nchoosek(1:5, 2);   % 10 pairs

% 3D: all combinations
if plot_all_3D
    for r = 1:size(pairs3,1)
        i = pairs3(r,1); j = pairs3(r,2); k = pairs3(r,3);

        figure
        surface([Xw(i,:);Xw(i,:)],[Xw(j,:);Xw(j,:)],[Xw(k,:);Xw(k,:)],...
                [score_end;score_end], 'FaceColor','none','EdgeColor','interp','LineWidth',1.2);

        xlabel(names{i}); ylabel(names{j}); zlabel(names{k});
        colorbar; colormap(turbo); caxis(CAX);
        grid on; view(3)

        title(sprintf('5D FB map(score\\_end) in %s-%s-%s | h=%.4f WT=%.3f Ky=%.1f | shift=%.2fs', ...
            names{i}, names{j}, names{k}, h, WT, Ky, t_shift));
    end
else
    % default: xyz only
    figure
    surface([Xw(1,:);Xw(1,:)],[Xw(2,:);Xw(2,:)],[Xw(3,:);Xw(3,:)],...
            [score_end;score_end], 'FaceColor','none','EdgeColor','interp','LineWidth',1.2);

    xlabel('x'); ylabel('y'); zlabel('z');
    colorbar; colormap(turbo); caxis(CAX);
    grid on; view(3)

    title(sprintf('5D FB map(score\\_end) in x-y-z | h=%.4f WT=%.3f Ky=%.1f | shift=%.2fs', ...
        h, WT, Ky, t_shift));
end

% 2D: optional, colored scatter
if plot_all_2D
    for r = 1:size(pairs2,1)
        i = pairs2(r,1); j = pairs2(r,2);

        figure
        scatter(Xw(i,:), Xw(j,:), 8, score_end, 'filled');
        xlabel(names{i}); ylabel(names{j});
        colorbar; colormap(turbo); caxis(CAX);
        grid on

        title(sprintf('5D FB map(score\\_end) in %s-%s | h=%.4f WT=%.3f Ky=%.1f | shift=%.2fs', ...
            names{i}, names{j}, h, WT, Ky, t_shift));
    end
end

%% =================================================================
function Xn = hyperchen5_step(X,a,b,c,d,g,e,h,s,S,K)
% Time-symmetric 2-stage step (explicit h1 + semi-implicit h2 reverse),
% coupling N computed ONCE per step.

h1 = h*s;
h2 = h*(1-s);

N = K .* (S - X);

x = X(1); y = X(2); z = X(3); q = X(4); w = X(5);

% stage 1
x = x + h1*( a*(y - x) + N(1) );
y = y + h1*( -x*z + d*x + c*y - q + N(2) );
z = z + h1*( x*y - b*z + N(3) );
q = q + h1*( x + g + N(4) );

% ---- 5D MODIFICATION (CHANGE THIS if your model differs) ----
% w' = -e*w + x*z
w = w + h1*( -e*w + x*z + N(5) );

% stage 2 (reverse order)
w = ( w + h2*( x*z + N(5) ) ) / (1 + e*h2);

q = q + h2*( x + g + N(4) );
z = ( z + h2*( x*y + N(3) ) ) / (1 + b*h2);
y = ( y + h2*( -x*z + d*x - q + N(2) ) ) / (1 - c*h2);
x = ( x + h2*( a*y + N(1) ) ) / (1 + a*h2);

Xn = [x; y; z; q; w];
end
