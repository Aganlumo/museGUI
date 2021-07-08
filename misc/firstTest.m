clc; clear; close all;

fileName = 'F\\F001.txt';
fileID = fopen(fileName, 'r');
formatSpec = '%f';
x = fscanf(fileID, formatSpec);

% visualize time series under study
figure
plot(x)
title(fileName)
xlabel('Time')
ylabel('microVolts')


% stage 1 obtains mean period and normalize
% x --> time series
% Fs --> Sampling frequecy (@ which x was obtained)
stage1 = meanperiod(x, 173.61);

% stage 2 obtain mutual information mean
% tau max --> 64
% partitions --> 128 --> Fraser & Swinney Algorithm?
[PIM, tauOpt] = pim(x, 64, 128);

% stage 3 embedding dimension
% returns fnn and embedding dimension
% usage: function [FNN, emb_dim] = knn_deneme(x, tao, mmax, rtol, atol)
% x --> time series
% tauOpt --> optimal tau
% mmax --> maximum embedding dimension (64?)
% rtol --> relative tolerance
[FNN, dim] = knn_deneme(x, tauOpt, 64, 15, 2);
% dim = 6;
% stage 4 strange attractor reconstruction
M = length(x)-dim*tauOpt;
Y = psr_deneme(x, dim, tauOpt, M);
% % Time series delay Plot
% x_k = [x; zeros(2*tauOpt, 1)];
% x_kt = [zeros(tauOpt, 1); x; zeros(tauOpt, 1)];
% x_k2t = [zeros(2*tauOpt,1 ); x];
% figure(5)
% plot3(x_k, x_kt, x_k2t)
% title("Reconstructed Attractor (zero padding)")
% xlabel('x[k]')
% ylabel('x[k + t]')
% zlabel('x[k + 2t]')

figure(5)
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
lle = lyarosenstein(x, dim, tauOpt, 173.61, stage1, 100);

h = hurstexp(x);

% s = approximateEntropy(x, tauOpt, dim);
s = approximateEntropy(x);
