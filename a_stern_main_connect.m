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
load('Crossings');
boston_tif = geotiffread('boston.tif');
proj = geotiffinfo('boston.tif');
mstruct = geotiff2mstruct(proj);
[kreuz_lat, kreuz_lon] = calc_lat_lon(Crossings(:,1), Crossings(:,2));

% Start und Ziel markieren
load('L.mat');
field1 = 'Geometry';
value1 = {'Line'};
field_x = 'lat';
field_y = 'long';
value_x = [L(4300).x, L(430).x];
value_y = [L(4300).y, L(430).y];
value_x = value_x * unitsratio('survey feet', 'meter');
value_y = value_y * unitsratio('survey feet', 'meter');
[lat_st_fin,lon_st_fin] = projinv(proj,value_x,value_y);
start_fin = struct(field1,value1, field_x, lat_st_fin, field_y, lon_st_fin);

%%P2 Karten georeferenzieren
figure(4)
hold on
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
mapshow('worldfile.PNG')
mapshow(Highways.lon,Highways.lat, 'Color','m');
mapshow(Local.lon,Local.lat, 'Color','k')
mapshow(start_fin, 'Color', 'g');
% kreuzungen_plot = geoshow(kreuz_lat, kreuz_lon, 'DisplayType', 'point','MarkerEdgeColor','blue','MarkerSize', 20);
kreuzungen_plot = geoshow(kreuz_lat, kreuz_lon, 'DisplayType', 'point','MarkerEdgeColor','blue');
title('Georeferenzierte Karte')
xlabel('Longitude [�]')
ylabel('Latitude [�]')

%%
% A *
% INIT
tic
N = length(boston_roads);
% Die Implementierung ist Indexbasiert, d.h. alle Listen haben die
% gleichen Indezes wie L
start_idx = 4300;
ziel_idx = 430;
START = [L(start_idx).x, L(start_idx).y];
ZIEL = [L(ziel_idx).x, L(ziel_idx).y];

L(start_idx).parent_x = START(1); % Fuer den Startknoten ist er selbst der parent
L(start_idx).parent_y = START(2); % y
path_cost_g = 0; % Weil Startknoten g(n) = 0 (Distanz zu diesem Knoten)
L(start_idx).g = path_cost_g;
goal_distance_h = 0; % Luftlinie
L(start_idx).h = goal_distance_h;
L(start_idx).f = path_cost_g + goal_distance_h;
% Closed List beinhaltet nur, ob der Knoten mit dem entsprechenden Index in
% der CLOSED list ist oder nicht z.B. CLOSED = (false, false, true,...)
CLOSED = zeros(2*N,1);
OPEN = [];
OPEN(1,1) = start_idx;
OPEN(1,2) = L(start_idx).f;
path_found = 0; % wird true gesetzt, wenn Ziel gefunden wurde
x_all = [];
y_all = [];

while isempty(OPEN) == false
    
    [min_cost,min_index] = min(OPEN(:,2));
    current_node = OPEN(min_index,:); % current_node = [index in L vector | Kosten (f)]
    OPEN(min_index,:) = [];
    CLOSED(current_node(1,1)) = 1;
    current_idx = current_node(1,1);
    
    for a = 1 : 2*N
        local_g = A(current_idx, a);
        if local_g > 0 && CLOSED(a) == 0
            
            path_cost_g = L(current_idx).g + local_g;
            goal_distance_h = 0;
            current_f = path_cost_g + goal_distance_h;

            % Knoten a zur OPEN Liste hinzufuegen, falls er noch nicht drin
            % ist
            k = find(OPEN(:,1) == a);
            if isempty(k)
                if isempty(OPEN)
                    OPEN(1,:) = [a, current_f];
                else
                    OPEN(end+1,:) = [a, current_f];
                end
                L(a).g = path_cost_g;
                L(a).h = goal_distance_h;
                L(a).f = current_f;
                L(a).parent_x = L(current_idx).x;
                L(a).parent_y = L(current_idx).y;
                L(a).parent_index = current_idx;
            else
                % Kosten vergleichen
                old_f = OPEN(k,2);
                if current_f < old_f
                    OPEN(k,2) = current_f;
                    L(a).g = path_cost_g;
                    L(a).h = goal_distance_h;
                    L(a).f = current_f;
                    L(a).parent_x = L(current_idx).x;
                    L(a).parent_y = L(current_idx).y;
                    L(a).parent_index = current_idx;
                end % if current_f < old_f
            end % if isempty(k)
            
        end % end if um Knoten in A Matrix zu finden
    end % end A Matrix for schleife
    
    open_indezes = OPEN(:,1);
    for c = 1 : length(open_indezes)
        x_current(c) = L(open_indezes(c)).x * unitsratio('survey feet', 'meter');
        y_current(c) = L(open_indezes(c)).y * unitsratio('survey feet', 'meter');

    end
    
    for b = 1 : length(x_current)
        x_all(end + 1,1) = x_current(b);
        y_all(end + 1,1) = y_current(b);
    end
    

    
end % end while loop (path_found == 0)
save('x_all','x_all');
save('y_all','y_all');
% load('x_all');
% load('y_all');

figure(4)
[lat_current,lon_current] = projinv(proj,x_all,y_all);
geoshow(lat_current, lon_current, 'DisplayType', 'multipoint','MarkerEdgeColor','red')
    
toc