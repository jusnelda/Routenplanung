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
figure
mapshow(Highways.lon,Highways.lat, 'Color','m')
title('Boston Highways in geographic coordinates')
xlabel('Longitude [�]')
ylabel('Latitude [�]')
figure
mapshow(Local.lon,Local.lat, 'Color','g')
title('Boston Local roads in geographic coordinates')
xlabel('Longitude [�]')
ylabel('Latitude [�]')
figure
mapshow(All.lon,All.lat, 'Color','b')
title('Boston All roads in geographic coordinates')
xlabel('Longitude [�]')
ylabel('Latitude [�]')

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
% [A,L] = shapefileToAdjMatrix('all');
% disp('Adjazenzmatrix und L Vector erstellt');
%% Visualisierung
load('A');
load('L');
load('Kreuzungen');
boston_tif = geotiffread('boston.tif');
proj = geotiffinfo('boston.tif');
mstruct = geotiff2mstruct(proj);
x_1 = [Kreuzungen(:,1)] * unitsratio('survey feet', 'meter');
y_1 = [Kreuzungen(:,2)] * unitsratio('survey feet', 'meter');
% X und Y Koordinaten in Laengen- und Breitengrad umrechnen und darstellen
[lat_1,lon_1] = projinv(proj,x_1,y_1);

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
mapshow('worldfile.PNG')
mapshow(Highways.lon,Highways.lat, 'Color','m');
mapshow(Local.lon,Local.lat, 'Color','k')
mapshow(start_fin, 'Color', 'g');
kreuzungen_plot = geoshow(lat_1, lon_1, 'DisplayType', 'point','MarkerEdgeColor','blue')

title('Georeferenzierte Karte')
xlabel('Longitude [�]')
ylabel('Latitude [�]')
%%
% roadColors = ...
%     makesymbolspec('Line',{'CLASS',1,'Color',[0.22,0.47,0.78]},...
%     {'CLASS',2,'Color',[0.22,0.47,0.78]},...
%     {'CLASS',3,'Color','r'},...
%     {'CLASS',4,'Color',[0.96,0.82,0.4]},...
%     {'CLASS',5,'Color',[0.96,0.82,0.4]},...
%     {'CLASS',6,'Color',[0.96,0.82,0.4],'LineStyle',':'},...
%     {'CLASS',7,'Color',[0.22,0.47,0.78]},...
%     {'Default','Color','k'});
% figure(5)
% hold on
% mapshow(boston_roads,'SymbolSpec',roadColors);
% title('Boston roads in NAD83 projected coordinates [survey feet]')
% xlabel('X [survey feet]')
% ylabel('Y [survey feet]')


%%
% A *
% INIT
tic
N = length(boston_roads);
% Die Implementierung ist Indexbasiert, d.h. die alle Listen haben die
% gleichen Indezes wie L
START = [L(4300).x, L(4300).y];
ZIEL = [L(430).x, L(430).y];
start_index = 4300;
ziel_index = 430;
L(4300).parent_x = START(1); % Fuer den Startknoten ist er selbst der parent
L(4300).parent_y = START(2); % y
path_cost = 0; % Weil Startknoten h(n) = 0 (Distanz zu diesem Knoten)
L(4300).h = path_cost;
goal_distance = distance_to_goal(START,ZIEL) % Matlab Function => g(n)
L(4300).g = goal_distance;
L(4300).f = goal_distance; % Bei START f(n) = g(n), weil h(n) = 0
% Closed List beinhaltet nur, ob der Knoten mit dem entsprechenden Index in
% der CLOSED list ist oder nicht z.B. CLOSED = (false, false, true,...)
CLOSED = zeros(2*N,1);
OPEN = [];
OPEN(1,1) = 4300;
OPEN(1,2) = L(4300).f;
path_found = 0; % wird true gesetzt, wenn Ziel gefunden wurde
counter=1;


