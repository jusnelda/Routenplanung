%%Boston Navi App
%%INIT
clc;
clear all;
close all;
format longg
boston_roads = shaperead('boston_roads.shp');
%init_shapefile()
%[worldfile, shapefile] = calcWorldFile();

%%Matfiles laden
Highways = load('Highways');
All = load('All');
Local = load('Local');


%% P1 Strassen darstellen
% figure
% mapshow(Highways.lon,Highways.lat, 'Color','m')
% title('Boston Highways in geographic coordinates')
% xlabel('Longitude [�]')
% ylabel('Latitude [�]')
% figure
% mapshow(Local.lon,Local.lat, 'Color','g')
% title('Boston Local roads in geographic coordinates')
% xlabel('Longitude [�]')
% ylabel('Latitude [�]')
% figure
% mapshow(All.lon,All.lat, 'Color','b')
% title('Boston All roads in geographic coordinates')
% xlabel('Longitude [�]')
% ylabel('Latitude [�]')

%% Interaktiv Punkte auswaehlen

%%Punkte durch User input einlesen
% Startpunkt waehlen
% min_lon = min(All.lon); min_lat = min(All.lat);
% max_lon = max(All.lon); max_lat = max(All.lat);
% disp('Bitte Startpunkt mit Laengen- und Breitengrad angeben.')
% prompt_orig = ['\nBitte Laengengrad zwischen: ', num2str(min_lon), ...
%     ' und ', num2str(max_lon), ' eingeben:\n' ];
%
% start_lon = input(prompt_orig);
% while start_lon < min_lon || start_lon > max_lon
%     prompt = [num2str(start_lon), ' ist nicht gueltig. ', prompt_orig];
%     start_lon = input(prompt);
% end
% prompt_orig = ['Bitte Breitengrad zwischen: ', num2str(min_lat), ...
%     ' und ', num2str(max_lat), ' eingeben:\n' ];
% start_lat = input(prompt_orig);
% while start_lat < min_lat || start_lat > max_lat
%     prompt = [num2str(start_lat), ' ist nicht gueltig. ', prompt_orig];
%     start_lat = input(prompt);
% end
% disp(['Startpunkt gewaehlt: ', num2str(start_lon), ', ', num2str(start_lat)]);

% Endpunkt waehlen
% min_lon = min(All.lon); min_lat = min(All.lat);
% max_lon = max(All.lon); max_lat = max(All.lat);
% disp('Bitte Endpunkt mit Laengen- und Breitengrad angeben.')
% prompt_orig = ['\nBitte Laengengrad zwischen: ', num2str(min_lon), ...
%     ' und ', num2str(max_lon), ' eingeben:\n' ];
%
% end_lon = input(prompt_orig);
% while end_lon < min_lon || end_lon > max_lon
%     prompt = [num2str(end_lon), ' ist nicht gueltig. ', prompt_orig];
%     end_lon = input(prompt);
% end
% prompt_orig = ['Bitte Breitengrad zwischen: ', num2str(min_lat), ...
%     ' und ', num2str(max_lat), ' eingeben:\n' ];
% end_lat = input(prompt_orig);
% while end_lat < min_lat || end_lat > max_lat
%     prompt = [num2str(end_lat), ' ist nicht gueltig. ', prompt_orig];
%     end_lat = input(prompt);
% end
% disp(['Endpunktpunkt gewaehlt: ', num2str(start_lon), ', ', num2str(start_lat)]);

%%P2 Eingegebene Koordinaten in NAD83 Koordinaten transformieren
% proj = geotiffinfo('boston.tif');
% [x_start,y_start] = projfwd(proj,start_lat, start_lon)
% [x_end, y_end] = projfwd(proj, end_lat, end_lon)


%% shapefiletoadjmatrix
% shapefileToAdjMatrix('all');
% disp('Adjazenzmatrix und L Vector erstellt');
%% Visualisierung
load('A');
load('L');
load('Kreuzungen');
boston_tif = geotiffread('boston.tif');
proj = geotiffinfo('boston.tif');
mstruct = geotiff2mstruct(proj);
[kreuz_lat, kreuz_lon] = calc_lat_lon(Kreuzungen(:,1), Kreuzungen(:,2));

% Start und Ziel markieren
load('L.mat');


%%P2 Karten georeferenzieren
figure(4)
hold on
set(gcf, 'units', 'normalized', 'outerposition',[0 0 1 1])
mapshow('worldfile.PNG')
mapshow(Highways.lon,Highways.lat, 'Color',[0.22,0.47,0.78]);
mapshow(Local.lon,Local.lat, 'Color',[0.27,0.75,0.78])

kreuzungen_plot = geoshow(kreuz_lat, kreuz_lon, 'DisplayType', 'point', 'Marker', '+',...
        'MarkerSize', 3, 'MarkerEdgeColor',[1,0.4,0.8]);

title('Boston in geografischen Koordinaten - A-Star Algorithmus')
xlabel('Longitude')
ylabel('Latitude')

%%

