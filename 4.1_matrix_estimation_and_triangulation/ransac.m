function [F, inliers] = ransac(D1, D2, rt)
%-----------------------------------------------------------------%
% RANSAC on data set D1, D2 with threshold for inliers as         %
% rt pixels                                                       %
%-----------------------------------------------------------------%

%------------------------Set Parameters---------------------------%
D = [D1;D2];
n = size(D,2);
bestF = NaN;
sample = NaN;
count = 0;
bestninliers =  0;
N = 1000; % Max iterations

%--------------------------Run RANSAC-----------------------------%
while count < N
    %-----Sample 4 matches
    s = randsample(n,8);
    x1 = D(1:3,s);
    x2 = D(4:6,s);
    F = fit_fundamental(x1,x2,2);
    
    %-----Calculate Residual
    for i=1:n
        res(i) = (D2(:,i)'*F*D1(:,i)).^2;
    end
    
    %-----Check inliers with threashold rt   
    inliers = find(res < rt); 
    inliers = res(inliers);
    
    %-----Save solution if best so far
    ninliers = length(inliers);
    if ninliers > bestninliers
        bestninliers = ninliers;
        bestinliers = inliers;
        bestF = F;
    end
    
    %-----Increment iteration count
    count = count + 1;
end

F = bestF;
inliers = bestinliers;

end