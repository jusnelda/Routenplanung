function shapefileToAntMatrix()

% Read Shapefile
sights = shaperead('boston_placenames.shp');

N = length(sights);
n_visiting = 5;
load('L');
L_matrix(:,1) = [L.x];
L_matrix(:,2) = [L.y];
kdTree = KDTreeSearcher(L_matrix);

% Detect crossings and write to adjacency matrix
AntMatrix = zeros(n_visiting,n_visiting);
for i = 1 : n_visiting
    P1 = [sights(i).X, sights(i).Y];
    % Find closest Point on Map
    start_p_index = knnsearch(kdTree,P1);
    for j = 1 : n_visiting
        P2 = [sights(j).X, sights(j).Y];
        end_p_index = knnsearch(kdTree,P2);
        if i ~= j
            % Calculate distance between two points
            %s = sqrt( ( P1(1,1) - P2(1,1) )^2 + ( P1(1,2) - P2(1,2) )^2 );
            s = sqrt ( ( L(start_p_index).x - L(end_p_index).x)^2 + ...
                       ( L(start_p_index).y - L(end_p_index).y)^2 );
            AntMatrix(i,j) = s;
        end
    end
end

save('AntMatrix', 'AntMatrix');

end

