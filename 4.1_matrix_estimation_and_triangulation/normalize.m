function [newx,T] = normalize(x)

c = mean(transpose(x(1:2,:)))';
newp(1,:) = x(1,:)-c(1);
newp(2,:) = x(2,:)-c(2);

dist = sqrt(newp(1,:).^2 + newp(2,:).^2);

scale = sqrt(2)/mean(dist);

T = [scale   0   -scale*c(1);
     0     scale -scale*c(2);
     0       0      1       ];
 
newx = T*x;

end