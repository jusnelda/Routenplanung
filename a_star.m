function final_path = a_star( start_idx, goal_idx, shapefile, L, A, proj )
tic

N = length(shapefile);

% This implementation is based on indeces, i.e. all lists have the same
% indeces as L
START = [L(start_idx).x, L(start_idx).y];
GOAL = [L(goal_idx).x, L(goal_idx).y];

L(start_idx).parent_x = START(1); % Parent of the start node is itself
L(start_idx).parent_y = START(2); 
% Distance from this node is 0 in case of the start node g(n) = 0
path_cost_g = 0;
L(start_idx).g = path_cost_g;
% Beeline from start node to destination node
goal_distance_h = distance_to_goal(START,GOAL);
L(start_idx).h = goal_distance_h;
L(start_idx).f = path_cost_g + goal_distance_h;
% Closed List is the same size as L and only contains bools, which tell you
% if the node is in the CLOSED List or not like this CLOSED = (false, false, true,...)
CLOSED = zeros(2*N,1);
% OPEN List is initially empty
OPEN = [];
% Fill OPEN with start node
OPEN(1,1) = start_idx;
OPEN(1,2) = L(start_idx).f;
path_found = 0;

while path_found == 0
    
    [min_cost,min_index] = min(OPEN(:,2));
%   current_node layout = [index in L vector | cost (f)]
    current_node = OPEN(min_index,:);
    OPEN(min_index,:) = [];
    CLOSED(current_node(1,1)) = 1;
    current_idx = current_node(1,1);
    
    for a = 1 : 2*N
        local_g = A(current_idx, a);
        if local_g > 0 && CLOSED(a) == 0
%           Set costs for current neighbor node
            path_cost_g     = L(current_idx).g + local_g;
            goal_distance_h = distance_to_goal([L(a).x, L(a).y], GOAL);
            current_f       = path_cost_g + goal_distance_h;
            
            % Add neighbor node to OPEN List, if it's not already in there
            k = find(OPEN(:,1) == a); % return index of element found in OPEN
            if isempty(k)
                if isempty(OPEN)
                    OPEN(1,:) = [a, current_f];
                else
                    OPEN(end+1,:) = [a, current_f];
                end
%               Update L vector with new neighbor node
                L(a).g = path_cost_g;
                L(a).h = goal_distance_h;
                L(a).f = current_f;
                L(a).parent_x = L(current_idx).x;
                L(a).parent_y = L(current_idx).y;
                L(a).parent_index = current_idx;
            else
%               Compare costs
                old_f = OPEN(k,2);
                if current_f < old_f
                    OPEN(k,2) = current_f;
                    L(a).g = path_cost_g;
                    L(a).h = goal_distance_h;
                    L(a).f = current_f;
                    L(a).parent_x = L(current_idx).x;
                    L(a).parent_y = L(current_idx).y;
                    L(a).parent_index = current_idx;
                end % if current_f < old_f
            end % if isempty(k)            
        end % end if to find neighbor node in A Matrix
    end % end A Matrix for loop
    
%%%%%%%%%%%%%%%%%%%%% Plot OPEN List on the fly %%%%%%%%%%%%%%%%%%%%%%%%%%%
    open_indezes = OPEN(:,1);
    for c = 1 : length(open_indezes)
        x_current(c) = L(open_indezes(c)).x * unitsratio('survey feet', 'meter');
        y_current(c) = L(open_indezes(c)).y * unitsratio('survey feet', 'meter');        
    end
    [lat_current,lon_current] = projinv(proj,x_current,y_current);
    figure(4)
    OPEN_list_plot = geoshow(lat_current, lon_current, 'DisplayType', 'point', 'Marker', '.',...
        'MarkerSize', 10, 'MarkerEdgeColor','red');
    legend(OPEN_list_plot, 'OPEN List');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%   Destination found
    if current_idx == goal_idx
        path_found = 1;
        disp(['Destination reached in: ', num2str(toc), ' seconds.']);
    end % if current_idx == goal_idx    
end % end while loop (path_found == 0)

% Compute final path
final_path(1,:) = [L(goal_idx).x, L(goal_idx).y, goal_idx];
final_parent_index = L(goal_idx).parent_index;
while final_parent_index ~= start_idx
    final_path(end+1,:) = [L(final_parent_index).x, L(final_parent_index).y, final_parent_index];
    final_parent_index = L(final_parent_index).parent_index;
end
final_path(end+1,:) = [L(start_idx).x, L(start_idx).y, start_idx];
final_path(1,4) = OPEN_list_plot;

end

