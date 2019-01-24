function isLaplace = checkLaplace(Laplace_Matrix)

[evec, eval] = eig(Laplace_Matrix);
% check eigenvals

if min(eval) < 0 
    isLaplace = 0;
elseif (Laplace_Matrix * evec) ~= 0
    isLaplace = 0;
elseif min(eval) ~= 0
    isLaplace = 0;
else
    isLaplace = 1;
end

if eval(2,2) > 0
    disp('Graph zusammenhängend')
else
    disp('Graph nicht zusammenhängend')
end
end