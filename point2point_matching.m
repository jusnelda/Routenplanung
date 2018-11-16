function closest_index = point2point_matching( x, y, shapefile )
% function that returns the index of the closest point to the clicked (x,y) 
% in the shapefile

min_dist = inf;
for i = 1 : length( shapefile )
   for j = 1 : length( shapefile(i).X )
       
       % calculate distance
       distance = hypot( ( shapefile(i).X(j) - x ), ( shapefile(i).Y(j) - y ) ); % Matlab function
       if( distance < min_dist )          
          closest_index = i;
          min_dist = distance;
       end
   end
end

end

