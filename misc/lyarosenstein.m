function lle=lyarosenstein(x,m,tao,fs,meanperiod,maxiter)
  % d: divergence of nearest trajectories
  % x: signal
  % tao: time delay
  % m: embedding dimension
  % fs: sampling frequency
  % Copyright(c) 2012, mirwais
  % All rights reserved.
  % Created by: Mirwais
  % Modifications by: Walther Carballo Hernández (2015)
  N = length(x);
  M = N-(m-1)*tao;
  Y = psr_deneme(x,m,tao);
  % Obtaining nearest distances
  for i=1:M
    x0 = ones(M,1)*Y(i,:);
    distance = sqrt(sum((Y-x0).^2,2));
    for j=1:M
      if abs(j-i)<=meanperiod
        distance(j) = 1e10;
      end
    end
    [neardis(i) nearpos(i)]=min(distance);
  end

  % Obtaining log of divergence
  for k=1:maxiter
    maxind = M-k;
    evolve = 0;
    pnt = 0;
    for j=1:M
      if j<= maxind && nearpos(j) <= maxind
        dist_k = sqrt(sum((Y(j + k, :) - Y(nearpos(j) + k, :)).^2, 2));
        if dist_k ~= 0
          evolve = evolve + log(dist_k);
          pnt = pnt + 1;
        end
      end
    end
    if pnt>0
      d(k) = evolve/pnt;
    else
      d(k) = 0;
    end
  end

  % figure
  % plot(d)


  % % LLE Calculation
  % tlinear = 1:1500;
  tlinear = 10:90;
  F = polyfit(tlinear,d(tlinear),1);
  lle = F(1)*fs;
  % % Plot the results
  %
  % figure
  % y = F(1)*d + F(2);
  % % hold on
  % % plot(d, y, '--')
  % % plot(y)
  % plot(d)
  % title('Largest Lyapunov Exponent divergence');
  % xlabel('Drive cycles');
  % ylabel('LLE');
end
