%% Spring 2014 CS 543 Assignment 1
%% Arun Mallya and Svetlana Lazebnik
%% Edited by Mustafa Mukadam
clear
clc
% path to the folder and subfolder
root_path = '/Users/mustafamukadam/Documents/MATLAB/Computer Vision/assignment1_materials/croppedyale/';
subject_name = 'yaleB03';

integration_method = 'random_20'; % 'column', 'row', 'average', 'random_x' (where x is the number of paths)

save_flag = 0; % whether to save output images

%% load images
full_path = sprintf('%s%s/', root_path, subject_name);
[ambient_image, imarray, light_dirs] = LoadFaceImages(full_path, subject_name, 64);
image_size = size(ambient_image);

%% preprocess the data: 
%% subtract ambient_image from each image in imarray
%% make sure no pixel is less than zero
%% rescale values in imarray to be between 0 and 1
%% <<< fill in your preprocessing code here >>>

fun = @(A,B) max(((A-B)/255),0);
imarray = bsxfun(fun,imarray,ambient_image);

%% get albedo and surface normals (you need to fill in photometric_stereo)
[albedo_image, surface_normals] = photometric_stereo(imarray, light_dirs);

%% reconstruct height map (you need to fill in get_surface for different integration methods)
height_map = get_surface(surface_normals, image_size, integration_method);

%% display albedo and surface
display_output(albedo_image, height_map);

%% plot surface normal
plot_surface_normals(surface_normals);

%% save output (optional) -- note that negative values in the normal images will not save correctly!
if save_flag
    imwrite(albedo_image, sprintf('%s_albedo.jpg', subject_name), 'jpg');
    imwrite(surface_normals, sprintf('%s_normals_color.jpg', subject_name), 'jpg');
    imwrite(surface_normals(:,:,1), sprintf('%s_normals_x.jpg', subject_name), 'jpg');
    imwrite(surface_normals(:,:,2), sprintf('%s_normals_y.jpg', subject_name), 'jpg');
    imwrite(surface_normals(:,:,3), sprintf('%s_normals_z.jpg', subject_name), 'jpg');    
end

fprintf('//****Program Completed****// \n');