function main
%-----------------------------------------------------------------%
% Comuper Vision Assignment 3                                     %
% Image Stitching                                                 %
% Written by Mustafa Mukadam                                      %
%-----------------------------------------------------------------%
clear
clc
tic
%----------------------------User Inputs--------------------------%
% Data Set to process
% 1: uttower : ht=0.08, d=25, t=0.90, rt=0.5
% 2: hill    : ht=0.01, d=25, t=0.85, rt=0.5
% 3: ledge   : ht=0.01, d=15, t=0.85, rt=0.5
% 4: pier    : ht=0.01, d=25, t=0.85, rt=0.5
p.num = 1; % Put image number here

p.ht = 0.08; % Harris Threshold
p.d = 25; % Descriptor Size (d x d)
p.t = 0.9; % Threshold for Normalized Correlation
p.rt = 0.5 ; % RANSAC Threshold

p.sh = 0; % Show harris results

%--------------------Loading and Pre-processing-------------------%
root_path = '/Users/mustafamukadam/Documents/MATLAB/Computer Vision/assignment3/assignment3_data/';
imnames = 'uttower hill ledge pier';
imnames = strsplit(imnames,' ');
p.imname = cell2mat(imnames(p.num));

im1c = im2double((imread([root_path p.imname '/1.JPG'])));
im2c = im2double((imread([root_path p.imname '/2.JPG'])));
if (p.num > 1)
    im3c = im2double((imread([root_path p.imname '/3.JPG'])));
end

%-------------------------Making Panorama-------------------------%
if (p.num == 1)
    [im,H,data] = compute(im1c,im2c,p);
    No_of_Matches = data.nom
    No_of_Inliers = data.noi
    Inlier_Ratio = data.ir
    Average_Residual = data.ar
    name = strcat('Results/',p.imname,'_',num2str(data.noi),'_',num2str(data.ar),'.jpg');
    show(im,name);
else
    disp('Computing 1 and 2');
    [im12,H12,data12] = compute(im1c,im2c,p);
    IR = data12.ir
    disp('Computing 2 and 3');
    [im23,H23,data23] = compute(im2c,im3c,p);
    IR = data23.ir
    disp('Computing 3 and 1');
    [im31,H31,data31] = compute(im3c,im1c,p);
    IR = data31.ir
    if ((data12.ir >= data23.ir) && (data12.ir >= data31.ir))
        disp('Computing 1+2 and 3');
        [im123,H123,data123] = compute(im12,im3c,p);
        IR = data123.ir
        name = strcat('Results/',p.imname,'123.jpg');
        show(im123,name);
    else if ((data23.ir >= data12.ir) && (data23.ir >= data31.ir))
            disp('Computing 2+3 and 1');
            [im231,H231,data231] = compute(im23,im1c,p);
            IR = data231.ir
            name = strcat('Results/',p.imname,'231.jpg');
            show(im231,name);
        else
            disp('Computing 3+1 and 2');
            [im312,H312,data312] = compute(im31,im2c,p);
            IR = data312.ir
            name = strcat('Results/',p.imname,'312.jpg');
            show(im312,name);
        end
    end
end
    


%----------------------------END----------------------------------%
time_elapsed = toc
disp('Done');

end


function [im,H,data] = compute(im1c,im2c,p)

%-----------------------Convert to GrayScale----------------------%
im1 = rgb2gray(im1c);
im2 = rgb2gray(im2c);

%------------------Feature Detection and Matching-----------------%
[D1,D2] = getMatches(im1,im2,p.ht,p.d,p.t,p.sh);
data.nom = size(D1,2);

%----------------------------RANSAC-------------------------------%
[H, inliers, sample] = ransac(D2,D1,p.rt);
if (p.num == 1)
    figure; axis off; showMatchedFeatures(im1c,im2c,sample(4:5,:)',sample(1:2,:)','montage');
    name = strcat('Results/',p.imname,'_','matches.jpg');
    AxesH = gca;
    F = getframe(AxesH);
    imwrite(F.cdata,name);
end

%--------------------------Final Image---------------------------%
data.noi = size(inliers,2);
data.ir = data.noi/data.nom;
data.ar = mean(inliers);
im = stitch(im1c,im2c,H);

end

function show(im,name)

figure; imshow(im)
AxesH = gca;
F = getframe(AxesH);
imwrite(F.cdata,name);

end