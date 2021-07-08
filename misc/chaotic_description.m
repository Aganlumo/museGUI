function [PIM, optau, FNN, dim, dg, lle, h, s] = chaotic_description(x, fs)
    mp = meanperiod(x, fs);
    [PIM, optau] = pim(x, 64, 128);
    [FNN, dim] = knn_deneme(x, optau, 64, 15, 2);
    [dg, C_R, R] = corrdim(x, dim, optau);
    lle = lyarosenstein(x, dim, optau, fs, mp, 100);
    h = hurstexp(x);
    s = approximateEntropy(x);
end
