function matrix = shapefileToAdjMatrix(type)

% Shapefile einlesen
roads = shaperead('boston_roads.shp');
Highways = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 < 4), 'CLASS'});
Local = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 > 3), 'CLASS'});

% Alle Shapefile Koordinaten in eine Liste der Form L = (start1,start2,....startn,end1,end2,....endn) schreiben
N = length(roads);
for i = 1 : N
    x = roads(i).X;
    y = roads(i).Y;
    
    x(isnan(x)) = [];
    y(isnan(y)) = [];
    x_t(1,1) = x(1,1);
    x_t(1,2) = x(1,(length(x)));
    y_t(1,1) = y(1,1);
    y_t(1,2) = y(1,(length(y)));
    
    % L Vektor erstellen
    L(i,1) = x_t(1,1); % Start x
    L(i,2) = y_t(1,1); % Start y
    L(N+i,1) = x_t(1,2); % End x
    L(N+i,2) = y_t(1,2); % End y
end

if type == 'all'
    % Kreuzungen entdecken und in Adjazezmatrix schreiben
    A = zeros(N*2,N*2);
    min_dist = min([roads.LENGTH]);
    index = 1;
    % min_dist = min(min_dist)
    for i = 1 : N*2
        P1 = L(i,:);
        for k = 1 : N*2
            P2 = L(k,:);
            % Strecke zwischen zwei Punkten berechnen
            s = sqrt((P1(1,1) - P2(1,1))^2 + (P1(1,2) - P2(1,2))^2);
            if s < min_dist*5 && s > 0
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
matrix = A;
end

