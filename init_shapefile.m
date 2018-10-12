function init_shapefile()

% Shapefile einlesen
roads = shaperead('boston_roads.shp');
Highways = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 < 4), 'CLASS'});
Local = shaperead('boston_roads.shp', 'Selector',{@(v1) (v1 > 3), 'CLASS'});

%% Projizierte Koordinaten in Survey Feet in Meter transformieren und darstellen
tif = geotiffread('boston.tif');
proj = geotiffinfo('boston.tif');
mstruct = geotiff2mstruct(proj);
%% All
x = [roads.X] * unitsratio('survey feet', 'meter');
y = [roads.Y] * unitsratio('survey feet', 'meter');

% X und Y Koordinaten in Laengen- und Breitgrad umrechnen und darstellen
[lat,lon] = projinv(proj,x,y);

% Strassenklassen abspeichern
save('All', 'lat', 'lon');

%% Highways
x = [Highways.X] * unitsratio('survey feet', 'meter');
y = [Highways.Y] * unitsratio('survey feet', 'meter');
% X und Y Koordinaten in Laengen- und Breitgrad umrechnen und darstellen
[lat,lon] = projinv(proj,x,y);
save('Highways', 'lat', 'lon');
%% Local
x = [Local.X] * unitsratio('survey feet', 'meter');
y = [Local.Y] * unitsratio('survey feet', 'meter');
% X und Y Koordinaten in Laengen- und Breitgrad umrechnen und darstellen
[lat,lon] = projinv(proj,x,y);
save('Local', 'lat', 'lon');

end