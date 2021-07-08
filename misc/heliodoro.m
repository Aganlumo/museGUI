A = importdata('Z001.txt');
ts = timeseries(A);
mean_per = meanperiod(A,1000);
filtered = butterworth (A);
%plot(A)

[PIM1,TOpt]=pim(A,64,   128);
M=mean(PIM1);
[FNN1, dimension] = knn_deneme(A,TOpt,20,15,2);
plot3(PIM1,PIM1-5,PIM1-10)
%[Corrdim,C_vector,RadiusVec]=corrdim(A,dimension,TOpt); 

%Lyapunv=lyarosenstein (A,dimension,TOpt,100, mean_per,5000);
%Hurst=hurstexp(A)
%Entrop1=approximateEntropy(A)           

%B=importdata('Z002.txt');
%ts2=timeseries(B);
%mean_per2=meanperiod(B,1000);
%filtered=butterworth (B);

%[PIM2,TOpt2]=pim(B,64,128);
%[FNN2, dimension2] = knn_deneme(B,TOpt2,20,15,2);
%[Corrdim2,C_vector2,RadiusVec2]=corrdim(B,dimension2,TOpt2); 
%Lyapunv2=lyarosenstein (B,dimension2,TOpt2,100, mean_per2,5000);
%Hurst2=hurstexp(B);
%Entrop2=approximateEntropy(B);

function mean_period = meanperiod (x , Fs) 
% Estimates the mean period of the time series % x: time series 
%Fs : sampling frequency 
% Based upon the Matlab example obtained from here : 
%http : //www. mathworks .com/ help / matlab / ref / fft . html 
% Band?Pass filter example was obtained from 
%http : //www. mathworks .com/ help / dsp / ref / fdesign . bandpass . html
T = 1/Fs ;
L =   length (x); 
%t = (0:L?1)*T;
NFFT=2^nextpow2(L); % Next power of 2 from length of y 
X = fft(x ,NFFT)/L; 
%f = Fs/2* linspace (0 ,1 ,NFFT/2+1);
% Plot single?sided amplitude spectrum . 
% plot (f ,2* abs (X(1:NFFT/2+1))) 
% ti t le ( ’ Single?Sided Amplitude Spectrum of y( t ) ’) % xlabel ( ’ Frequency (Hz) ’) 
% ylabel ( ’|Y( f )| ’)
mean_period = 1/(sum(2*abs(X(1:NFFT/2+1)))/length(X(1:NFFT/2+1)));
end
function y = butterworth( x )
% Butterworth Filter for EEG time series 
fs = 173.61;

% Design an IIR Butterworth filter of order 10 with 3?dB 
% frequencies of 0.53 and 60 Hz 
d = fdesign.bandpass ('N,F3dB1,F3dB2',10 ,0.53 ,60 , fs ); 
Hd = design(d,'butter'); 
% Apply the filter to the discrete ?time signal . 
y = filter (Hd,x ); 
% figure (1) 
% plot (x) 
% xlabel ( ’time ’); 
% ylabel ( ’ microVolts ’); 
% figure (2) % plot (y) 
% xlabel ( ’time ’); 
% ylabel ( ’ microVolts ’); 
xdft = fft (x ); 
ydft = fft (y ); 
% Plot Results 
% freq = 0:(2* pi )/ length (x ): pi ; 
% plot ( freq , abs ( xdft (1: length (x )/2+1))); 
% hold on; 
% plot ( freq , abs ( ydft (1: length (x)/2+1)) , ’ r ’ , ’ linewidth ’ ,2); 
% legend ( ’ Original Signal ’ , ’ Bandpass Signal ’);
end

%PROMEDIO DE INFORMMACION MUTUA

function [PIM, TauOpt] = pim( serie , taumax , particiones) 
% [PIM, TauOpt] = pim( serie , taumax , particiones )
% e .g. taumax = 64; particiones = 128; 
% Devuelve la grafica de I (x_n , x_{n+Tau}) 
% y el valor optimo de retraso 
% Normalizacion de la serie 
serie = ( serie-min( serie ))/( max( serie)-min( serie ));
N = length (serie); 
PIM = ami(serie ,1: taumax,particiones ,N); 
if primin (PIM,N)==0
    TauOpt = taumax ; 
else
    TauOpt = primin(PIM,N);
end
 %figure (1); 
