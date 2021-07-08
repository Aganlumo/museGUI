load('training_data.mat');
load('training_classes.mat');

% % Group creation for 1 vs all classes
groups1=repmat(char(0),300,1);groups2=groups1;groups3=groups2;
for  i=1:300
  if (strcmp(classes(i),'F'))
    groups1(i)='F';
  else
    groups1(i)='O';
  end;
  if (strcmp(classes(i),'S'))
    groups2(i)='S';
  else
    groups2(i)='O';
  end;
  if (strcmp(classes(i),'Z'))
    groups3(i)='Z';
  else
    groups3(i)='O';
  end;
end;

% % RBF SVM training
svmStruct1 = svmtrain(data,groups1,'kernel_function',
                      ...'rbf','rbf_sigma',0.2,'boxconstraint',10);
svmStruct2 = svmtrain(data,groups2,'kernel_function',
                      ...'rbf','rbf_sigma',0.5,'boxconstraint',10);
svmStruct3 = svmtrain(data,groups3,'kernel_function',
                      ...'rbf','rbf_sigma',0.15,'boxconstraint',10);

scaleFactor1 = svmStruct1.ScaleData.scaleFactor;
shift1 = svmStruct1.ScaleData.shift;
SupportVectors1 = svmStruct1.SupportVectors;
Alpha1 = svmStruct1.Alpha;
Bias1 = svmStruct1.Bias;
KernelArgs1 = cell2mat(svmStruct1.KernelFunctionArgs);

scaleFactor2 = svmStruct2.ScaleData.scaleFactor;
shift2 = svmStruct2.ScaleData.shift;
SupportVectors2 = svmStruct2.SupportVectors;
Alpha2 = svmStruct2.Alpha;
Bias2 = svmStruct2.Bias;
KernelArgs2 = cell2mat(svmStruct2.KernelFunctionArgs);

scaleFactor3 = svmStruct3.ScaleData.scaleFactor;
shift3 = svmStruct3.ScaleData.shift;
SupportVectors3 = svmStruct3.SupportVectors;
Alpha3 = svmStruct3.Alpha;
Bias3 = svmStruct3.Bias;
KernelArgs3 = cell2mat(svmStruct3.KernelFunctionArgs);

% % % Plot classified areas
% step = 20;
% divisionsDg = 8/step; divisionsL = 3/step; divisionsH = 1/step;
% [X,Y,Z] = meshgrid([0:divisionsDg:8]',
%           ...[−1:divisionsL:2]',[0:divisionsH:1]');

% % % Classified area for F Class
% S = 10*ones(length(X(:)), 1);
% C = repmat([000], length(X(:)), 1);
% for i = 1:length(X(:))
%   if svmclassify(svmStruct1, [X(i) Y(i) Z(i)]) == 'F'
%     C(i, 2) = 1;
%     S(i) = 10*S(i);
%   else
%     C(i, 1) = 1;
%   end;
% end;
% figure
% scatter3(X(:), Y(:), Z(:), S, C, 'fill', 's')
% title('F Class vs S−Z Classes')
% xlabel('Dg');
% ylabel('L');
% zlabel('H');

% % % Classified area for S Class
% S = 10*ones(length(X(:)),1);
% C = repmat([000],length(X(:)),1);
% for i = 1:length(X(:))
%   if svmclassify(svmStruct2, [X(i) Y(i) Z(i)]) == 'S'
%     C(i, 2) = 1;
%   else
%     C(i, 1) = 1;
%     S(i) = 10*S(i);
%   end;
% end;
% figure
% scatter3(X(:), Y(:), Z(:), S, C, 'fill', 's')
% title('S Class vs F−Z Classes')
% xlabel('Dg');
% ylabel('L');
% zlabel('H');

% % % Classifiedareafor ZClass
% S = 10*ones(length(X(:)),1);
% C = repmat([000],length(X(:)),1);
% for i = 1:length(X(:))
%   if svmclassify(svmStruct3, [X(i) Y(i) Z(i)]) == 'Z'
%     C(i, 2) = 1;
%     S(i) = 10*S(i);
%   else
%     C(i, 1) = 1;
%   end;
% end;
% figure
% scatter3(X(:), Y(:), Z(:), S, C, 'fill', 's')
% title('Z Class vs F-S Classes')
% xlabel('Dg');
% ylabel('L');
% zlabel('H');
