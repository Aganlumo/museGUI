clc; clear; close all;

% Get the data directory
% data_dir = uigetdir('D:/ITESM/EEG/tesisManu/data/bp');
% data_dir = dir(data_dir);
data_dir = dir('D:/ITESM/EEG/tesisManu/data/bp');

% Create header for file
header = 'id,student_id,electrodo_id,banda_id,cluster_id,tau,m,Dg,LLE,H,S\n';

% Get the directory to store the results
% results_dir = uigetdir(data_dir(1).folder);
results_dir = 'D:/ITESM/EEG/tesisManu/results';

% Create file and put the header on it. If there is an existing file, it
% overwrites it
fid = fopen(strcat(results_dir,'\CriticalThinkingEEG_DB_bp.csv'), 'w');
fprintf(fid, header);
fclose(fid);

% Variables for the creation of the db
id = 1;
bid = 1;
for i=1+2:length(data_dir)
    % Get the values of the csv
    data = readtable(strcat(data_dir(i).folder, '\', data_dir(i).name));
    disp(data_dir(i).name)
    % Get the markers indexes
    idxs = find(data.(27) == 1);
    c_id = 1;
    end_chunk = find(strcmp(string(data.Properties.VariableNames(:)), 'AF4_GAMMA'));
    % Find where to start the chunk for the different clusters
    idx_cluster = find(strcmp(string(data.(28)(idxs)), "Slide de cómo se hacen las donas"));
    for j=idx_cluster:idx_cluster+2
        disp(data.(28)(idxs(j)))
        chunk = data(idxs(j):idxs(j+1)-1, 2:end_chunk);
        for k=1:width(chunk)
            % [PIM, optau, FNN, dim, dg, lle, h, S] = chaotic_description(chunk.(k), 128);
            [x, optau, dim] = phaseSpaceReconstruction(chunk.(k), 'MaxLag', 20, 'MaxDim', 10, 'PercentFalseNeighbors', 0.01);
            dg = correlationDimension(chunk.(k), optau, dim, 'NumPoints',200);
            lle = lyapunovExponent(chunk.(k),128, optau,dim);
            h = hurstexp(chunk.(k));
            % S = approximateEntropy(chunk.(2), optau);
            S = approximateEntropy(chunk.(k), optau, dim);
            fID = fopen(strcat(results_dir, '\CriticalThinkingEEG_DB_bp.csv'),'a');
            %               'id, fn, electrodo_id,banda_id,cluster_id,tau,m,Dg,LLE,H,S\n';
            fprintf(fID,'%d,%d,%d,%d,%d,%d,%d,%f,%f,%f,%f\n',id,i-2,floor((k-1)/5)+1,bid,c_id,optau,dim,dg,lle,h,S);
            fclose(fID);
            if bid == 5
                bid = 0;
            end
            bid = bid + 1;
            id = id + 1;
        end
        c_id = c_id + 1;
    end
end
