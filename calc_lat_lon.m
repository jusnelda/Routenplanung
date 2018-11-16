function [lat,lon] = calc_lat_lon(x_feet,y_feet)
proj = geotiffinfo('boston.tif');
x_meter = x_feet * unitsratio('survey feet', 'meter');
y_meter = y_feet * unitsratio('survey feet', 'meter');
[lat,lon] = projinv(proj,x_meter,y_meter);
end