while path_found == 0
    
    [min_cost,min_index] = min(OPEN(:,2));
    current_node = OPEN(min_index,:); % current_node = [index in L vector | Kosten (f)]
    OPEN(min_index,:) = [];
    CLOSED(current_node(1,1)) = 1;
    
    %min_cost = min([L.f]);
    %[~, index] = find( cellfun(@(x)isequal(x,min_cost),{L.f}) ) % findet den index mit den geringsten Kosten
    
    for a = 1 : 2*N
        weight = A(current_node(1,1),a);
        if weight > 0 && CLOSED(a) == 0
            L(a).h = weight;
            L(a).g = distance_to_goal([L(a).x, L(a).y], ZIEL);
            L(a).f = L(a).h + L(a).g;
            k = find(OPEN(:,1) == a);
            if isempty(k)
                if isempty(OPEN)
                    OPEN(1,:) = [a, L(a).f];
                else
                    OPEN(end+1,:) = [a, L(a).f];
                end
                L(a).parent_x = L(current_node(1,1)).x;
                L(a).parent_y = L(current_node(1,1)).y;
                L(a).parent_index = current_node(1,1);
            else
                % Kosten vergleichen
                current_f = L(a).f;
                old_f = OPEN(k,2);
                if current_f < old_f
                    OPEN(k,:) = [a, current_f];
                    L(a).parent_x = L(current_node(1,1)).x;
                    L(a).parent_y = L(current_node(1,1)).y;
                    L(a).parent_index = current_node(1,1);
                end
            end
            
        end % end if um Knoten in A Matrix zu finden
    end % end A Matrix for schleife
    
    %%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%
    open_indezes = OPEN(:,1);
    for c = 1 : length(open_indezes)
        x_current(c) = L(open_indezes(c)).x * unitsratio('survey feet', 'meter');
        y_current(c) = L(open_indezes(c)).y * unitsratio('survey feet', 'meter');
    end
    [lat_current,lon_current] = projinv(proj,x_current,y_current);
    figure(4)
    geoshow(lat_current, lon_current, 'DisplayType', 'multipoint','MarkerEdgeColor','green')
    pause(0.2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Ziel gefunden
    if current_node(1,1) == ziel_index
        path_found = 1;
        disp('Am Ziel angekommen');
        %         path(1,1:2) = [L(current_node(1,1)+N).x, L(current_node(1,1)+N).y];
        %         path(1,3:4) = [L(current_node(1,1)).x, L(current_node(1,1)).y]; % Ziel muss der Endknoten sein
        
        path(1,1:2) = [L(current_node(1,1)).x, L(current_node(1,1)).y]; % Ziel
        path(1,3:4) = [L(current_node(1,1)).parent_x, L(current_node(1,1)).parent_y];
        path_index = 2;
        parent_index = L(current_node(1,1)).parent_index;
        while parent_index ~= start_index
            path(path_index,1:2) = [L(parent_index).x, L(parent_index).y]; 
            path(path_index,3:4) = [L(parent_index).parent_x, L(parent_index).parent_y];
            %shape_index = mod(parent_index,N) -> geht nicht bei
            %parent_index == N
            
            %             if parent_index <= N
            %                 segment_start = [L(parent_index).x, L(parent_index).y];
            %                 segment_end = [L(parent_index+N).x, L(parent_index+N).y];
            %                 path(path_index,:) = [segment_start, segment_end];
            %             else
            %                 parent_index = parent_index - N;
            %                 segment_start = [L(parent_index).x, L(parent_index).y];
            %                 segment_end = [L(parent_index+N).x, L(parent_index+N).y];
            %                 path(path_index,:) = [segment_start, segment_end];
            %             end
            parent_index = L(parent_index).parent_index;
            path_index = path_index + 1;
            
        end
        value_x_path = [path(:,1); path(:,3)];
        value_y_path = [path(:,2); path(:,4)];
        x_current = value_x_path * unitsratio('survey feet', 'meter');
        y_current = value_y_path * unitsratio('survey feet', 'meter');
        [lat_path,lon_path] = projinv(proj,x_current,y_current);
        figure(4)
        delete(kreuzungen_plot)
        geoshow(lat_path, lon_path, 'DisplayType', 'line','MarkerEdgeColor','red')
%         Mapshow
%         figure(5)
%         field1 = 'Geometry';
%         value1 = {'Line'};
%         field_x = 'X';
%         field_y = 'Y';
%         for p = 1 : length(path)
%             value_x_path = [path(:,1); path(:,3)];
%             value_y_path = [path(:,2); path(:,4)];
%             path_struct = struct(field1,value1, field_x, value_x_path, field_y, value_y_path);
%             mapshow(path_struct, 'Color','red') 
%         end
        
    end
    
end % end while loop (START ~= ZIEL && path_found == 0)

toc