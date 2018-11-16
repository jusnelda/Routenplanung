function [start_point,goal_point] = commandline_program(All)
% Select points by command line input

%Read points
%Select start
min_lon = min(All.lon); min_lat = min(All.lat);
max_lon = max(All.lon); max_lat = max(All.lat);
disp('Please type coordinates (lat,lon) of start point.')
prompt_orig = ['\nType Longitude between: ', num2str(min_lon), ...
    ' and ', num2str(max_lon), '\n' ];

start_lon = input(prompt_orig);
while start_lon < min_lon || start_lon > max_lon
    prompt = [num2str(start_lon), ' not valid - out of map! ', prompt_orig];
    start_lon = input(prompt);
end
prompt_orig = ['Type Latitude between: ', num2str(min_lat), ...
    ' and ', num2str(max_lat), '\n' ];
start_lat = input(prompt_orig);
while start_lat < min_lat || start_lat > max_lat
    prompt = [num2str(start_lat), ' not valid - out of map! ', prompt_orig];
    start_lat = input(prompt);
end
disp(['Selected start: ', num2str(start_lon), ', ', num2str(start_lat)]);

% Select End point
min_lon = min(All.lon); min_lat = min(All.lat);
max_lon = max(All.lon); max_lat = max(All.lat);
disp('Please type coordinates (lat,lon) of start point.')
prompt_orig = ['\nType Longitude between: ', num2str(min_lon), ...
    ' and ', num2str(max_lon), '\n' ];

end_lon = input(prompt_orig);
while end_lon < min_lon || end_lon > max_lon
    prompt = [num2str(end_lon), ' not valid - out of map! ', prompt_orig];
    end_lon = input(prompt);
end
prompt_orig = ['Type Latitude between: ', num2str(min_lat), ...
    ' and ', num2str(max_lat), '\n' ];
end_lat = input(prompt_orig);
while end_lat < min_lat || end_lat > max_lat
    prompt = [num2str(end_lat), ' not valid - out of map! ', prompt_orig];
    end_lat = input(prompt);
end
disp(['Selected end:', num2str(start_lon), ', ', num2str(start_lat)]);

%Transform coordinates to NAD83
proj = geotiffinfo('boston.tif');
[x_start,y_start] = projfwd(proj,start_lat, start_lon);
[x_end, y_end] = projfwd(proj, end_lat, end_lon);
start_point = [x_start,y_start];
goal_point = [x_end, y_end];
end

