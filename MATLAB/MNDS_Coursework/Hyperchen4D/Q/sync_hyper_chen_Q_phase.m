%% Hyper-Chen — FB map(score_end) (q-only)
clear; close all; clc

%% ================= PARAMETERS =================
TT = 1000;
CT = 50;
y_decim = 1;

% FB
itrs_map  = 800;
epsR = 1e-14;

% Hyper-Chen parameters
a = 36; b = 3; c = 28; d = 16; g = 0.2;

% Found good params (from your grid search)
h  = 0.0010;
WT = 0.400;
s  = 0.5;

% q-only coupling
Kq = 5.0;
Kf = [0; 0; 0; Kq];
Kb = Kf;

% Master initial (before transient)
X = [3; 3; 0; 0];

% Slave offset
slave_offset = [5;5;5;5];

% Color scale fixed for comparison (like paper)
CAX = [-14 2];

%% ================= TRANSIENT =================
for i = 1:ceil(TT/h)
    X = hyperchen_step(X,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
end

%% ================= MASTER TRAJECTORY =================
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

%% ================= FB MAP (score_end) =================
WT_iter = ceil(WT/h);
WT_forward = zeros(4, WT_iter);

score_end = zeros(1, m);

hw = waitbar(0,'Computing FB map (score_end)...');

for kk = 1:m
    waitbar(kk/m, hw, sprintf('%d/%d', kk, m));

    Xc = Xwrite(:,kk);
    Xs = Xc + slave_offset;

    % master window
    Xm = Xc;
    for ii = 1:WT_iter
        WT_forward(:,ii) = Xm;
        Xm = hyperchen_step(Xm,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
    end
    WT_backward = fliplr(WT_forward);

    buffer_rms = zeros(1,itrs_map);

    for it = 1:itrs_map
        bn = zeros(1, WT_iter-1);

        % forward
        for j = 1:(WT_iter-1)
            bn(j) = norm(Xs - WT_forward(:,j));
            Xs = hyperchen_step(Xs,a,b,c,d,g,  h,s, WT_forward(:,j), Kf);
        end
        % backward
        for j = 1:(WT_iter-1)
            Xs = hyperchen_step(Xs,a,b,c,d,g, -h,s, WT_backward(:,j), -Kb);
        end

        buffer_rms(it) = rms(bn);
    end

    rms_safe = max(buffer_rms, epsR);
    s0 = log10(rms_safe(1));
    se = log10(rms_safe(end)) - s0;

    % clamp for stable plotting but keep paper range meaningful
    score_end(kk) = min(max(se, CAX(1)), CAX(2));
end
close(hw);

score_end(~isfinite(score_end)) = CAX(2);

%% ================= PLOT MAP =================
figure
surface([Xwrite(1,:);Xwrite(1,:)],[Xwrite(2,:);Xwrite(2,:)],[Xwrite(3,:);Xwrite(3,:)],...
        [score_end;score_end], 'FaceColor','none','EdgeColor','interp','LineWidth',1.2);
xlabel('x'); ylabel('y'); zlabel('z');
colorbar; colormap(turbo);
caxis(CAX); grid on; view(3)
title(sprintf('FB map (score\\_end), h=%.4f WT=%.3f Kq=%.1f', h, WT, Kq))

%% =================================================================
function Xn = hyperchen_step(X,a,b,c,d,g,h,s,S,K)
h1 = h*s;
h2 = h*(1-s);

N = K .* (S - X);

x = X(1); y = X(2); z = X(3); q = X(4);

% stage 1
x = x + h1*( a*(y - x) + N(1) );
y = y + h1*( -x*z + d*x + c*y - q + N(2) );
z = z + h1*( x*y - b*z + N(3) );
q = q + h1*( x + g + N(4) );

% stage 2
q = q + h2*( x + g + N(4) );
z = ( z + h2*( x*y + N(3) ) ) / (1 + b*h2);
y = ( y + h2*( -x*z + d*x - q + N(2) ) ) / (1 - c*h2);
x = ( x + h2*( a*y + N(1) ) ) / (1 + a*h2);

Xn = [x; y; z; q];
end
