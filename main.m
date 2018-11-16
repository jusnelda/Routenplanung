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

%% Show different kinds of roads
% figure(1)
% mapshow(Highways.lon,Highways.lat, 'Color','m')
% title('Boston Highways in geographic coordinates - Highways')
% xlabel('Longitude')
% ylabel('Latitude')
% figure(2)
% mapshow(Local.lon,Local.lat, 'Color','g')
% title('Boston Local roads in geographic coordinates - Local roads')
% xlabel('Longitude')
% ylabel('Latitude')
% figure (3)
% mapshow(All.lon,All.lat, 'Color','b')
% title('Boston All roads in geographic coordinates - All roads')
% xlabel('Longitude')
% ylabel('Latitude')

%% Get User Input for start and destination via command line
% [start, goal] = commandline_program(All);

%% Shapefile To adjmatrix
% shapefileToAdjMatrix('all');
% disp('Created adjacency matrix and L vector');
%% Visualization
load('A');
load('L');
load('Crossings');
boston_tif = geotiffread('boston.tif');
proj = geotiffinfo('boston.tif');
mstruct = geotiff2mstruct(proj);
[cross_lat, cross_lon] = calc_lat_lon(Crossings(:,1), Crossings(:,2));

%%%%%%%%%%%%%%%%%%% PLOT georeferenced map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
hold on
set(gcf, 'units', 'normalized', 'outerposition',[0 0 1 1])

mapplot = mapshow('worldfile.PNG');
highwayplot = mapshow(Highways.lon,Highways.lat, 'Color',[0.22,0.47,0.78]);
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
start_idx = point2point_matching(clicked_start(1,1), clicked_end(1,1), roads_geo);
end_idx = point2point_matching(clicked_start(2,1), clicked_end(2,1), roads_geo);

%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT Beeline %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
value_x = [L(start_idx).x, L(end_idx).x];
value_y = [L(start_idx).y, L(end_idx).y];
value_x = value_x * unitsratio('survey feet', 'meter');
value_y = value_y * unitsratio('survey feet', 'meter');
[lat_st_fin,lon_st_fin] = projinv(proj,value_x,value_y);
start_fin = struct('Geometry', 'Line', 'lat', lat_st_fin, 'long', lon_st_fin);
figure(4)
beelineplot = geoshow(start_fin, 'DisplayType', 'line','Color',[1,0.76,0], 'LineWidth', 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% A-STAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
final_path = a_star(start_idx, end_idx,boston_roads, L, A,proj);
%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT Final Path %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
for p = 1 : length(final_path)
    if (final_path(p,3) > length(roads_geo))
        transformed_idx = final_path(p,3) - length(roads_geo);
        finplot = mapshow(roads_geo(transformed_idx), 'Color', 'blue', 'LineWidth',2);
    end
end
% legend('Map', 'Highways', 'Local Roads', 'Crossings', 'Beeline', plotname, 'Final Path')
legend([mapplot, highwayplot, localplot, crossplot, beelineplot, final_path(1,4), finplot], {'Map', ...
    'Highways', 'Local Roads', 'Crossings', 'Beeline', 'OPEN List', 'Final Path'})