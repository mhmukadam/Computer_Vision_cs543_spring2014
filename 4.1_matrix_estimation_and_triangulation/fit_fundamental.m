function F = fit_fundamental(x1,x2,algo)

N = size(x1,2);

if (algo == 2)
    [x1,T1] = normalize(x1);
    [x2,T2] = normalize(x2);
end

A = [x2(1,:)'.*x1(1,:)'   x2(1,:)'.*x1(2,:)'  x2(1,:)' ...
     x2(2,:)'.*x1(1,:)'   x2(2,:)'.*x1(2,:)'  x2(2,:)' ...
     x1(1,:)'             x1(2,:)'            ones(N,1) ];       


[U,D,V] = svd(A,0);
F = reshape(V(:,9),3,3)';

% % non-Homogeneous form (don't use)
% A = A(:,1:end-1);
% b = -1*ones(N,1);
% F = [A\b;1];
% F = reshape(F,3,3)';

% Enforce rank-2 constraint
[U,D,V] = svd(F,0);
F = U*diag([D(1,1) D(2,2) 0])*V';

if (algo == 2)
% Denormalise
    F = T2'*F*T1;
end

end