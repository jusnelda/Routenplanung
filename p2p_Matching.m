function p2p = p2p_Matching(x, y, shapefile)


%Init
d_min = inf;
for i = 1:length(shapefile)
   for j = 1:length(shapefile(i).X)
       
       % Berechnung der Distanz
       dist = hypot((shapefile(i).X(j) - x), (shapefile(i).Y(j) - y));
       % Prüfen ob die aktuelle Distanz kleiner als d_min ist
       if(dist < d_min)
          
          p2p = i;
          d_min = dist;
           
       end
   end
end

end

