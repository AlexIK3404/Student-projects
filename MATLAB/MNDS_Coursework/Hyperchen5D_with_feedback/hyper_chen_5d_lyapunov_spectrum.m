%% Lyapunov spectrum for Hyper-Chen 5D + feedback (variant 1)
% System:
%   x' = a (y - x)
%   y' = -x z + d x + c y - q + rho w
%   z' = x y - b z
%   q' = x + g
%   w' = -e w + x z
%
% Lyapunov spectrum computed for the *discrete-time one-step map* produced
% by hyperchen5fb_step (finite-difference Jacobian + QR / Benettin).
%
% IMPORTANT: this matches your integrator exactly.

clear; close all; clc

%% ===== Parameters (same as your FB scripts) =====
a=36; b=3; c=28; d=16; g=0.2;
e   = 1.0;   % w damping
rho = 0.5;   % feedback into y: +rho*w

h  = 0.005;
s  = 0.5;

% trajectory times
TT = 1000;   % transient to reach attractor
LT = 100;    % time length for Lyapunov averaging (increase for stability)

% initial condition
X = [3;3;0;0;0];

%% ===== Lyapunov settings =====
dim = 5;
eps_fd = 1e-7;        % finite-difference step for Jacobian of one-step map
qr_every = 1;         % QR each step (safe); can set 5..20 to speed up a bit

% coupling off for Lyapunov (natural system)
S0 = zeros(5,1);
K0 = zeros(5,1);

%% ===== Transient =====
Ntr = ceil(TT/h);
for n = 1:Ntr
    X = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,S0,K0);
end

%% ===== Main Lyapunov loop =====
N = ceil(LT/h);

Q = eye(dim);
le_sum = zeros(dim,1);

% optional: track convergence
le_hist = zeros(dim, N);

for n = 1:N

    % one-step base
    X1 = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,S0,K0);

    % finite-difference Jacobian of the one-step map F at X
    % A(:,i) = (F(X + eps*e_i) - F(X))/eps
    A = zeros(dim,dim);
    for i = 1:dim
        dX = zeros(dim,1);
        dX(i) = eps_fd;
        Xi = X + dX;
        Fi = hyperchen5fb_step(Xi,a,b,c,d,g,e,rho,h,s,S0,K0);
        A(:,i) = (Fi - X1) / eps_fd;
    end

    % advance base state
    X = X1;

    % propagate tangent vectors
    Z = A * Q;

    % QR re-orthonormalization (can be done every qr_every steps)
    if mod(n, qr_every) == 0
        [Q,R] = qr(Z,0);
        le_sum = le_sum + log(abs(diag(R)));
    else
        Q = Z; % if skipping QR, Q grows; not recommended unless you implement block-QR
    end

    % convergence history (current estimate)
    t = n*h;
    le_hist(:,n) = le_sum / (t);  % note: if qr_every>1 and you skip QR, this is wrong
end

% final Lyapunov exponents (per unit time)
lyap = le_sum / (N*h);

%% ===== Output =====
fprintf('Lyapunov spectrum (dim=%d), h=%.4g, LT=%.2f:\n', dim, h, LT);
for i=1:dim
    fprintf('  L%d = %+ .6f\n', i, lyap(i));
end
fprintf('Sum(L) = %+ .6f\n', sum(lyap));

% hyperchaos check: number of positive exponents
fprintf('Positive count: %d\n', sum(lyap > 0));

%% ===== Plots =====
figure
bar(lyap);
grid on
xlabel('index')
ylabel('Lyapunov exponent')
title(sprintf('Lyapunov spectrum (LT=%.1f, h=%.4g, rho=%.2f, e=%.2f)', LT, h, rho, e))

figure
plot((1:N)*h, le_hist','LineWidth',1.1);
grid on
xlabel('time')
ylabel('running estimate of Lyapunov exponents')
title('Convergence of Lyapunov exponents (running averages)')
legend('L1','L2','L3','L4','L5','Location','best')

%% =================================================================
function Xn = hyperchen5fb_step(X,a,b,c,d,g,e,rho,h,s,S,K)
% 5D time-symmetric 2-stage step (explicit h1 + semi-implicit h2 reverse),
% coupling N computed ONCE per step.
%
% NEW SYSTEM:
%   y' = -x*z + d*x + c*y - q + rho*w
%   w' = -e*w + x*z

h1 = h*s;
h2 = h*(1-s);

N = K .* (S - X);

x = X(1); y = X(2); z = X(3); q = X(4); w = X(5);

% ---- stage 1 ----
x = x + h1*( a*(y - x) + N(1) );
y = y + h1*( -x*z + d*x + c*y - q + rho*w + N(2) );
z = z + h1*( x*y - b*z + N(3) );
q = q + h1*( x + g + N(4) );
w = w + h1*( -e*w + x*z + N(5) );

% ---- stage 2 (reverse) ----
w = ( w + h2*( x*z + N(5) ) ) / (1 + e*h2);
q = q + h2*( x + g + N(4) );
z = ( z + h2*( x*y + N(3) ) ) / (1 + b*h2);
y = ( y + h2*( -x*z + d*x - q + rho*w + N(2) ) ) / (1 - c*h2);
x = ( x + h2*( a*y + N(1) ) ) / (1 + a*h2);

Xn = [x; y; z; q; w];
end