% plot3(PIM,PIM-5,PIM-10)
%title ('Mutual information and time delay') 
%ylabel ('Mutual information') 
%xlabel ('Time delay ') 
end
function mutua = ami(x , tau ,k ,N) 
%mutua = zeros ( length ( tau ) ,1); 
mutua = []; 
% I (x_n , x_{n+\ tau })=pim(x , tau , KHistograma)
for i =1: length ( tau ) 
    for k1=1:k 
        for k2=1:k 
        % Histogramas unidimensionales 
        px=find ((k1-1)/k<x(1:N-tau ( i )) & x(1:N-tau ( i ))<=k1/k ); 
        py=find ((k2-1)/k<x(1+ tau ( i ):N) & x(1+ tau ( i ):N)<=k2/k );  
        % Histograma bidimensional 
        Ixy=find((k1-1)/k<x(1:N-tau ( i )) & x(1:N-tau ( i ))<=k1/k & (k2-1)/k<x(1+ tau ( i ):N)& x(1+ tau (i):N)<=k2/k );
        Ixy=length( Ixy ); 
        Pxy = Ixy ; 
        % Densidades de probabilidad
            if Pxy>0 
                Px=length (px )/(N-tau ( i )); 
                Py=length (py )/(N-tau ( i )); 
                Pxy=Pxy /(N-tau ( i )); 
            %Promedio de informacion mutua 
            %mutua(i)=mutua( i )+Pxy*log2 (Pxy/px/py ); 
                mutua=[mutua,Pxy*log2(Pxy/(Px*Py))]; 
                
             end
        end
    end
    
end
end
function T = primin (X,N) 
% Devuelve el primer minimo de I (x_n , x_{n+T}) 
% j =0;
T=0; 
for m=3:N 
    derivp1(m-2)= X(m-1)-X(m-2); 
    derivp2(m-2)= X(m)-X(m-1); 
    if ( derivp1 (m-2)<0) && ( derivp2 (m-2)>0) 
        %j=j +1; 
        T = m-2; 
        break 
    end
end
end

%FALSOS VECINOS CERCANOS

function [FNN, emb_dim] = knn_deneme(x , tao ,mmax, rtol , atol ) 
% x : time series 
% tao : time delay
%mmax : maximum embedding dimension 
% reference :M. B. Kennel , R. Brown , and H. D. I . Abarbanel , 
% Determining embedding dimension for phase?space reconstruction 
% using a geometrical construction , Phys . Rev. A 45, 3403 (1992). 
% modified by: Walther Carballo Hernández

% rtol =15 
% atol =2; 
N=length (x ); 
% Standard deviation 
Ra=std (x ,1); 
emb_dim = 0;

% Compute the FNN with each m iteration 
for m=1:mmax 
    M=N-m*tao ; 
    %Reconstruct the attractor 
    Y=psr_deneme(x ,m, tao ,M); 
    FNN(m,1)=0; 
    % Each iteration calculates the distance from one point 
    % in the attractorwith other point in the space state 
    for n=1:M 
        y0=ones (M,1)*Y(n ,:) ; 
        % Obtaining the distance vector 
        distance=sqrt (sum((Y-y0 ).^2 ,2)); 
        % Sorting the distance vector 
        [neardis nearpos]=sort(distance); 
        % Obtaining absolute value 
        D=abs (x(n+m*tao)-x(nearpos(2)+m*tao)); 
        % Obtaining square root 
        R=sqrt (D.^2+ neardis(2).^2);
        if D/neardis(2) > rtol || R/Ra > atol 
            FNN(m,1)=FNN(m,1)+1; 
        end
    end
    if (FNN(m,1)/FNN(1 ,1))*100 < 0.01 
        emb_dim = m; 
        break 
    end
end
% Calculating embedding dimension 
if emb_dim == 0 
    min_indexes = find(FNN(:,1)==min(FNN(:,1))); 
    emb_dim = min_indexes(1,1);
end
% Percentage of the FNN 
FNN=(FNN./FNN(1,1))*100
% Plot results 
%figure (2)
%plot (1: length (FNN) ,FNN)
 %title ( 'Minimum embedding dimension with false nearest neighbours ') 
 %xlabel ( 'Embedding dimension ') 
 %ylabel ( 'The percentage of false nearest neighbours ')
 
end
%ATRACTOR
function Y=psr_deneme(x ,m, tao ,npoint ) 
    %Phase space reconstruction 
    %x : time series 
    %m : embedding dimension 
    %tao : time delay 
    %npoint : total number of reconstructed vectors 
    %Y : M x m matrix 
    % author :"Merve Kizilkaya " 
    N =length (x ); 
    if nargin == 4
        M = npoint ;
    else
        M=N-(m-1)*tao ;
    end
    Y= zeros (M ,m);
    for i =1:m 
        Y(:,i)=x((1:M)+(i-1)*tao )'; 
    end
    
end

