function [albedo_image, surface_normals] = photometric_stereo(imarray, light_dirs)
% imarray: h x w x Nimages array of Nimages no. of images
% light_dirs: Nimages x 3 array of light source directions
% albedo_image: h x w image
% surface_normals: h x w x 3 array of unit surface normals


%% <<< fill in your code below >>>

h = size(imarray,1);
w = size(imarray,2);
N = size(imarray,3);

imarray = permute(imarray,[3 1 2]);
imarray = reshape(imarray,[N h*w]);

g = light_dirs\imarray;

albedo_image = sqrt(g(1,:).^2 + g(2,:).^2 + g(3,:).^2);
fun = @(A,B) A./B;
surface_normals = bsxfun(fun,g,albedo_image);

albedo_image = reshape(albedo_image,[h w]);
surface_normals = permute(surface_normals,[2 1]);
surface_normals = reshape(surface_normals,[h w 3]);

end