%% Boston Navi App
% INIT
clc;
clear all;
close all;
format longg
boston_roads = shaperead('boston_roads.shp');
roads_geo = shaperead('roads_geo_out.shp');
N = length(roads_geo);
%init_shapefile()
%[worldfile, shapefile] = calcWorldFile();

% load matfiles
Highways = load('Highways');
All = load('All');
Local = load('Local');

load('A');
load('L');
load('A_local')
load('A_HW')
load('Crossings');
load('kdtree');
connected_map = load('Connected_Graph');
%% Visualization
boston_tif = geotiffread('boston.tif');
proj = geotiffinfo('boston.tif');
mstruct = geotiff2mstruct(proj);
[cross_lat, cross_lon] = calc_lat_lon(Crossings(:,1), Crossings(:,2));

%%%%%%%%%%%%%%%%%%% PLOT georeferenced map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
hold on
set(gcf, 'units', 'normalized', 'outerposition',[0 0 1 1])

mapplot = mapshow('worldfile.PNG');
highwayplot = mapshow(Highways.lon,Highways.lat, 'Color',[0,0.38,0.87]);
localplot = mapshow(Local.lon,Local.lat, 'Color',[0.27,0.75,0.78]);
crossplot = geoshow(cross_lat, cross_lon, 'DisplayType', 'point',...
        'Marker', '+', 'MarkerSize', 3, 'MarkerEdgeColor',[1,0.4,0.8]);
title('Boston in geographical coordinates - A-Star Algorithm')
xlabel('Longitude [lon]')
ylabel('Latitude [lat]')

%% Open map to select start and end by clicking
map = figure('Position', [0, 0, 1280, 1024]);
mapshow('worldfile.PNG'); 
title('Please click to select Start and Destination')
xlabel('Longitude [lon]')
ylabel('Latitude [lat]')
[clicked_start, clicked_end] = ginput(2);
close(map);
start_idx = point2point_matching(clicked_start(1,1), clicked_end(1,1), roads_geo, kdtree);
end_idx = point2point_matching(clicked_start(2,1), clicked_end(2,1), roads_geo, kdtree);

if connected_map.closed_list(start_idx) == 0
    % Use default value
    start_idx = 4300;
end
if connected_map.closed_list(end_idx) == 0
    % Use default value
    end_idx = 430;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT Beeline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
value_x = [L(start_idx).x, L(end_idx).x];
value_y = [L(start_idx).y, L(end_idx).y];
value_x = value_x * unitsratio('survey feet', 'meter');
value_y = value_y * unitsratio('survey feet', 'meter');
[lat_st_fin,lon_st_fin] = projinv(proj,value_x,value_y);
start_fin = struct('Geometry', 'Line', 'lat', lat_st_fin, 'long', lon_st_fin);
figure(4)
beelineplot = geoshow(start_fin, 'DisplayType', 'line','Color',[1,0.76,0], 'LineWidth', 2);
%%%%%%%%%%%%%%%%%%% A-STAR - Weg-Mitte-Heuristik %%%%%%%%%%%%%%%%%%%%%%%%%
start_idx_to_hw_start_index = point2point_matching_highway(clicked_start(1,1), clicked_end(1,1), roads_geo);
start_idx_to_hw_end_index = start_idx_to_hw_start_index + N;
end_idx_to_hw_end_index = ( point2point_matching_highway(clicked_start(2,1), clicked_end(2,1), roads_geo) + N );
end_idx_to_hw_start_index = end_idx_to_hw_end_index - N;
mapshow(roads_geo(start_idx_to_hw_start_index), 'Color', 'green', 'LineWidth',4);
mapshow(roads_geo(end_idx_to_hw_start_index), 'Color', 'green', 'LineWidth',4);
final_path = a_star(start_idx, start_idx_to_hw_start_index, boston_roads, L, A, proj);

%%%%%%%%%%%%%%%%%%%%%%% PLOT Final Path to Highway %%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
for p = 1 : size(final_path,1)
    if (final_path(p,3) > length(roads_geo))
        transformed_idx = final_path(p,3) - length(roads_geo);
        finplot = mapshow(roads_geo(transformed_idx), 'Color', 'magenta', ...
                          'LineWidth', 4);
    else
        finplot = mapshow(roads_geo(final_path(p,3)), 'Color', 'magenta', ...
                          'LineWidth', 4);
    end
end

legend([mapplot, highwayplot, localplot, crossplot, beelineplot, ...
        final_path(1,4), finplot], {'Map', 'Highways', 'Local Roads', ...
        'Crossings', 'Beeline', 'OPEN List', 'Final Path'});
delete(final_path(1,4));
final_path = a_star_on_highway(start_idx_to_hw_start_index, end_idx_to_hw_end_index, boston_roads, L, A_HW, proj);
%%%%%%%%%%%%%%%%%%%%%%%% PLOT Final Path on Highway %%%%%%%%%%%%%%%%%%%%%%%
figure(4)
for p = 1 : size(final_path,1)
    if (final_path(p,3) > length(roads_geo))
        transformed_idx = final_path(p,3) - length(roads_geo);
        finplot_hw = mapshow(roads_geo(transformed_idx), 'Color', 'blue', 'LineWidth',2);
    else
        finplot_hw = mapshow(roads_geo(final_path(p,3)), 'Color', 'blue', ...
                             'LineWidth', 2);
    end
end
hw_open_list_plot = final_path(1,4);
final_path = a_star(end_idx_to_hw_end_index,end_idx, boston_roads, L, A, proj);
%%%%%%%%%%%%%%%%%%%%%%%%% PLOT Final Path from Highway %%%%%%%%%%%%%%%%%%%
figure(4)
for p = 1 : size(final_path,1)
    if (final_path(p,3) > length(roads_geo))
        transformed_idx = final_path(p,3) - length(roads_geo);
        finplot = mapshow(roads_geo(transformed_idx), 'Color', 'magenta', ...
                          'LineWidth', 4);
    else
        finplot = mapshow(roads_geo(final_path(p,3)), 'Color', 'magenta', ...
                          'LineWidth', 4);
    end
end
local_open_list_plot = final_path(1,4);
legend([highwayplot, localplot, crossplot, beelineplot, ...
        local_open_list_plot, hw_open_list_plot, finplot, finplot_hw], ...
        {'Highways', 'Local Roads', ...
        'Crossings', 'Beeline', 'Local OPEN List', 'Highway OPEN List', ...
        'Final Path local', 'Final Path Highways'})
    

