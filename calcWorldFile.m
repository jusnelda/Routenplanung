function [worldfile, roads_geo_out] = calcWorldFile()
% roads_geo_out is going to be a shapefile
% Read shapefile
roads = shaperead('boston_roads.shp');

% Create empty data structure
roads_geo_out = roads;

% NAD 83 Proj. - Load info from Geotiff
info = geotiffinfo('boston.tif');

for i = 1 : length(roads)
    N = 1; 
    for k = 1 : length(roads(i).X)
        x(N) = roads(i).X(k) * unitsratio('sf', 'm');
        y(N) = roads(i).Y(k) * unitsratio('sf', 'm');
        [roads_geo_out(i).Y(k), roads_geo_out(i).X(k)] = projinv(info, x(N), y(N));
        N = N + 1;        
    end
end

% Create Esri World File
% Pixel coordinates from Map screenshot (Map.png)
M = [554, 620, 1; 196, 511, 1;885 ,635, 1;740, 274, 1];

% Geo coordinates extracted from Google Maps
blon = [-71.070726;-71.092461;-71.050471;-71.059216];
blat = [42.351995;42.356956;42.351568;42.367701];

% Let Matlab solve linear equations
alon = M\blon;
alat = M\blat;
worldfile(1,1) = alon(1,1);
worldfile(2,1) = alat(1,1);
worldfile(3,1) = alon(2,1);
worldfile(4,1) = alat(2,1);
worldfile(5,1) = alon(3,1);
worldfile(6,1) = alat(3,1);

fileID = fopen('worldfile.pgw','w');
fprintf(fileID, '%2.12f\n',worldfile);

shapewrite(roads_geo_out, 'roads_geo_out.shp')

end