%CORRELACION
    
  function [dg , C_R, R] = corrdim (x , m, tau ) 
        % Correlation dimension based on Grassberger?Procaccia algorithm (1983) 
        % dg : Correlation dimension 
        % C_R : Vector of contribution of the points 
        % in the Radius R ( size = (R_max?R_min/ R_step )+1) 
        %R : Vector of radius (same size as C_R) 
        % x :Time series 
        %m :Embedded dimension 
        % tau :Time delay 
        % R_initial : Initial radius of the n?dimensional sphere ( i . e . 0.3) 
        % R_step : Increments of the radius ( i . e 0.1) 
        % R_max : Max radius (?1 R_step ) of the n?dimensional sphere 
        % 
        % Created by: Walther Carballo Hernández
        N = length (x ); 
        M = N-(m-1)* tau ; 
        % Attractor reconstruction 
        Y = psr_deneme(x , m, tau ); 
        R_min = 1000; R_max = 0; 
        % Distance vector between all the points size of N^2 ? N 
        dist_vec = zeros (1 ,((N^2)-N));
        n = 1;
        % Estimating R_min and R_max 
        for i= 1: length (Y) %For each point 
            for j = 1: length (Y) %Compare with the other points 
                if i ~= j %If it ’s not the same point 
                    R_estimate = norm(Y(i ,:)-Y(j ,:)) ; 
                    dist_vec ? = R_estimate ; 
                    if R_estimate < R_min %Estimate min radius 
                        R_min = R_estimate ; 
                    end
                    if R_estimate > R_max %Estimate max radius 
                        R_max = R_estimate ;
                    end
                    n = n + 1; 
                end
            end
        end
% Range of the Radius ignore and 40% of the max radius 
R_range = 0.2*(R_max-R_min );
R_max = R_max-2*R_range ;
if R_min == 0
    R_min = 1.0000e-06; %Solve some cases of NaN in R and C_R vectors 
end
% Calculate step of the radius increase in the linear 
% zone of 10 divisions 
R_step = (R_max-R_min)/10; 
R = R_min; 
C_R = zeros (1 , floor (((R_max-R_min )/ R_step )+1)); 
n = 1; 
sum = 0;
% Obtaining C(R) vector 
while R <= R_max + 1 %R_init tends to R_max in steps of R_step 
    % For each distance in the distance vector 
    for i= 1: length (dist_vec) 
        % If it ’s contained in the radius 
        if dist_vec ( i ) < R
            % Add 1 to the counter 
            sum = sum + 1; 
        end
    end
% C_R calculation 
C_R(n) = ((2/(M*(M-1)))*sum); 
% Next step for the Radius 
R = R + R_step ; 
sum = 0; 
n = n + 1;
end
% Calculate ln (C(R)) and ln (R) 
R = (R_min: R_step :R_max); 
lnC_R = log (C_R); 
lnR = log (R);
% Calculate dg 
coefficients = polyfit (lnR (2: length (lnR)-5),lnC_R(2: length (lnC_R)-5) ,1); 
dg = coefficients (1);
% Plot results % y = coefficients (1)*lnR + coefficients (2); 
% figure ; 
% hold on; 
 plot (lnR ,y,'??'); 
 plot (lnR ,lnC_R );
% title ( ’ln(C(R))vs ln(R)’); 
% xlabel ( ’ln(R)’); 
% ylabel ( ’ln(C(R))’);
   end

   
%LYAPUNOV
  function lle = lyarosenstein (x ,m, tao , fs , meanperiod , maxiter ) 
  % d: divergence of nearest trajectoires 
  % x: signal 
  % tao : time delay 
  %m: embedding dimension 
  % fs : sampling frequency
%Copyright (c) 2012, mirwais 
%All rights reserved . 
% Created by: Mirwais 
%Modifications by: Walther Carballo Hernández

N=length (x );
M=N-(m-1)*tao ; 
Y=psr_deneme(x ,m, tao ); 
%Obtaining nearest distances 
for i=1:M 
    x0=ones (M,1)*Y(i,:); 
    distance=sqrt(sum((Y-x0 ).^2 ,2)); 
    for j =1:M 
        if abs(j-i)<=meanperiod 
            distance(j)=1e10;
        end
    end
    [neardis(i) nearpos(i)]=min(distance); 
end
 
%Obtaining log of divergence 
for k=1: maxiter 
    maxind=M-k; 
    evolve =0; 
    pnt =0; 
    for j=1:M 
        if j<=maxind && nearpos(j)<=maxind 
            dist_k=sqrt(sum((Y( j+k,:)-Y( nearpos(j)+k ,:)).^2 ,2));
            if dist_k~=0 
                evolve=evolve+log(dist_k); 
                pnt=pnt +1; 
            end
        end
    end
    if pnt > 0 
        d(k)=evolve/pnt; 
    else
        d(k)=0; 
    end
