clc; clear; close all;

data_dir = dir(uigetdir(pwd));

results_dir = './results/lyapunovs/';
if ~exist(results, 'dir')
    mkdir(results_dir)
end

for i=1:length(data_dir)
    if strcmp(data_dir(i).name, "..")
        continue
    end
    if strcmp(data_dir(i).name, ".")
        continue
    end
    disp(data_dir(i).name)
    data = readtable(strcat(data_dir(i).folder, '/', data_dir(i).name));
    idxs = find(data.('Marcadores') == 1);
    end_chunk = find(strcmp(string(data.Properties.VariableNames(:)), 'AF4'));
    % Find where to start the chunk for the different clusters
    idx_cluster = find(strcmp(string(data.('Etiqueta')(idxs)), "Slide de cómo se hacen las donas"));
    for j=idx_cluster:idx_cluster+2
        disp(data.('Etiqueta')(idxs(j)))
        chunk = data(idxs(j):idxs(j+1)-1, 2:end_chunk);
        for k=1:width(chunk)
            % [PIM, optau, FNN, dim, dg, lle, h, S] = chaotic_description(chunk.(k), 128);
            [x, optau, dim] = phaseSpaceReconstruction(chunk.(k), 'MaxLag', 20, 'MaxDim', 10, 'PercentFalseNeighbors', 0.01);
            [lle, estep, ldiv] = lyapunovExponent(chunk.(k),128, optau,dim, 'ExpansionRange', 400);
            p = polyfit(estep, ldiv, 1);
            y_fit = polyval(p, estep);
            y_resid = ldiv - y_fit;
            SSresid = sum(ldiv.^2);
            SStotal = (length(ldiv)-1) * var(ldiv);
            rsq = 1 - SSresid/SStotal;
            name = string(strcat('Erange[0,400]_', data_dir(i).name, 'cluster_', string(j),'_', chunk.Properties.VariableNames(k)));
            save_name = string(strcat('Erange_0_400_', string(i),'_','cluster_', string(j),'_', chunk.Properties.VariableNames(k)));
            f = figure('Name', name, 'NumberTitle', 'off');
            f.Position = [200,200,933,700];
            hold on
            xlabel('Expansion Range')
            ylabel('Average Logarithmic Divergence')
            title(name)
            grid on
            h = plot(estep, ldiv);
            h = plot(estep, y_fit, 'LineStyle', '--');
            text(estep(1),y_fit(1) + 50,strcat('LLE: ', string(p(1))), 'FontSize', 14)
            text(estep(1),y_fit(1) + 30,strcat('R^2: ', string(rsq)), 'FontSize', 14)
            hold off;
            saveas(h, strcat(results_dir, save_name), 'png')
            saveas(h, strcat(results_dir, save_name), 'fig')
            save(strcat(results_dir, save_name, '.mat'), 'optau', 'dim', 'lle', 'estep', 'ldiv', 'p', 'rsq')
            close all
        end
    end
end
