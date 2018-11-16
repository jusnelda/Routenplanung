function [distance] = distance_to_goal(Start,Ziel)
distance = sqrt( (Ziel(1) - Start(1))^2  + (Ziel(2) - Start(2))^2 );
end

