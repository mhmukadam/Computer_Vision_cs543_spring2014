function [H, inliers, sample] = ransac(D1, D2, rt)
%-----------------------------------------------------------------%
% RANSAC on data set D1, D2 with threshold for inliers as         %
% rt pixels                                                       %
%-----------------------------------------------------------------%

%------------------------Set Parameters---------------------------%
D = [D1;D2];
n = size(D,2);
bestH = NaN;
sample = NaN;
count = 0;
bestninliers =  0;
N = 1000; % Max iterations

%--------------------------Run RANSAC-----------------------------%
while count < N
    %-----Sample 4 matches
    s = randsample(n,4);
    x = D(1,s);
    y = D(2,s);
    xp = D(4,s);
    yp = D(5,s);
    A = [0 0 0 x(1) y(1) 1 -yp(1)*x(1) -yp(1)*y(1) -yp(1);
         x(1) y(1) 1 0 0 0 -xp(1)*x(1) -xp(1)*y(1) -xp(1);
         0 0 0 x(2) y(2) 1 -yp(2)*x(2) -yp(2)*y(2) -yp(2);
         x(2) y(2) 1 0 0 0 -xp(2)*x(2) -xp(2)*y(2) -xp(2);
         0 0 0 x(3) y(3) 1 -yp(3)*x(3) -yp(3)*y(3) -yp(3);
         x(3) y(3) 1 0 0 0 -xp(3)*x(3) -xp(3)*y(3) -xp(3);
         0 0 0 x(4) y(4) 1 -yp(4)*x(4) -yp(4)*y(4) -yp(4);
         x(4) y(4) 1 0 0 0 -xp(4)*x(4) -xp(4)*y(4) -xp(4)];
    
    %-----Compute Homography
    [U,S,V] = svd(A,0);
    H = reshape(V(:,9),3,3)';
    
    %-----Skip solution if sample was degenerate
    if (rank(H) < 3)
        continue;
    end
    
    %-----Calculate squared difference for forward and inverse tranformation
    newD2 = H*D1;
    newD2(1,:) = newD2(1,:)./newD2(3,:);
    newD2(2,:) = newD2(2,:)./newD2(3,:);
    newD2(3,:) = newD2(3,:)./newD2(3,:);

    newD1 = H\D2;
    newD1(1,:) = newD1(1,:)./newD1(3,:);
    newD1(2,:) = newD1(2,:)./newD1(3,:);
    newD1(3,:) = newD1(3,:)./newD1(3,:);

    SD = sum((newD2 - D2).^2) + sum((newD1 - D1).^2);
    
    %-----Check inliers with threashold rt   
    inliers = find(abs(SD) < rt); 
    inliers = SD(inliers);
    
    %-----Save solution if best so far
    ninliers = length(inliers);
    if ninliers > bestninliers
        bestninliers = ninliers;
        bestinliers = inliers;
        bestH = H;
        sample = D(:,s);
    end
    
    %-----Increment iteration count
    count = count + 1;
end

H = bestH;
inliers = bestinliers;

end