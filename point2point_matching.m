function [closest_index_p2p, closest_index_kd] = point2point_matching( lon, lat, shapefile, kdtree )
% function that returns the index of the closest point to the clicked (x,y) 
% in the shapefile
tic
min_dist = inf;
for i = 1 : length( shapefile )
   for j = 1 : length( shapefile(i).X )
       
       % calculate distance
       distance = hypot( ( shapefile(i).X(j) - lon ), ( shapefile(i).Y(j) - lat ) ); % Matlab function
       if( distance < min_dist )          
          closest_index_p2p = i;
          min_dist = distance;
       end
   end
end
toc
disp('Now KdTree')
tic
%Transform coordinates to NAD83
proj = geotiffinfo('boston.tif');
[x,y] = projfwd(proj, lat, lon);
x = x * unitsratio('meter', 'survey feet');
y = y * unitsratio('meter', 'survey feet');
% Use KD-Tree Search
closest_index_kd = knnsearch(kdtree, [x y]);
toc

end

