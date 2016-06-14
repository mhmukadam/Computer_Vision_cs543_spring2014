function main
%-----------------------------------------------------------------%
% Comuper Vision Assignment 3                                     %
% Window Based Stereo Matching                                    %
% Written by Mustafa Mukadam                                      %
%-----------------------------------------------------------------%
clear
clc
tic
%---------------------------User Inputs---------------------------%

w = 5; % Window size
d = 50; % disparity range (15)
m = 2; % 1-Normalized Correlation, 2-SSD (2)

%---------------------Loading and Preprocessing-------------------%
im1 = im2double(rgb2gray(imread('data/1.JPG')));
im2 = im2double(rgb2gray(imread('data/2.JPG')));
[r,c] = size(im1);

rs = ceil(w/2); % start row
re = ceil(r-w/2); % end row
cs = ceil(w/2); % start column
ce = ceil(c-w/2); % end column

%--------------------------Form Descriptors-----------------------%
descriptor1 = cell(r,c);
descriptor2 = cell(r,c);
w = floor(w/2);
for i=rs:re
    for j=cs:ce
        descriptor1{i,j} = reshape(im1(i-w:i+w,j-w:j+w),[(w*2+1)^2 1]);
        descriptor2{i,j} = reshape(im2(i-w:i+w,j-w:j+w),[(w*2+1)^2 1]);
    end
end
w = w*2+1;

%-------------------------Form Diparity Map-----------------------%
depth = zeros(r,c);
for a=rs:re
    disp(a);
    for b=cs:ce
        u = descriptor1{a,b};
        ubar = mean(u)*ones(size(descriptor1{a,b}));
        X = zeros(d,1);
        if (m == 1) % Normalized Correlation
            for i=1:d
                if (b-i+1 < rs)
                    X(i) = 0;
                    continue;
                end
                v = descriptor2{a,b-i+1};
                vbar = mean(v)*ones(size(descriptor2{a,b-i+1}));
                X(i) = sum((u-ubar).*(v-vbar))/(sqrt(sum((u-ubar).^2))*sqrt(sum((v-vbar).^2)));
            end
            x = b - find(X==max(X),1) + 1;
        end
        if (m == 2) % SSD
            for i=1:d
                if (b-i+1 < rs)
                    X(i) = 100000;
                    continue;
                end
                v = descriptor2{a,b-i+1};
                X(i) = sum((u-v).^2);
            end
            x = b - find(X==min(X),1) + 1;
        end      
        if ((b-x) ~= 0)
            depth(a,b) = 1/(b-x);
        end
    end
end

%------------------------------Results----------------------------%
Time_elapsed = toc

pause;
name = strcat('results/',num2str(w),'_',num2str(d),'_',num2str(m),'_',num2str(Time_elapsed),'.jpg');
show(depth,name);

disp('Done');
end


function show(im,name)

figure, imshow(im)
AxesH = gca;
F = getframe(AxesH);
imwrite(F.cdata,name);

end