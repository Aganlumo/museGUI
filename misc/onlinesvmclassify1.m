function class = onlinesvmclassify1(scaleFactor, shift, SupportVectors,
                                  ...Alpha, Bias, KernelFunctionArgs,
                                  ...Sample, class0, class1)
  % Online classification for embedded coding in Simulink
  for c=1:size(Sample,2)
    Sample(:,c) = scaleFactor(c)*(Sample(:,c) + shift(c));
  end
  sum = 0;
  for i=1:length(SupportVectors)
    sum = sum + (Alpha(i)*rbf(SupportVectors(i,:),Sample,KernelFunctionArgs));
  end
  sum = sum + Bias;
  if(sum>=0)
    class = class1;
  else
    class = class0;
  end
end


function class = onlinesvmclassify2(scaleFactor,shift,SupportVectors,
                                    ...Alpha,Bias,KernelFunctionArgs,
                                    ...Sample,class0,class1)
  % Online classification for embedded coding in Simulink
  for c=1:size(Sample,2)
    Sample(:,c) = scaleFactor(c)*(Sample(:,c) + shift(c));
  end
  sum = 0;
  for i=1:length(SupportVectors)
    sum = sum + (Alpha(i)*rbf(SupportVectors(i,:),Sample,KernelFunctionArgs));
  end
  sum = sum + Bias;
  if(sum>=0)
    class = class1;
  else
    class = class0;
  end
end


function class = onlinesvmclassify3(scaleFactor,shift,SupportVectors,
                                    ...Alpha,Bias,KernelFunctionArgs,
                                    ...Sample,class0,class1)
  % Online classification for embedded coding in Simulink
  for c=1:size(Sample,2)
    Sample(:,c) = scaleFactor(c)*(Sample(:,c) + shift(c));
  end
  sum = 0;
  for i=1:length(SupportVectors)
    sum = sum + (Alpha(i)*rbf(SupportVectors(i,:),Sample,KernelFunctionArgs));
  end
  sum = sum + Bias;
  if(sum>=0)
    class = class1;
  else
    class = class0;
  end
end


function k = rbf(sv,Sample,sigma)
  k = exp(−sum((sv−Sample).^2)/(2*sigma^2));
end
