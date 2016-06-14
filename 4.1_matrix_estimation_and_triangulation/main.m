function main
%-----------------------------------------------------------------%
% Comuper Vision Assignment 3                                     %
% Fundamental Matrix Estimation and Triangulation                 %
% Written by Mustafa Mukadam                                      %
%-----------------------------------------------------------------%
clc
clear
%%
%% User Inputs
%%
algo = 2; % 1-unnormalized, 2-normalized
num = 2; % 1-house, 2-library
method = 3; % 1-GroundTruth, 2-RANSAC, 3-Triangulation

%--RANSAC parameters
ht = 0.001; % Harris Threshold
d = 25; % Descriptor Size (d x d)
t = 0.75; % Threshold for Normalized Correlation
rt = 0.001 ; % RANSAC Threshold
sh = 0; % Show harris results

%%
%% load images and match files for the first example
%%
imnames = 'house library';
imnames = strsplit(imnames,' ');
imname = cell2mat(imnames(num));

I1 = imread(['data/' imname '/1.JPG']);
I2 = imread(['data/' imname '/2.JPG']);
matches = load(['data/' imname '/matches.txt']);
% this is a N x 4 file where the first two numbers of each row
% are coordinates of corners in the first image and the last two
% are coordinates of corresponding corners in the second image: 
% matches(i,1:2) is a point in the first image
% matches(i,3:4) is a corresponding point in the second image
N = size(matches,1);

x1 = [matches(:,1:2)';ones(1,N)];
x2 = [matches(:,3:4)';ones(1,N)];

%%
%% display two images side-by-side with matches
%% this code is to help you visualize the matches, you don't need
%% to use it to produce the results for the assignment
%%
% figure, imshow([I1 I2]); hold on;
% plot(matches(:,1), matches(:,2), '+r');
% plot(matches(:,3)+size(I1,2), matches(:,4), '+r');
% line([matches(:,1) matches(:,3) + size(I1,2)]', matches(:,[2 4])', 'Color', 'r');
% hold off
%%
%% display second image with epipolar lines reprojected 
%% from the first image
%%

% first, fit fundamental matrix to the matches
if (method==1)
    F = fit_fundamental(x1,x2,algo); % this is a function that you should write
    % Calculate residual error
    r = 0;
    for i=1:N
        r = r + (x2(:,i)'*F*x1(:,i)).^2;
    end
    Residual = r
end
if (method==2)
    %------------------Feature Detection and Matching-----------------%
    im1 = rgb2gray(im2double(I1));
    im2 = rgb2gray(im2double(I2));

    [D1,D2] = getMatches(im1,im2,ht,d,t,sh);
    Number_of_Matches = size(D1,2)

    %----------------------------RANSAC-------------------------------%
    [F, inliers] = ransac(D2,D1,rt);
    Number_of_Inliers = size(inliers,2)
    Inlier_ratio = Number_of_Inliers/Number_of_Matches
    Residual = mean(inliers)

    matches = [D1(1:2,:); D2(1:2,:)]';
    N = size(matches,1);
end
if (method == 1 || method == 2)
    L = (F * [matches(:,1:2) ones(N,1)]')'; % transform points from 
    % the first image to get epipolar lines in the second image

    % find points on epipolar lines L closest to matches(:,3:4)
    L = L ./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); % rescale the line
    pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
    closest_pt = matches(:,3:4) - L(:,1:2) .* repmat(pt_line_dist, 1, 2);

    % find endpoints of segment on epipolar line (for display purposes)
    pt1 = closest_pt - [L(:,2) -L(:,1)] * 10; % offset from the closest point is 10 pixels
    pt2 = closest_pt + [L(:,2) -L(:,1)] * 10;

    % display points and segments of corresponding epipolar lines
    h = figure; imshow(I2); hold on;
    plot(matches(:,3), matches(:,4), '+r');
    line([matches(:,3) closest_pt(:,1)]', [matches(:,4) closest_pt(:,2)]', 'Color', 'r');
    line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');
    if (method == 1)
        name = strcat('results/',num2str(num),'_',num2str(algo),'_',num2str(method),'_',num2str(Residual),'.jpg');
    end
    if (method == 2)
        name = strcat('results/',num2str(num),'_',num2str(algo),'_',num2str(method),'_',num2str(Number_of_Inliers),'_',num2str(Residual),'.jpg');
    end
    savefig(name);
    hold off
end
if (method == 3)
    p1 = load(['data/' imname '/1_camera.txt']);
    p2 = load(['data/' imname '/2_camera.txt']);
    %---Get camera Centers
    [U,D,V] = svd(p1,0);
    c1 = V(:,end);
    c1 = c1./c1(4);
    [U,D,V] = svd(p2,0);
    c2 = V(:,end);
    c2 = c2./c2(4);
    %---Solve for 3D data
    X = zeros(4,N);
    for i=1:N
        A = [x1(1,i)*p1(3,:) - p1(1,:);
             x1(2,i)*p1(3,:) - p1(2,:);
             x2(1,i)*p2(3,:) - p2(1,:);
             x2(2,i)*p2(3,:) - p2(2,:)];
        
        [U,D,V] = svd(A,0);
        X(:,i) = V(:,end);
        X(:,i) = X(:,i)./X(4,i);
    end
    %---Calculate residual
    Total_Residual = getResidual(x1,p1,X,I1,1,num) + getResidual(x2,p2,X,I2,2,num)
    %---Plot reconstruction
    if (num == 1)
        X(2,:) = -1*X(2,:);
        c1(2) = -1*c1(2);
        c2(2) = -1*c2(2);
    end
    figure, scatter3(X(1,:),X(2,:),X(3,:),10,'fill');
    hold on
    scatter3(c1(1),c1(2),c1(3),'r','fill');
    scatter3(c2(1),c2(2),c2(3),'g','fill');
    legend('Data','Camera 1','Camera 2')
    axis equal
end

disp('Done');
end

function r = getResidual(x,T,X,I,i,num)
%---x = T*X is the form
newx = (T*X);
newx(1,:) = newx(1,:)./newx(3,:);
newx(2,:) = newx(2,:)./newx(3,:);
newx(3,:) = newx(3,:)./newx(3,:);
r = sum(sqrt(sum((x - newx).^2)));

figure, imshow(I)
hold on
scatter(x(1,:),x(2,:),10,'fill','b');
scatter(newx(1,:),newx(2,:),10,'fill','r');
name = ['results/',num2str(num),'_',num2str(i),'.jpg'];
savefig(name)

end

function savefig(name)

AxesH = gca;
F = getframe(AxesH);
imwrite(F.cdata,name);

end