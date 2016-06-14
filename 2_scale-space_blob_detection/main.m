function main
%-----------------------------------------------------------------%
% Comuper Vision Assignment 2                                     %
% Scale Space Blob Detection                                      %
% Written by Mustafa Mukadam                                      %
%-----------------------------------------------------------------%
clear
clc
tic
%----------------------------User Inputs--------------------------%
% Image to process
% 1: butterfly
% 2: einstein
% 3: fishes
% 4: sunflower
% 5: lena
% 6: monalisa
% 7: matrix
% 8: uofi
% 9: oscars
num = 1; % Put image number here

sigma_init = 2; % Initial sigma of gaussian

level = 15; % Number of level in scale space

k = 1.24; % Scale factor

method = 2; % 1: increase filter size, 2: downsample image

t = 0.0004; % 1: 0.01, 2: 0.0004 threshold

%--------------------Loading and Pre-processing-------------------%
root_path = '/Users/mustafamukadam/Documents/MATLAB/Computer Vision/assignment2/assignment2_images/';
imnames = 'butterfly.jpg einstein.jpg fishes.jpg sunflowers.jpg lena.jpg monalisa.jpg matrix.jpg uofi.jpg oscars.jpg';
imnames = strsplit(imnames,' ');
imname = cell2mat(imnames(num));

im = im2double(rgb2gray(imread([root_path imname])));
h = size(im,1);
w = size(im,2);

%---------------------Filtering and Scale Space-------------------%
scale_space = zeros(h,w,level);
sigma = zeros(1,level);
sigma(1) = sigma_init;

%---Method 1: Increase filter size
if (method == 1)
    for i=1:level
        %---make sure filter size is odd
        filter_size = round(6*sigma(i));
        if (mod(filter_size,2) == 0)
            filter_size = filter_size + 1;
        end
        %---filter and convolve
        lofg = sigma(i)*sigma(i)*fspecial('log', filter_size, sigma(i));
        scale_space(:,:,i) = conv2(im,lofg,'same').^2;
        %---scale sigma
        sigma(i+1) = sigma(i)*k;
    end
end

%---Method 2: Downsample image
if (method == 2)
    %---make sure filter size is odd
    filter_size = round(6*sigma_init);
    if (mod(filter_size,2) == 0)
        filter_size = filter_size + 1;
    end
    lofg = fspecial('log', filter_size, sigma_init); % (sigma^2) scale normalization not needed
    for i=1:level
        im_curr = imresize(im,(1/k)^(i-1));
        temp = conv2(im_curr,lofg,'same').^2;
        scale_space(:,:,i) = imresize(temp,[h w]); % Back to original size
        %---scale sigma for later use (to calculate radii)
        sigma(i+1) = sigma(i)*k;
    end
end

sigma = sigma(1:level);

%---------------------Non-Maximum Suppression---------------------%
mx = zeros(h,w,level); % maximum filter layers
X = zeros(h,w,level); % non-maximum suppressed layers
pixel_loc = zeros(1,3); % blob centre locations

%---Get maximum filter layers
for i=1:level
    temp = scale_space(:,:,i);
    mx(:,:,i) = ordfilt2(temp,9,ones(3)); % Maximum filter
end

%---Create a mask filter to get rid of noise on the boundaries
mask = zeros(h,w,level);
for i=1:level
    ms = ceil((sqrt(2))*sigma(i));
    mask((ms+1):(h-ms),(ms+1):(w-ms),i) = ones(h-2*ms,w-2*ms);
end

%---Non-maximum suppression
for i=1:level
    temp = scale_space(:,:,i);
    if (i>1 && i<level)
        X(:,:,i) = (temp==mx(:,:,i))&(temp>mx(:,:,i-1))&(temp>mx(:,:,i+1))&(temp>t)&(mask(:,:,i));
    elseif (i==1)
        X(:,:,i) = (temp==mx(:,:,i))&(temp>mx(:,:,i+1))&(temp>t)&(mask(:,:,i));
    else
        X(:,:,i) = (temp==mx(:,:,i))&(temp>mx(:,:,i-1))&(temp>t)&(mask(:,:,i));
    end
    [r,c] = find(X(:,:,i));
    l = i*ones(size(r,1),1);
    pixel_loc = [pixel_loc; [r,c,l]];
end
pixel_loc = pixel_loc(2:end,:);


%-----------------------------Results-----------------------------%
for i=1:size(pixel_loc,1)
    pixel_loc(i,3) = sqrt(2)*sigma(pixel_loc(i,3));
end

h = figure(1);
show_all_circles(im,pixel_loc(:,2),pixel_loc(:,1),pixel_loc(:,3));
time = toc;

name = strcat('Results/',imname(1:end-4),'_',num2str(method),'_',num2str(t),'_',num2str(time),'.jpg');
saveas(h,name,'jpg');

end