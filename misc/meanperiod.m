function mean_period = meanperiod(x, Fs)
  % Estimates the mean period of the time series
  % x: timeseries
  % Fs: samplingfrequency
  % Based upon the Matlab example obtained from:
  % http://www.mathworks.com/help/matlab/ref/fft.html
  % Band-Pass filter example was obtained from
  % http://www.mathworks.com/help/dsp/ref/fdesign.bandpass.html

  % T = 1/Fs;
  L = length(x);
  % t=(0:L - 1)*T;

  NFFT = 2^nextpow2(L); % Next power of 2 from length of y
  X = fft(x, NFFT)/L;
  f = Fs/2*linspace(0,1,NFFT/2 + 1);

  % % Plot single sided amplitude spectrum.
  % figure
  % plot(f, 2*abs(X(1:NFFT/2 + 1)))
  % title('Single Sided Amplitude Spectrum of y(t)')
  % xlabel('Frequency (Hz)')
  % ylabel('|Y(f)|')
  mean_period = 1/(sum(2*abs(X(1:NFFT/2 + 1)))/length(X(1:NFFT/2 + 1)));
end

function y = butterworth(x)
  % Butterworth Filter for EEG time series
  fs = 173.61;

  %  Designan IIR Butterworth filter of order 10 with 3-dB
  %  frequencies of 0.53 and 60 Hz
  d = fdesign.bandpass('N,F3dB1,F3dB2', 10, 0.53, 60, fs);
  Hd = design(d,'butter');
  %  Apply the filter to the discrete-time signal.
  y = filter(Hd,x);
  figure(1)
  plot(x)
  xlabel('time');
  ylabel('microVolts');
  figure(2)
  plot(y)
  xlabel('time');
  ylabel('microVolts');
  xdft = fft(x);
  ydft = fft(y);
  % PlotResults
  freq = 0:(2*pi)/length(x):pi;
  plot(freq, abs(xdft(1:length(x)/2 + 1)));
  hold on;
  plot(freq, abs(ydft(1:length(x)/2 + 1)), 'r', 'linewidth', 2);
  legend('OriginalSignal', 'BandpassSignal');
end
