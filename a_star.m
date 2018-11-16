function final_path = a_star(start_idx, ziel_idx, shpfile,L,A,proj)

% A *
% INIT
tic
N = length(shpfile);
% Die Implementierung ist Indexbasiert, d.h. alle Listen haben die
% gleichen Indezes wie L

START = [L(start_idx).x, L(start_idx).y];
ZIEL = [L(ziel_idx).x, L(ziel_idx).y];

L(start_idx).parent_x = START(1); % Fuer den Startknoten ist er selbst der parent
L(start_idx).parent_y = START(2); % y
path_cost_g = 0; % Weil Startknoten g(n) = 0 (Distanz zu diesem Knoten)
L(start_idx).g = path_cost_g;
goal_distance_h = distance_to_goal(START,ZIEL); % Luftlinie
L(start_idx).h = goal_distance_h;
L(start_idx).f = path_cost_g + goal_distance_h;
% Closed List beinhaltet nur, ob der Knoten mit dem entsprechenden Index in
% der CLOSED list ist oder nicht z.B. CLOSED = (false, false, true,...)
CLOSED = zeros(2*N,1);
OPEN = [];
OPEN(1,1) = start_idx;
OPEN(1,2) = L(start_idx).f;
path_found = 0; % wird true gesetzt, wenn Ziel gefunden wurde

while path_found == 0
    
    [min_cost,min_index] = min(OPEN(:,2));
    current_node = OPEN(min_index,:); % current_node = [index in L vector | Kosten (f)]
    OPEN(min_index,:) = [];
    CLOSED(current_node(1,1)) = 1;
    current_idx = current_node(1,1);
    
    for a = 1 : 2*N
        local_g = A(current_idx, a);
        if local_g > 0 && CLOSED(a) == 0
            
            path_cost_g = L(current_idx).g + local_g;
            goal_distance_h = distance_to_goal([L(a).x, L(a).y], ZIEL);
            current_f = path_cost_g + goal_distance_h;
            
            % Knoten a zur OPEN Liste hinzufuegen, falls er noch nicht drin
            % ist
            k = find(OPEN(:,1) == a);
            if isempty(k)
                if isempty(OPEN)
                    OPEN(1,:) = [a, current_f];
                else
                    OPEN(end+1,:) = [a, current_f];
                end
                L(a).g = path_cost_g;
                L(a).h = goal_distance_h;
                L(a).f = current_f;
                L(a).parent_x = L(current_idx).x;
                L(a).parent_y = L(current_idx).y;
                L(a).parent_index = current_idx;
            else
                % Kosten vergleichen
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
            
        end % end if um Knoten in A Matrix zu finden
    end % end A Matrix for schleife
    
    %%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%
    open_indezes = OPEN(:,1);
    for c = 1 : length(open_indezes)
        x_current(c) = L(open_indezes(c)).x * unitsratio('survey feet', 'meter');
        y_current(c) = L(open_indezes(c)).y * unitsratio('survey feet', 'meter');
        
    end
    [lat_current,lon_current] = projinv(proj,x_current,y_current);
    figure(4)
    geoshow(lat_current, lon_current, 'DisplayType', 'point', 'Marker', '.',...
        'MarkerSize', 10, 'MarkerEdgeColor','red')
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Ziel gefunden
    if current_idx == ziel_idx
        path_found = 1;
        disp('Am Ziel angekommen');
    end % if current_idx == ziel_idx
    
end % end while loop (path_found == 0)

final_path(1,:) = [L(ziel_idx).x, L(ziel_idx).y, ziel_idx];
final_parent_index = L(ziel_idx).parent_index;
while final_parent_index ~= start_idx
    final_path(end+1,:) = [L(final_parent_index).x, L(final_parent_index).y, final_parent_index];
    final_parent_index = L(final_parent_index).parent_index;
end
final_path(end+1,:) = [L(start_idx).x, L(start_idx).y, start_idx];

end

