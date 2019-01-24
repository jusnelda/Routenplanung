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

%  Create L-highways-only vector for kdTree later on
N_hw = length(Highways);
for i = 1 : N_hw
    x_road = Highways(i).X;
    y_road = Highways(i).Y;
    
    x_road(isnan(x_road)) = [];
    y_road(isnan(y_road)) = [];
    x_t(1,1) = x_road(1,1);
    x_t(1,2) = x_road(1,(length(x_road)));
    y_t(1,1) = y_road(1,1);
    y_t(1,2) = y_road(1,(length(y_road)));
    
    %   Create L Vector -> Highways ONLY
    L_highways(i).x = x_t(1,1); % Start x
    L_highways(i).y = y_t(1,1); % Start y
    L_highways(N_hw+i).x = x_t(1,2); % End x
    L_highways(N_hw+i).y = y_t(1,2); % End y
    
end

if strcmp(type,'all')
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
    Laplace = create_laplace(A);
    save('Laplace', 'Laplace');
    save('A', 'A');
    save('Crossings', 'Crossings');
    
elseif strcmp(type, 'highways')
    A_HW = zeros(N*2,N*2);
    % Fill adjacency matrix with costs between start and end
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
                A_HW(i,k) = 2;
                A_HW(k,i) = 2;
                index = index + 1;
            end
        end
    end
    average_speed_hw = 40;
    hw_weight = 1;
    for i = 1 : N
        if roads(i).CLASS < 4
            A_HW(i,i+N) = ( roads(i).LENGTH / average_speed_hw ) * hw_weight;
            A_HW(i+N,i) = ( roads(i).LENGTH / average_speed_hw ) * hw_weight;
        end
    end
    Laplace_highways = create_laplace(A_HW);
    save('Laplace_highways', 'Laplace_highways');
    save('A_HW', 'A_HW');
    
elseif strcmp(type, 'locals')
    % Detect crossings and write to adjacency matrix
    A_local = zeros(N*2,N*2);
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
                A_local(i,k) = 2;
                A_local(k,i) = 2;
                Crossings(index,1:2) = P1;
                index = index + 1;
            end
        end
    end
    
    % Fill adjacency matrix with costs between start and end
    average_speed_local = 20;
    local_weight = 5;
    for i = 1 : N
        if roads(i).CLASS >= 4
            A_local(i,i+N) = 3;
            A_local(i+N,i) = 3;
        end
    end
    Laplace_local = create_laplace(A_local);
    save('Laplace_local', 'Laplace_local');
    save('A_local', 'A_local');
    save('Crossings', 'Crossings');
    
elseif strcmp(type, 'kdtree')
    L_matrix(:,1) = [L.x];
    L_matrix(:,2) = [L.y];
    test_point = L_matrix(3000,:);
    kdtree = KDTreeSearcher(L_matrix);
    index = knnsearch(kdtree, test_point);
    L_matrix_hw(:,1) = [L_highways.x];
    L_matrix_hw(:,2) = [L_highways.y];
    kdtree_highways = KDTreeSearcher(L_matrix_hw);
    save('kdtree', 'kdtree');
    save('kdtree_highways', 'kdtree_highways');
end %if type == all

save('L', 'L');

end

