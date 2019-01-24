function [bestTour] = ant_algorithm(A)
boston_sights = shaperead('boston_placenames.shp');
proj = geotiffinfo('boston.tif');
% Step 0 -- Init
N = length(A);
% Pheromonmatrix
P = zeros(N,N) + 0.5;
alpha = 0.5; % ausprobieren 0.5
beta = 0.9; % ausprobieren 0.9
% Evaporationswert - Reduktion jeder Pheromone in Abhaengigkeit der Zeit,
% proportional zum Wert: tau = (1 - rho) * tau
rho = 0.05; % 0.25
% Intensification - Vergroesserung der Pheromone entlang der besten Tour,
% um einen konstanten Wert: tau = delta + tau
delta = 0.4; % 0.4-5
bestTour = struct('nodes', 0, 'paths', inf);
max_iteration = 10;
load('L');
L_matrix(:,1) = [L.x];
L_matrix(:,2) = [L.y];
kdTree = KDTreeSearcher(L_matrix);

while max_iteration > 0 % Schritt 5 Abbruchkriterium?
    % Schritt 1 ?
    % Schritt 2 - Fuer jede Ameise eine Tour berechnen
    for i = 1 : N
        current_antTour = calcAntTour(i, P, A, beta, alpha);
        antTour(i).nodes = current_antTour.nodes;
        antTour(i).paths = current_antTour.paths;
    end % Tour berechnen
    
    
    % Schritt 4 Aktuell beste Tour berechnen
    for i = 1 : N
        s = sum(antTour(i).paths);
        if s < bestTour.paths
            bestTour = antTour(i);
        end
    end % Beste Tour berechnen
    %%%% PLOT
%     for ant_idx = 1 : N
%         for p = 1 : N-1
%             start_p = [boston_sights(antTour(ant_idx).nodes(p)).X boston_sights(antTour(ant_idx).nodes(p)).Y];
%             end_p   = [boston_sights(antTour(ant_idx).nodes(p+1)).X boston_sights(antTour(ant_idx).nodes(p+1)).Y];
%             kdTree = KDTreeSearcher(L_matrix);
%             start_idx = knnsearch(kdTree, start_p);
%             end_idx = knnsearch(kdTree, end_p);
%             value_x = [L(start_idx).x, L(end_idx).x];
%             value_y = [L(start_idx).y, L(end_idx).y];
%             value_x = value_x * unitsratio('survey feet', 'meter');
%             value_y = value_y * unitsratio('survey feet', 'meter');
%             [lat_st_fin,lon_st_fin] = projinv(proj,value_x,value_y);
%             start_fin = struct('Geometry', 'Line', 'lat', lat_st_fin, 'long', lon_st_fin);
%             figure(4)
%             antTourplot = geoshow(start_fin, 'DisplayType', 'line', 'LineStyle', ':','Color',[0.6,0.09,0.22], 'LineWidth', 0.5);
%             hold on
%             legend(antTourplot, {'Ant - Possible Ant Tours'})
%         end
%     end
    
    % Schritt 3 Pheromon update
    % Evaporation
    P = (1 - rho) * P;
    % Pheromone der besten Tour vergroessern
    for i = 1 : N - 1
        idx_s = bestTour.nodes(i);
        idx_e = bestTour.nodes(i+1);
        P(idx_s, idx_e) = P(idx_s, idx_e) + delta;
    end
    P(bestTour.nodes(N-1), bestTour.nodes(N)) = P(bestTour.nodes(N-1), bestTour.nodes(1)) + delta;
    max_iteration = max_iteration - 1;
end % while max_iteration > 0

for p = 1 : N
    start_p = [boston_sights(bestTour.nodes(p)).X boston_sights(bestTour.nodes(p)).Y];
    end_p = [boston_sights(bestTour.nodes(p+1)).X boston_sights(bestTour.nodes(p+1)).Y];
    kdTree = KDTreeSearcher(L_matrix);
    start_idx = knnsearch(kdTree, start_p);
    end_idx = knnsearch(kdTree, end_p);
    value_x = [L(start_idx).x, L(end_idx).x];
    value_y = [L(start_idx).y, L(end_idx).y];
    value_x = value_x * unitsratio('survey feet', 'meter');
    value_y = value_y * unitsratio('survey feet', 'meter');
    [lat_st_fin,lon_st_fin] = projinv(proj,value_x,value_y);
    start_fin = struct('Geometry', 'Line', 'lat', lat_st_fin, 'long', lon_st_fin);
    figure(4)
    bestTourplot = geoshow(start_fin, 'DisplayType', 'line','Color', [1,0.4,0.8], 'LineWidth', 2);
    bestTourplot = geoshow(start_fin, 'DisplayType', 'line','Color', 'red', 'LineWidth', 1);
    hold on
    legend([bestTourplot], {'Ant - Best Tour'})
    %legend([bestTourplot, antTourplot], {'Ant - Best Tour', 'Ant - Possible Ant Tours'})
    bestTour.plot = bestTourplot;   
end
% bestTour.allTours = antTourplot
save('bestTour', 'bestTour');
end

