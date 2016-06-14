function main
%-----------------------------------------------------------------%
% Comuper Vision Assignment 3                                     %
% Affine Factorization                                            %
% Written by Mustafa Mukadam                                      %
%-----------------------------------------------------------------%
clear
clc
%---------------------Loading and Preprocessing-------------------%
Ddata = load('data/measurement_matrix.txt');
[m,n] = size(Ddata);
m=m/2;

%-----------------------Normalize Coordinates---------------------%
D = Ddata - (ones(n,1)*(mean(Ddata,2))')';
Ddata = D;

%-----------------------Structure from Motion---------------------%
[U,W,V] = svd(D);
U = U(:,1:3);
W = W(1:3,1:3);
V = V(:,1:3)';

D = U*W*V;
M = U;
S = W*V;
%---3D plot
figure, scatter3(S(1,:),S(2,:),S(3,:)*10,10,'fill')
axis equal

%---Difference in original and projected
figure, scatter(Ddata(1,:),Ddata(2,:),10,'fill','b');
hold on; axis equal
scatter(D(1,:),D(2,:),10,'fill','r');
title('Frame 1');
legend('Original 2D point','Projected 3D point')

figure, scatter(Ddata(99,:),Ddata(100,:),10,'fill','b');
hold on; axis equal
scatter(D(99,:),D(100,:),10,'fill','r');
title('Frame 50');
legend('Original 2D point','Projected 3D point')

figure, scatter(Ddata(201,:),Ddata(202,:),10,'fill','b');
hold on; axis equal
scatter(D(201,:),D(202,:),10,'fill','r');
title('Frame 101');
legend('Original 2D point','Projected 3D point')

%---Residual plot
j = 1;
for i=1:2:202
    r(j) = sum(sqrt(sum((D(i:i+1,:)-Ddata(i:i+1,:)).^2)));    
    j = j + 1;
end
figure, plot(1:m,r);
xlabel('Frame Number')
ylabel('Total Residual')
title('Residual Plot')
dlmwrite('results/r.txt',r)

disp('Done');
end