% % A *
% % INIT
% tic
% N = length(boston_roads);
% % Die Implementierung ist Indexbasiert, d.h. alle Listen haben die
% % gleichen Indezes wie L
% start_idx = 4300;
% ziel_idx = 430;
% START = [L(start_idx).x, L(start_idx).y];
% ZIEL = [L(ziel_idx).x, L(ziel_idx).y];
% 
% L(start_idx).parent_x = START(1); % Fuer den Startknoten ist er selbst der parent
% L(start_idx).parent_y = START(2); % y
% path_cost_g = 0; % Weil Startknoten g(n) = 0 (Distanz zu diesem Knoten)
% L(start_idx).g = path_cost_g;
% goal_distance_h = distance_to_goal(START,ZIEL); % Luftlinie
% L(start_idx).h = goal_distance_h;
% L(start_idx).f = path_cost_g + goal_distance_h;
% % Closed List beinhaltet nur, ob der Knoten mit dem entsprechenden Index in
% % der CLOSED list ist oder nicht z.B. CLOSED = (false, false, true,...)
% CLOSED = zeros(2*N,1);
% OPEN = [];
% OPEN(1,1) = start_idx;
% OPEN(1,2) = L(start_idx).f;
% path_found = 0; % wird true gesetzt, wenn Ziel gefunden wurde
% 
% while path_found == 0
%     
%     [min_cost,min_index] = min(OPEN(:,2));
%     current_node = OPEN(min_index,:); % current_node = [index in L vector | Kosten (f)]
%     OPEN(min_index,:) = [];
%     CLOSED(current_node(1,1)) = 1;
%     current_idx = current_node(1,1);
%     
%     for a = 1 : 2*N
%         local_g = A(current_idx, a);
%         if local_g > 0 && CLOSED(a) == 0
%             
%             path_cost_g = L(current_idx).g + local_g;
%             goal_distance_h = distance_to_goal([L(a).x, L(a).y], ZIEL);
%             current_f = path_cost_g + goal_distance_h;
% 
%             % Knoten a zur OPEN Liste hinzufuegen, falls er noch nicht drin
%             % ist
%             k = find(OPEN(:,1) == a);
%             if isempty(k)
%                 if isempty(OPEN)
%                     OPEN(1,:) = [a, current_f];
%                 else
%                     OPEN(end+1,:) = [a, current_f];
%                 end
%                 L(a).g = path_cost_g;
%                 L(a).h = goal_distance_h;
%                 L(a).f = current_f;
%                 L(a).parent_x = L(current_idx).x;
%                 L(a).parent_y = L(current_idx).y;
%                 L(a).parent_index = current_idx;
%             else
%                 % Kosten vergleichen
%                 old_f = OPEN(k,2);
%                 if current_f < old_f
%                     OPEN(k,2) = current_f;
%                     L(a).g = path_cost_g;
%                     L(a).h = goal_distance_h;
%                     L(a).f = current_f;
%                     L(a).parent_x = L(current_idx).x;
%                     L(a).parent_y = L(current_idx).y;
%                     L(a).parent_index = current_idx;
%                 end % if current_f < old_f
%             end % if isempty(k)
%             
%         end % end if um Knoten in A Matrix zu finden
%     end % end A Matrix for schleife
%     
%     %%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%
%     open_indezes = OPEN(:,1);
%     for c = 1 : length(open_indezes)
%         x_current(c) = L(open_indezes(c)).x * unitsratio('survey feet', 'meter');
%         y_current(c) = L(open_indezes(c)).y * unitsratio('survey feet', 'meter');
% 
%     end
%     [lat_current,lon_current] = projinv(proj,x_current,y_current);
%     figure(4)
%     geoshow(lat_current, lon_current, 'DisplayType', 'point', 'Marker', '.',...
%         'MarkerSize', 10, 'MarkerEdgeColor','red')
%     
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     % Ziel gefunden
%     if current_idx == ziel_idx
%         path_found = 1;
%         disp('Am Ziel angekommen');
%     end % if current_idx == ziel_idx
%     
% end % end while loop (path_found == 0)
% final_path(1,:) = [L(ziel_idx).x, L(ziel_idx).y, ziel_idx];
% final_parent_index = L(ziel_idx).parent_index;
% while final_parent_index ~= start_idx
%     final_path(end+1,:) = [L(final_parent_index).x, L(final_parent_index).y, final_parent_index];
%     final_parent_index = L(final_parent_index).parent_index;
% end
% final_path(end+1,:) = [L(start_idx).x, L(start_idx).y, start_idx];
% 
% % delete(kreuzungen_plot)
% figure(4)
% roads_transf = shaperead('roads_geo_out.shp');
% for p = 1:length(final_path)
%     if (final_path(p,3) > length(roads_transf))
%         tempIdx = final_path(p,3) - length(roads_transf);
%         mapshow(roads_transf(tempIdx), 'Color', 'b', 'LineWidth',2)
%     end
% end
% toc

%% Interaktive Start und Endpunkte dem A* Algorithmus �bergeben
map = figure('Position', [0, 0, 1280, 1024]);
roads_transf = shaperead('roads_geo_out.shp');
mapshow('worldfile.PNG'); 
[startIndex, endIndex] = ginput(2);
close(map);
p2p_start = p2p_Matching(startIndex(1,1), endIndex(1,1), roads_transf);
p2p_end = p2p_Matching(startIndex(2,1), endIndex(2,1), roads_transf);

field1 = 'Geometry';
value1 = {'Line'};
field_x = 'lat';
field_y = 'long';
value_x = [L(p2p_start).x, L(p2p_end).x];
value_y = [L(p2p_start).y, L(p2p_end).y];
value_x = value_x * unitsratio('survey feet', 'meter');
value_y = value_y * unitsratio('survey feet', 'meter');
[lat_st_fin,lon_st_fin] = projinv(proj,value_x,value_y);
start_fin = struct(field1,value1, field_x, lat_st_fin, field_y, lon_st_fin);
figure(4)
mapshow(start_fin, 'Color', [1,0.76,0], 'LineWidth', 2);

final_path = a_star(p2p_start, p2p_end,boston_roads, L, A,proj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PLOT
figure(4)
for p = 1:length(final_path)
    if (final_path(p,3) > length(roads_transf))
        tempIdx = final_path(p,3) - length(roads_transf);
        mapshow(roads_transf(tempIdx), 'Color', 'b', 'LineWidth',2)
    end
end