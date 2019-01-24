close all;
clear all;
clc
%shapefileToAntMatrix();

load('AntMatrix');
load('L');
load('A');
L_matrix(:,1) = [L.x];
L_matrix(:,2) = [L.y];

boston_sights = shaperead('boston_placenames.shp');
boston_roads = shaperead('boston_roads.shp');
proj = geotiffinfo('boston.tif');
roads_geo = shaperead('roads_geo_out.shp');
x = [boston_sights.X] * unitsratio('survey feet', 'meter');
y = [boston_sights.Y] * unitsratio('survey feet', 'meter');
[lat,lon] = projinv(proj,x,y);
% %% PLOT
figure(4)
hold on
set(gcf, 'units', 'normalized', 'outerposition',[0 0 1 1])
mapplot = mapshow('worldfile.PNG');
sightsplot = geoshow(lat(1,1:5),lon(1,1:5), 'DisplayType', 'point',...
    'Marker', 'o', 'MarkerSize', 7, 'MarkerFaceColor',[1,0.4,0.8]);
title('Ant Algorithm combined with A-Star in Boston')
xlabel('Longitude [°]')
ylabel('Latitude [°]')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bestTour = ant_algorithm(AntMatrix);

% Trick to go back to starting point
bestTour.nodes(end+1) = bestTour.nodes(1);
bestTour.paths(end+1) = bestTour.paths(1);

%% Apply A-Star on bestTour
for i = 1 : length(bestTour.nodes)-1
    idx_s = bestTour.nodes(i);
    idx_e = bestTour.nodes(i+1);
    
    start_p = [boston_sights(idx_s).X boston_sights(idx_s).Y];
    end_p = [boston_sights(idx_e).X boston_sights(idx_e).Y];
    kdTree = KDTreeSearcher(L_matrix);
    k_start = knnsearch(kdTree, start_p);
    k_end = knnsearch(kdTree, end_p);
    
    final_path = a_star(k_start, k_end, boston_roads, L, A, proj);
    figure(4)
    for p = 1 : size(final_path,1)
        if (final_path(p,3) > length(roads_geo))
            transformed_idx = final_path(p,3) - length(roads_geo);
            finplot = mapshow(roads_geo(transformed_idx), 'Color', [0,0.69,0.94], 'LineWidth',2.5);
        else
            finplot = mapshow(roads_geo(final_path(p,3)), 'Color', [0,0.69,0.94], 'LineWidth',2.5);
        end
    end
    legend([sightsplot, bestTour.plot, final_path(1,4), finplot], ...
        {'Points of Interest (Sights)',...
        'Ant - Best Tour', 'A* - Open List', 'A* - Final Path'})
end
    legend([sightsplot, bestTour.plot, final_path(1,4), finplot], ...
        {'Points of Interest (Sights)',...
        'Ant - Best Tour', 'A* - Open List', 'A* - Final Path'})