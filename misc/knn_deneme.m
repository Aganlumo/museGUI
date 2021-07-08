function [FNN, emb_dim] = knn_deneme(x, tao, mmax, rtol, atol)
  % x: time series
  % tao: time delay
  % mmax: maximum embedding dimension
  % reference: M.B.Kennel, R.Brown, and H.D.I. Abarbanel,
  % Determining embedding dimension for phase-space reconstruction
  % using a geometrical construction, Phys. Rev. A 45, 3403 (1992).
  % modified by: Walther Carballo Hernández (2015)

  % rtol = 15
  % atol = 2;
  N = length(x);
  % Standard deviation
  Ra = std(x, 1);
  emb_dim = 0;

  % Compute the FNN with each m iteration
  for m = 1:mmax
    M = N-m*tao;
    % Reconstruct the attractor
    Y = psr_deneme(x, m, tao, M);
    FNN(m, 1) = 0;
    % Each iteration calculates the distance from one point
    % in the attractor with other point in the space state
    for n = 1:M
      y0 = ones(M, 1)*Y(n, :);
      % Obtaining the distance vector
      distance = sqrt(sum((Y-y0).^2,2));
      % Sorting the distance vector
      [neardis nearpos] = sort(distance);
      % Obtaining absolut evalue
      D = abs(x(n + m*tao) - x(nearpos(2) + m*tao));
      % Obtaining square root
      R = sqrt(D.^2 + neardis(2).^2);
      if (D/neardis(2) > rtol || R/Ra > atol)
        FNN(m,1) = FNN(m,1) + 1;
      end
    end
    if (FNN(m,1) / FNN(1,1))*100<0.05
      emb_dim = m;
      break
    end
  end
  % Calculating embedding dimension
  if emb_dim == 0
    min_indexes = find(FNN(:, 1) == min(FNN(:,1)));
    emb_dim = min_indexes(1, 1);
  end
  % Percentage of the FNN
  FNN = (FNN./FNN(1,1))*100;
  % % Plot results
  % figure
  % plot(1:length(FNN), FNN)
  % title('Minimum embedding dimension with false nearest neighbours')
  % xlabel('Embedding dimension')
  % ylabel('The percentage of false nearest neighbours')
end