end
 
% figure 
% plot (d) 
% ti t le (’ Largest Lyapunov Exponent divergence ’);
% xlabel ( ’ Drive cycles ’); 
% ylabel ( ’LLE’);
 
%%LLE Calculation 
tlinear =40:90; 
F = polyfit( tlinear ,d(tlinear),1); 
lle = F(1)* fs ;
  end

    
%HURST
function H = hurstexp (x) 
    % Computing of Hurst exponent 
    % x is the time series 
    % Created by: Walther Carballo Hernández
% Length of the time series 
N = length (x ); 
% Maximal 2?factors divisions of the time series 
max_divisions = round ( log (N)/ log (2)); 
lnH_n = zeros (1 , max_divisions ); 
lnn = zeros (1 , max_divisions );
 
% For each division obtain the rescaled range 
for k= 1: max_divisions 
    n=round (N/(2^(k-1))); 
       if (n == 1) 
            break; 
       end
    lnn (k) = log (n );
    % Divide the time series
    X = x(1:n ); 
    % Obtaining the mean of the new time series 
    m = mean(X); 
    % Adjusting the time series to the mean 
    Y = X-m; 
    Z = zeros (1 ,n );
    R = 0; S = 0; 
    sum = 0;
    % Computing the cumulative deviate series 
    for t = 1:n
        for i = 1: t
            sum = sum + Y( i );
        end
        Z( t ) = sum; 
        sum = 0;
    end
    % Obtaining the range of the deviate series 
    R = range (Z);
% Computing standard deviation 
for i = 1:n 
    sum = sum + ((X( i )-m)^2); 
end
S = sqrt ((sum)/ n );
% Computing the results of rescaled range and store them 
if ( isnan ( log (R/S)))
    lnH_n(k) = 0; 
else
    lnH_n(k) = log (R/S); 
end
end
 
% Linear approximation 
coefficients = polyfit (lnn , lnH_n ,1); 
H = coefficients (1);
 
% Plot results 
% y = coefficients (1)* lnn + coefficients (2); 
% figure ; 
% hold on; 
% plot (lnn ,y.’??’); 
% plot (lnn , lnH_n ); 
% ti t le ( ’ ln (H(R/S)) vs ln ? ’);
% xlabel ( ’ ln ? ’); % ylabel ( ’ ln (H(R/S)) ’);
end 

function [apen] = approx_entropy(n,r,a)
%% Code for computing approximate entropy for a time series: Approximate
% Entropy is a measure of complexity. It quantifies the unpredictability of
% fluctuations in a time series

% To run this function- type: approx_entropy('window length','similarity measure','data set')

% i.e  approx_entropy(5,0.5,a)

% window length= length of the window, which should be considered in each iteration
% similarity measure = measure of distance between the elements
% data set = data vector

% small values of apen (approx entropy) means data is predictable, whereas
% higher values mean that data is unpredictable

% concept boorowed from http://www.physionet.org/physiotools/ApEn/

% Author: Avinash Parnandi, parnandi@usc.edu, http://robotics.usc.edu/~parnandi/


data =a;


for m=n:n+1; % run it twice, with window size differing by 1

set = 0;
count = 0;
counter = 0;
window_correlation = zeros(1,(length(data)-m+1));

for i=1:(length(data))-m+1
    current_window = data(i:i+m-1); % current window stores the sequence to be compared with other sequences
    
    for j=1:length(data)-m+1
    sliding_window = data(j:j+m-1); % get a window for comparision with the current_window
    
    % compare two windows, element by element
    % can also use some kind of norm measure; that will perform better
    for k=1:m
        if((abs(current_window(k)-sliding_window(k))>r) && set == 0)
            set = 1; % i.e. the difference between the two sequence is greater than the given value
        end
    end
    if(set==0) 
         count = count+1; % this measures how many sliding_windows are similar to the current_window
    end
    set = 0; % reseting 'set'
    
    end
   counter(i)=count/(length(data)-m+1); % we need the number of similar windows for every cuurent_window
   count=0;
i;
end  %  for i=1:(length(data))-m+1, ends here


counter;  % this tells how many similar windows are present for each window of length m
%total_similar_windows = sum(counter);

%window_correlation = counter/(length(data)-m+1);
correlation(m-n+1) = ((sum(counter))/(length(data)-m+1));


 end % for m=n:n+1; % run it twice   
   correlation(1);
   correlation(2);
apen = log(correlation(1)/correlation(2));
end