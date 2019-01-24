function L_Matrix = create_laplace(A)
% Create Laplace Matrix 
N_2 = size(A,1);
L_Matrix = zeros(N_2, N_2);

for i = 1 : N_2
    for j = i + 1 : N_2
       if A(i,j) > 0
          L_Matrix(i,j) = -1;
          L_Matrix(j,i) = -1;
       end
    end
end
% Diagonale
for i = 1 : N_2
   L_Matrix(i,i) = abs(sum(L_Matrix(:,i)));
end
end

