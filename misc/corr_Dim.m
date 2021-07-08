function dg = corr_Dim(x, optau, m)

    M = length(x);
    N = M - optau*m;

    Y = psr_deneme(x,m,optau);
    R_min = 1000;
    R_max = 0;

    dist_vector = zeros(1, (N^2) - N);
    n=1;

    for i=1:length(Y)
        for j=1:length(Y)
            if i~=j
                R_estimate = norm(Y(i,:) - Y(j,:));  % norm --> euclidean length
                if R_estimate < R_min
                    R_min = R_estimate;
                end
                if R_estimate > R_max;
                    R_max = R_estimate;
                end
                n = n+1;
            end
        end
    end

end
