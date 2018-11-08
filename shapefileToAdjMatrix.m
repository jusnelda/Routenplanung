function [A, L] = shapefileToAdjMatrix(type)

% Shapefile einlesen
roads = shaperead('boston_roads.shp');
Highways = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 < 4), 'CLASS'});
Local = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 > 3), 'CLASS'});

N = length(roads);
% Alle Shapefile Koordinaten in eine Liste der Form L = (start1,start2,....startn,end1,end2,....endn) schreiben
for i = 1 : N
    x_road = roads(i).X;
    y_road = roads(i).Y;
    
    x_road(isnan(x_road)) = [];
    y_road(isnan(y_road)) = [];
    x_t(1,1) = x_road(1,1);
    x_t(1,2) = x_road(1,(length(x_road)));
    y_t(1,1) = y_road(1,1);
    y_t(1,2) = y_road(1,(length(y_road)));
    
%     % L Vektor erstellen  
    L(i).x = x_t(1,1); % Start x
    L(i).y = y_t(1,1); % Start y
    L(N+i).x = x_t(1,2); % End x
    L(N+i).y = y_t(1,2); % End y
    
end

if type == 'all'
    % Kreuzungen entdecken und in Adjazezmatrix schreiben
    A = zeros(N*2,N*2);
    min_dist = min([roads.LENGTH]);
    index = 1;
    % min_dist = min(min_dist)
    for i = 1 : N*2
        P1 = [L(i).x, L(i).y];
        for k = 1 : N*2
            P2 = [L(k).x, L(k).y];
            % Strecke zwischen zwei Punkten berechnen
            s = sqrt((P1(1,1) - P2(1,1))^2 + (P1(1,2) - P2(1,2))^2);
            if s < min_dist * 50 && s > 0
                % Kreuzung gefunden
                A(i,k) = 2;
                A(k,i) = 2;
                Kreuzungen(index,1:2) = P1;
                Kreuzungen(index,3:4) = P2;
                index = index + 1;
            end
        end
    end
    % Adjazenzmatrix mit 1ern befüllen zwischen start und ende
    % A = zeros(N*2,N*2);
    average_speed_hw = 40;
    hw_weight = 1;
    average_speed_local = 20;
    local_weight = 5;
    for i = 1 : N
        if roads(i).CLASS < 4
            A(i,i+N) = average_speed_hw * roads(i).LENGTH * hw_weight;
            A(i+N,i) = average_speed_hw * roads(i).LENGTH * hw_weight;
        else
            A(i,i+N) = average_speed_local * roads(i).LENGTH * local_weight;
            A(i+N,i) = average_speed_local * roads(i).LENGTH * local_weight;
        end
    end
    
end
save('A', 'A');
save('L', 'L');
save('Kreuzungen', 'Kreuzungen');
end

