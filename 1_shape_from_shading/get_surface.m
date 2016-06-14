function  height_map = get_surface(surface_normals, image_size, method)
% surface_normals: h x w x 3
% image_size: [h, w] of output height map/image
% height_map: height map of object

    
%% <<< fill in your code below >>>
tic

fun = @(A,B) A./B;
fx = bsxfun(fun,surface_normals(:,:,1),surface_normals(:,:,3));
fy = bsxfun(fun,surface_normals(:,:,2),surface_normals(:,:,3));

method = strsplit(method,'_');
if (strcmp(cell2mat(method(1)),'random'))
    paths = str2num(cell2mat(method(2)));
end
method = cell2mat(method(1));

switch method
    %--------------------------------
    case 'column'
        for r=1:image_size(1)
            for c=1:image_size(2)
                sumx = cumsum(fx(r,1:c));
                sumy = cumsum(fy(1:r,1));
                height_map(r,c) = sumy(end) + sumx(end);
            end
        end
    %--------------------------------    
    case 'row'
        for r=1:image_size(1)
            for c=1:image_size(2)
                sumx = cumsum(fx(1,1:c));
                sumy = cumsum(fy(1:r,c));
                height_map(r,c) = sumx(end) + sumy(end);
            end
        end
    %--------------------------------   
    case 'average'
        for r=1:image_size(1)
            for c=1:image_size(2)
                sumx_c = cumsum(fx(r,1:c));
                sumy_c = cumsum(fy(1:r,1));
                sumx_r = cumsum(fx(1,1:c));
                sumy_r = cumsum(fy(1:r,c));
                height_map(r,c) = 0.5*(sumy_c(end) + sumx_c(end) + sumx_r(end) + sumy_r(end));
            end
        end
    %--------------------------------    
    case 'random'
        for i=1:paths
            for r=1:image_size(1)
                for c=1:image_size(2)
                    % for every pixel
                    a=1;
                    b=1;
                    height_map(r,c,i) = fx(a,b) + fy(a,b);
                    while (a<r && b<c)
                       if (rand(1) < 0.5)
                           a = a + 1;
                           height_map(r,c,i) = height_map(r,c,i) + fy(a,b);
                       else
                           b = b + 1;
                           height_map(r,c,i) = height_map(r,c,i) + fx(a,b);
                       end
                       if (a == r)
                           sumx = cumsum(fx(r,b:c));
                           height_map(r,c,i) = height_map(r,c,i) + sumx(end);
                       end
                       if (b == c)
                           sumy = cumsum(fy(a:r,c));
                           height_map(r,c,i) = height_map(r,c,i) + sumy(end);
                       end
                    end
                end
            end
            norm_data(i) = norm(sum(height_map,3)./i); % Takes the average up to this point
        end
        % Taking average of multiple paths
        height_map = sum(height_map,3)./paths;
        % Potting norm error
        if (paths>1)
            x=1:paths-1;
            for i=1:paths-1
                y(i) = norm_data(i+1) - norm_data(i);
            end
            plot(x,y);
        end
    %--------------------------------
end

toc

end