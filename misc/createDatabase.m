clc; clear; close all;

ZFiles = dir('Z');
FFiles = dir('F');
SFiles = dir('S');
formatSpec = '%f';

header = 'tau,m,Dg,LLE,H,S\n';

fid = fopen('CompleteZDataBase.csv', 'w');
fprintf(fid, header);
fclose(fid);
fid = fopen('CompleteFDataBase.csv', 'w');
fprintf(fid, header);
fclose(fid);
fid = fopen('CompleteSDataBase.csv', 'w');
fprintf(fid, header);
fclose(fid);

for  i=3:length(ZFiles)
    fileID = fopen(strcat('Z\\', ZFiles(i).name), 'r');
    x = fscanf(fileID, formatSpec);
    fID = fopen('CompleteZDataBase.csv', 'a');
    [PIM, optau, FNN, dim, dg, lle, h, S] = chaotic_description(x);
    fprintf(fID, '%f,%f,%f,%f,%f,%f\n', optau, dim, dg, lle, h, S);
    fclose(fID);
end

for  i=3:length(FFiles)
    fileID = fopen(strcat('F\\', FFiles(i).name), 'r');
    x = fscanf(fileID, formatSpec);
    fID = fopen('CompleteFDataBase.csv', 'a');
    [PIM, optau, FNN, dim, dg, lle, h, S] = chaotic_description(x);
    fprintf(fID, '%f,%f,%f,%f,%f,%f\n', optau, dim, dg, lle, h, S);
    fclose(fID);
end

for  i=3:length(SFiles)
    fileID = fopen(strcat('S\\', SFiles(i).name), 'r');
    x = fscanf(fileID, formatSpec);
    fID = fopen('ConpleteSDataBase.csv', 'a');
    [PIM, optau, FNN, dim, dg, lle, h, S] = chaotic_description(x);
    fprintf(fID, '%f,%f,%f,%f,%f,%f\n', optau, dim, dg, lle, h, S);
    fclose(fID);
end
