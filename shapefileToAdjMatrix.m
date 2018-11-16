function shapefileToAdjMatrix(type)

% Read Shapefile
roads = shaperead('boston_roads.shp');
Highways = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 < 4), 'CLASS'});
Local = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 > 3), 'CLASS'});

N = length(roads);

%   All Shapefile coordinates in one list L like this = ( start1,start2,....startn,end1,end2,....endn )
for i = 1 : N
    x_road = roads(i).X;
    y_road = roads(i).Y;
    
    x_road(isnan(x_road)) = [];
    y_road(isnan(y_road)) = [];
    x_t(1,1) = x_road(1,1);
    x_t(1,2) = x_road(1,(length(x_road)));
    y_t(1,1) = y_road(1,1);
    y_t(1,2) = y_road(1,(length(y_road)));
    
%   Create L Vector 
    L(i).x = x_t(1,1); % Start x
    L(i).y = y_t(1,1); % Start y
    L(N+i).x = x_t(1,2); % End x
    L(N+i).y = y_t(1,2); % End y
    
end

if type == 'all'
    % Detect crossings and write to adjacency matrix
    A = zeros(N*2,N*2);
    min_dist = min([roads.LENGTH]);
    index = 1;
    for i = 1 : N*2
        P1 = [L(i).x, L(i).y];
        for k = i+1 : N*2
            P2 = [L(k).x, L(k).y];
            % Calculate distance between two points
            s = sqrt( ( P1(1,1) - P2(1,1) )^2 + ( P1(1,2) - P2(1,2) )^2 );
            if s < min_dist
                % Crossing found
                A(i,k) = 2;
                A(k,i) = 2;
                Crossings(index,1:2) = P1;
                index = index + 1;
            end
        end
    end

    % Fill adjacency matrix with costs between start and end
    average_speed_hw = 40;
    hw_weight = 1;
    average_speed_local = 20;
    local_weight = 5;
    for i = 1 : N
        if roads(i).CLASS < 4
            A(i,i+N) = ( roads(i).LENGTH / average_speed_hw ) * hw_weight;
            A(i+N,i) = ( roads(i).LENGTH / average_speed_hw ) * hw_weight;
        else
            A(i,i+N) = ( roads(i).LENGTH / average_speed_local ) * local_weight;
            A(i+N,i) = ( roads(i).LENGTH / average_speed_local ) * local_weight;
        end
    end
    
end
save('A', 'A');
save('L', 'L');
save('Crossings', 'Crossings');
end

