function [dg,C_R,R] = corrdim(x, m, tau)
  % Correlation dimension based on Grassberger-Procaccia algorithm (1983)
  % dg: Correlation dimension
  % C_R: Vector of contribution of the points
  %     in the Radius R(size = (R_max - R_min/R_step) + 1)
  % R: Vector of radius(same size as C_R)
  % x: Time series
  % m: Embedded dimension
  % tau: Time delay
  % R_initial: Initial radius of the n-dimensional sphere (i.e. 0.3)
  % R_step: Increments of the radius(i.e. 0.1)
  % R_max: Max radius(-1 R_step) of the n-dimensional sphere
  %
  % Created by: Walther Carballo Hernández

  N = length(x);
  M = N - (m-1)*tau;
  % Attractor reconstruction
  Y = psr_deneme(x, m, tau);
  R_min = 1000;
  R_max = 0;
  % Distance vector between all the points size of N^2 - N
  dist_vec = zeros(1, ((N^2)-N));
  n = 1;
  % Estimating R_min and R_max
  for i=1:length(Y)                       % for each point
    for j=1:length(Y)                     % Compare with the other points
      if i~=j                             % if it's not the same point
      R_estimate = norm(Y(i,:)-Y(j,:));
      dist_vec(n) = R_estimate;
        if R_estimate<R_min               % Estimate min radius
          R_min = R_estimate;
        end
        if R_estimate>R_max               % Estimate max radius
          R_max = R_estimate;
        end
        n = n + 1;
      end
    end
  end
  % Range of the Radius ignore and 40% of the max radius
  R_range = 0.2*(R_max-R_min);
  R_max = R_max-2*R_range;
  if R_min == 0
    R_min = 1.0000e-06;% Solve some cases of NaN in R and C_R vectors
  end

  % Calculate step of the radius increase in the linear zone of 10 divisions
  R_step = (R_max-R_min)/10;
  R = R_min;
  C_R = zeros(1, floor(((R_max-R_min)/R_step) + 1));
  n = 1;
  sum = 0;

  % Obtaining C(R) vector
  while R <= R_max + 1                 % R_init tends to R_max in steps of R_step
    % for each distance in the distance vector
    for i=1:length(dist_vec)
      % if it's contained in the radius
      if dist_vec(i)<R
        % Add 1 to the counter
        sum = sum + 1;
      end
    end
    % C_R calculation
    C_R(n) = (2/(M*(M-1)))*sum;
    % Next step for the Radius
    R = R + R_step;
    sum = 0;
    n = n + 1;
  end
  % Calculate ln(C(R)) and ln(R)
  R = (R_min:R_step:R_max);
  lnC_R = log(C_R);
  lnR = log(R);
  % Calculate dg
  coefficients = polyfit(lnR(2:length(lnR) - 5), lnC_R(2:length(lnC_R) - 5), 1);
  % coefficients = polyfit(lnR(1:length(lnR) - 0), lnC_R(1:length(lnC_R) - 0), 1);
  dg = coefficients(1);
  % % Plot results
  % y = coefficients(1)*lnR + coefficients(2);
  % figure
  % hold on;
  % plot(lnR, y, '--');
  % plot(lnR, lnC_R);
  % title('ln(C(R)) vs ln(R)');
  % xlabel('ln(R)');
  % ylabel('ln(C(R))');
end
