function im = stitch(im1,im2,H)
%-----------------------------------------------------------------%
% Stitches im1 and im2 with tranformation H and returns new       %
% blended image im, in color                                      %        %
%-----------------------------------------------------------------%

T = maketform('projective',H');
[im2t,xdataim2t,ydataim2t]=imtransform(im2,T,'XYScale',1);
% xdataim2t and ydataim2t store the bounds of the transformed im2
xdataout=[min(1,xdataim2t(1)) max(size(im1,2),xdataim2t(2))];
ydataout=[min(1,ydataim2t(1)) max(size(im1,1),ydataim2t(2))];
% transform both images with the computed xdata and ydata
im2t=imtransform(im2,T,'XData',xdataout,'YData',ydataout,'XYScale',1);
im1t=imtransform(im1,maketform('affine',eye(3)),'XData',xdataout,'YData',ydataout,'XYScale',1);

o = [0 0 0];
a = 0;

for i=1:size(im1t,1)
    for j=1:size(im1t,2)
        v1 = [im1t(i,j,1) im1t(i,j,2) im1t(i,j,3)];
        v2 = [im2t(i,j,1) im2t(i,j,2) im2t(i,j,3)];
        if (isequal(v1,o) == 0 && isequal(v2,o) == 1)
            im(i,j,:) = (1-a).*im1t(i,j,:) + a.*im2t(i,j,:);
        else if (isequal(v1,o) == 1 && isequal(v2,o) == 0)
                im(i,j,:) = (1-a).*im2t(i,j,:) + a.*im1t(i,j,:);
            else
                im(i,j,:) = (im1t(i,j,:)+im2t(i,j,:))/2;
            end
        end
    end
end

end