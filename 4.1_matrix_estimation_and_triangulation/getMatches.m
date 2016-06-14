function [D1,D2] = getMatches(im1,im2,ht,d,t,sh)
%-----------------------------------------------------------------%
% Compute Descriptors (dxd) and return matches in im1 and im2 with%
% threshold t using harris corner detector with threshold ht      %
%-----------------------------------------------------------------%

%-----Detect Corners with Harris Corner Detector
[him1, r1, c1] = harris(im1,3,ht,3,sh);
[him2, r2, c2] = harris(im2,3,ht,3,sh);

%-----Form descriptors of size dxd
descriptor1 = cell(size(r1));
descriptor2 = cell(size(r2));

d = floor(d/2);
for i=1:size(descriptor1)
    a = r1(i);
    b = c1(i);
    descriptor1{i} = reshape(im1(a-d:a+d,b-d:b+d),[(d*2+1)^2 1]);
end
for i=1:size(descriptor2)
    a = r2(i);
    b = c2(i);
    descriptor2{i} = reshape(im2(a-d:a+d,b-d:b+d),[(d*2+1)^2 1]);
end

%-----Find putative matches with Normalized Correlation
X = zeros(size(descriptor1,1),size(descriptor2,1));
for i=1:size(descriptor1)
    for j=1:size(descriptor2)
        u = descriptor1{i};
        v = descriptor2{j};
        ubar = mean(u)*ones(size(descriptor1{i}));
        vbar = mean(v)*ones(size(descriptor2{j}));
        X(i,j) = sum((u-ubar).*(v-vbar))/(sqrt(sum((u-ubar).^2))*sqrt(sum((v-vbar).^2)));
    end
end

[d1,d2] = find(X>t);

%-----Generate coordinates of matched pixels
for i=1:size(d1,1)
    D1(:,i) = [c1(d1(i));r1(d1(i));1];
    D2(:,i) = [c2(d2(i));r2(d2(i));1];
end

end
