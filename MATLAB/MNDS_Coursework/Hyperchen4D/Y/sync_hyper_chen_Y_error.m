%% Hyper-Chen — FB error vs iteration
% Measures RMS error between slave and master WINDOW trajectory
% at each FB iteration (after forward pass), per variable and total.

clear; close all; clc

%% ===== SYSTEM & FB PARAMS (use your best) =====
a=36; b=3; c=28; d=16; g=0.2;

h  = 0.0025;
WT = 0.250;
s  = 0.5;

itrs = 100;
epsR = 1e-14;

% y-only coupling
Ky = 30;
Kf = [0; Ky; 0; 0];
Kb = Kf;

%% ===== PICK ONE MASTER POINT (either from attractor or fixed IC) =====
% Option A: fixed IC (simple / reproducible)
Xc = [1; 1; 1; 1];

% Option B: point on attractor (uncomment to use)
% TT = 1000; CT = 50; y_decim = 1;  % heavy if y_decim=1
% X = [3;3;0;0];
% for i=1:ceil(TT/h), X = hyperchen_step(X,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]); end
% M = ceil(CT/h/y_decim); Xwrite=zeros(4,M); m=0;
% for i=1:ceil(CT/h)
%     X = hyperchen_step(X,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
%     if mod(i,y_decim)==0, m=m+1; Xwrite(:,m)=X; end
% end
% Xwrite=Xwrite(:,1:m);
% k=200; k=max(1,min(m,k));
% Xc=Xwrite(:,k);

% slave initial (offset)
Xs = Xc + [5;5;5;5];

%% ===== BUILD MASTER WINDOW ONCE =====
WT_iter = ceil(WT/h);

W = zeros(4, WT_iter);
Xm = Xc;
for j = 1:WT_iter
    W(:,j) = Xm;
    Xm = hyperchen_step(Xm,a,b,c,d,g,h,s,[0;0;0;0],[0;0;0;0]);
end
Wb = fliplr(W);

%% ===== ARRAYS FOR ERROR CURVES =====
RMSx = zeros(1,itrs);
RMSy = zeros(1,itrs);
RMSz = zeros(1,itrs);
RMSq = zeros(1,itrs);
RMSall = zeros(1,itrs);

%% ===== FB ITERATIONS =====
for it = 1:itrs

    % forward pass: record slave trajectory along window
    Xsf = zeros(4, WT_iter-1);

    for j = 1:(WT_iter-1)
        Xsf(:,j) = Xs;  % slave state aligned with W(:,j)
        Xs = hyperchen_step(Xs,a,b,c,d,g, h,s, W(:,j), Kf);
    end

    % compute RMS error over the window (per variable)
    E = Xsf - W(:,1:WT_iter-1);
    RMSx(it) = sqrt(mean(E(1,:).^2));
    RMSy(it) = sqrt(mean(E(2,:).^2));
    RMSz(it) = sqrt(mean(E(3,:).^2));
    RMSq(it) = sqrt(mean(E(4,:).^2));
    RMSall(it)= sqrt(mean(sum(E.^2,1))); % total RMS (Euclidean per sample then mean)

    % backward pass: return slave back along reversed window
    for j = 1:(WT_iter-1)
        Xs = hyperchen_step(Xs,a,b,c,d,g, -h,s, Wb(:,j), -Kb);
    end
end

%% ===== PLOT (like classmates) =====
figure
semilogy(max(RMSx,epsR),'LineWidth',1.3); hold on
semilogy(max(RMSy,epsR),'LineWidth',1.3);
semilogy(max(RMSz,epsR),'LineWidth',1.3);
semilogy(max(RMSq,epsR),'LineWidth',1.3);
semilogy(max(RMSall,epsR),'k--','LineWidth',1.3);
grid on
xlim([1 itrs])
xlabel('FB iteration')
ylabel('RMS error over window (log scale)')
legend('RMS_x','RMS_y','RMS_z','RMS_q','RMS_{all}','Location','southwest')
title(sprintf('Hyper-Chen FB error vs iteration (WT=%.3f, h=%.4f, Ky=%.1f)', WT, h, Ky))
hold off

%% ===== OPTIONAL: print final errors =====
fprintf('Final RMS: x=%.3e y=%.3e z=%.3e q=%.3e all=%.3e\n', ...
    RMSx(end), RMSy(end), RMSz(end), RMSq(end), RMSall(end));

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
