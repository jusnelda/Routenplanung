function [antTour] = calcAntTour(i, P, A, beta, alpha)
antTour = [i, 0];
N = length(A);
p_niv = zeros(N,N);

% Solange noch Städte (Sehenswuerdigkeiten) offen sind
while ( length(antTour) < N )
    sum = 0;
    V = [0 0];
    
    % Schritt 2a Pheromonniveau berechnen
    for j = 1 : N
        % if (A(i,j) > 0 && j kein Element von AntTour)
        if (A(i,j) > 0 && (isempty(find(antTour == j, 1))) == 1)
            p_niv(i,j) = P(i,j)^alpha * ( 1/A(i,j) )^beta;
            sum = sum + p_niv(i,j);
        end
    end
    p_niv(i,1:N) = p_niv(i,1:N) / sum;
    
    % Schritt 2b Vektor V konstruieren
    for j = 1 : N
        if (A(i,j) > 0 && (isempty(find(antTour == j, 1))) == 1)
            multiplier = floor(p_niv(i,j) * 1000);
            for m = 1 : multiplier
                V(m,:) = [j, A(i,j)];
            end
        end
    end
    
    % Schritt 2c nächstes Wegstück
    % Zufallszahl zwischen 1 und length(V) waehlen
    idx = round( unifrnd( 1, length(V) ) );
    current_node_index = V(idx,1);
    current_path = V(idx,2);
    antTour(end+1, :) = [current_node_index, current_path];

       
end % while length(antTour < N)
antTour(end+1, :) = antTour(1,:);
%save('V', 'V');
antTour = struct('nodes', antTour(:,1), 'paths', antTour(:,2));

end % function

