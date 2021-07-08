function H=hurstexp(x)
  % Computing of Hurstexponent
  % x: time series
  % Created by: Walther Carballo Hernández

  % Length of the time series
  N = length(x);

  % Maximal 2-factors divisions of the time series
  max_divisions = round(log(N)/log(2));
  lnH_n = zeros(1, max_divisions);
  lnn = zeros(1, max_divisions);
  % for each division obtain the rescaled range
  for k=1:max_divisions
    n = round(N/(2^(k-1)));
    if (n==1)
      break;
    end
    lnn(k)=log(n);
    % Divide the time series
    X = x(1:n);
    % Obtaining the mean of the new time series
    m = mean(X);
    % Adjusting the time series to the mean
    Y = X-m;
    Z = zeros(1,n);
    R = 0;
    S = 0;
    sum = 0;
    % Computing the cumulative deviate series
    for t=1:n
      for i=1:t
        sum = sum + Y(i);
      end
      Z(t) = sum;
      sum = 0;
    end
    % Obtaining the range of the deviate series
    R = range(Z);
    % Computing standard deviation
    for i=1:n
      sum = sum + ((X(i)-m)^2);
    end
    S = sqrt((sum)/n);
    % Computing the results of rescaled range and store them
    if (isnan(log(R/S)))
      lnH_n(k) = 0;
    else
      lnH_n(k) = log(R/S);
    end
  end

  % Linear approximation
  coefficients = polyfit(lnn, lnH_n, 1);
  H = coefficients(1);
  % Plot results
  y = coefficients(1)*lnn + coefficients(2);
  % figure;
  % hold on;
  % plot(lnn, y, '--');
  % plot(lnn, lnH_n);
  % title('ln(H(R/S)) vs ln(n)');
  % xlabel('ln(n)');
  % ylabel('ln(H(R/S))');
end
