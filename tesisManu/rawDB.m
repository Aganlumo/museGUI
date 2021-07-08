% clc; clear; close all;

% data_dir = uigetdir('D:/ITESM/EEG/tesisManu/data/bp');
% data_dir = dir(data_dir);
data_dir = dir('D:/ITESM/EEG/tesisManu/data/raw');

header = 'id,student_id,electrodo_id,cluster_id,tau,m,Dg,LLE,H,S\n';
% results_dir = uigetdir(data_dir(1).folder);
results_dir = 'D:/ITESM/EEG/tesisManu/results';
fid = fopen(strcat(results_dir,'\CriticalThinkingEEG_DB_raw.csv'), 'w');
fprintf(fid, header);
fclose(fid);

id = 1;
bid = 1;
for i=1:length(data_dir)
    if strcmp(data_dir(i).name, "..")
        continue
    end
    if strcmp(data_dir(i).name, ".")
        continue
    end
    disp(data_dir(i).name)
    data = readtable(strcat(data_dir(i).folder, '\', data_dir(i).name));
    idxs = find(data.('Marcadores') == 1);
    c_id = 1;
    end_chunk = find(strcmp(string(data.Properties.VariableNames(:)), 'AF4'));
    % Find where to start the chunk for the different clusters
    idx_cluster = find(strcmp(string(data.('Etiqueta')(idxs)), "Slide de cómo se hacen las donas"));
    for j=idx_cluster:idx_cluster+2
        disp(data.('Etiqueta')(idxs(j)))
        chunk = data(idxs(j):idxs(j+1)-1, 2:end_chunk);
        for k=1:width(chunk)
            % [PIM, optau, FNN, dim, dg, lle, h, S] = chaotic_description(chunk.(k), 128);
            [x, optau, dim] = phaseSpaceReconstruction(chunk.(k), 'MaxLag', 20, 'MaxDim', 10, 'PercentFalseNeighbors', 0.01);
            dg = correlationDimension(chunk.(k), optau, dim, 'NumPoints',200);
            lle = lyapunovExponent(chunk.(k),128, optau,dim, 'ExpansionRange', 100);
            h = hurstexp(chunk.(k));
            % S = approximateEntropy(chunk.(2), optau);
            S = approximateEntropy(chunk.(k), optau, dim);
            fID = fopen(strcat(results_dir, '\CriticalThinkingEEG_DB_raw.csv'),'a');
            %               'id, fn, electrodo_id,cluster_id,tau,m,Dg,LLE,H,S\n';
            fprintf(fID,'%d,%d,%d,%d,%d,%d,%f,%f,%f,%f\n',id,i-2,k,c_id,optau,dim,dg,lle,h,S);
            fclose(fID);
            id = id + 1;
        end
        c_id = c_id + 1;
    end
end
