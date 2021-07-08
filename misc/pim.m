% [PIM,TauOpt] = pim(serie, taumax, particiones)
% e.g.taumax = 64; particiones = 128;
% Devuelve la grafica de I(x_n,x_{n + Tau})
% y el valor optimo de retraso
function [PIM,TauOpt] = pim(serie, taumax, particiones)
  % Normalizacion de la serie
  serie = (serie - min(serie))/(max(serie) - min(serie));
  N = length(serie);
  PIM = ami(serie, 1:taumax, particiones, N);
  if primin(PIM,N) == 0
    TauOpt = taumax;
  else
    TauOpt = primin(PIM,N);
  end
  % figure
  % plot(0:length(PIM) - 1,PIM);
  % title('Mutual information and time delay')
  % ylabel('Mutual information')
  % xlabel('Time delay')

  % disp(TauOpt)
end


function mutua = ami(x,tau,k,N)
  % mutua = zeros(length(tau), 1);
  mutua = [];
  % I(x_n,x_{n + \tau}) = pim(x, tau, K, Histograma)
  for i = 1:length(tau)
    for k1 = 1:k
      for k2 = 1:k
      % Histogramas unidimensionales
      px = find((k1 - 1)/k<x(1:N - tau(i)) & x(1:N - tau(i))<= k1/k);
      py = find((k2 - 1)/k<x(1 + tau(i):N) & x(1 + tau(i):N)<= k2/k);
      % Histograma bidimensional
      Ixy = find((k1 - 1)/k<x(1:N - tau(i)) & x(1:N - tau(i))<= k1/k & ...
                    (k2-1)/k<x(1 + tau(i):N) & x(1 + tau(i):N)<= k2/k);
      Ixy = length(Ixy);
      Pxy = Ixy;
      % Densidades de probabilidad
      if Pxy > 0
        Px = length(px)/(N-tau(i));
        Py = length(py)/(N-tau(i));
        Pxy = Pxy/(N-tau(i));
        % Promedio de informacion mutua
        % mutua(i) = mutua(i) + Pxy*log2(Pxy/px/py);
        mutua = [mutua, Pxy*log2(Pxy/(Px*Py))];
      end
      end
    end
  end
end


function T = primin(X,N)
  % Devuelve el primer minimo de I(x_n,x_{n + T})
  % j = 0;
  T = 0;
  for m = 3:N
    derivp1(m-2) = X(m-1)-X(m-2);
    derivp2(m-2) = X(m)-X(m-1);
    if (derivp1(m-2)<0)&&(derivp2(m-2)>0)
      % j = j + 1;
      T = m-2;
      break
    end
  end
end
