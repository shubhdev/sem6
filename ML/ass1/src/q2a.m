dat_x = 'data/q3x.dat';
dat_y = 'data/q3y.dat';
alpha = 1e-5;
x = importdata(dat_x);
y = importdata(dat_y);
x = [ones(size(x,1),1) x];

mat1 = transpose(x)*x;
mat2 = transpose(x)*y;
theta = inv(mat1)*mat2;
yy = y;
for i = 1:size(yy,1)
    yy(i) = x(i,:) * theta;
end
plot(x(:,2:end),y,'.',x(:,2:end),yy);