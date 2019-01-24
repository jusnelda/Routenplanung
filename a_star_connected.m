function CLOSED = a_star_connected(start_idx, shapefile, L, A, proj)

tic

N = length(shapefile);
start_idx = 430;

% This implementation is based on indeces, i.e. all lists have the same
% indeces as L
START = [L(start_idx).x, L(start_idx).y];

L(start_idx).parent_x = START(1); % Parent of the start node is itself
L(start_idx).parent_y = START(2); 
% Distance from this node is 0 in case of the start node g(n) = 0
path_cost_g = 0;
L(start_idx).g = path_cost_g;
% Beeline is zero, because we don't have a destination
goal_distance_h = 0;
L(start_idx).h = goal_distance_h;
L(start_idx).f = path_cost_g + goal_distance_h;
% Closed List is the same size as L and only contains bools, which tells you
% if the node is in the CLOSED List or not like this CLOSED = (false, false, true,...)
CLOSED = zeros(2*N,1);
% OPEN List is initially empty
OPEN = [];
% Fill OPEN with start node
OPEN(1,1) = start_idx;
OPEN(1,2) = L(start_idx).f;
x_all = [];
y_all = [];

while isempty(OPEN) == false
    
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
            goal_distance_h = 0;
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
    
%     open_indezes = OPEN(:,1);
% 
%     all_open_idx(end + 1 : end +length(OPEN), 1) = OPEN(:,1);
%     for c = 1 : length(open_indezes)
%         x_current(c) = L(open_indezes(c)).x * unitsratio('survey feet', 'meter');
%         y_current(c) = L(open_indezes(c)).y * unitsratio('survey feet', 'meter');
% 
%     end
%     
%     for b = 1 : length(x_current)
%         x_all(end + 1,1) = x_current(b);
%         y_all(end + 1,1) = y_current(b);
%     end
   
end % end while loop (isEmpty(OPEN) == false)
%     x_unique = unique(x_all);
%     y_unique = unique(y_all);

end

