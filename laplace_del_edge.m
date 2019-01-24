function L_Matrix  = laplace_del_edge(L_Matrix, i,j)
    L_Matrix(i,j) = 0;
    L_Matrix(j,i) = 0;
    L_Matrix(i,i) = L_Matrix(i,i) - 1;
    L_Matrix(j,j) = L_Matrix(j,j) - 1;
    
end

