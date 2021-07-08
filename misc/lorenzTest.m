clc; clear; close all;

[x y z] = lorenz(28, 10, 8/3);

% visualize time series under study
figure
plot(x)
title('Lorenz Series [x]')
xlabel('Time')
ylabel('microVolts')

% pause()

% stage 1 obtains mean period and normalize
% x --> time series
% Fs --> Sampling frequency (@ which x was obtained)
stage1 = meanperiod(x, 1/0.001);

% stage 2 obtain mutual information mean
% tau max --> 64
% partitions --> 128 --> Fraser & Swinney Algorithm?
[PIM, tauOpt] = pim(x, 64, 64);

% stage 3 embedding dimension
% returns fnn and embedding dimension
% usage: function [FNN, emb_dim] = knn_deneme(x, tao, mmax, rtol, atol)
% x --> time series
% tauOpt --> optimal tau
% mmax --> maximum embedding dimension (64?)
% rtol --> relative tolerance
[FNN, dim] = knn_deneme(x, tauOpt, 64, 15, 2);

% stage 4 strange attractor reconstruction
M = length(x)-dim*tauOpt;
Y = psr_deneme(x, dim, tauOpt, M);
% Attractor reconstruction plot
figure
plot3(Y(:,1), Y(:,2), Y(:,3))
title("Reconstructed Attractor (Y)")
xlabel('x[k]')
ylabel('x[k + t]')
zlabel('x[k + 2t]')

% stage 5 correlation dimension
% function contains stage 4, but no visualization of this one
% dg: correlation dimension
[dg, C_R, R] = corrdim(x, dim, tauOpt);

% stage 6 largest lyapunov exponent
lle = lyarosenstein(x, dim, tauOpt, 1/0.001000, stage1, 2000);

h = hurstexp(x);
