X = importdata('data/q3x.dat');
Y = importdata('data/q3y.dat');
plot(X,Y,'.');
hold on;
m = size(X,1);
n = size(X,2);
W = zeros(m,m);
X = [ ones(m,1) X];
bdw = 10 ;
xrange = -7:0.2:14;
yrange = ones(length(xrange),1);
for t = 1:length(xrange)
    x = xrange(t);
    for i = 1:m
        W(i,i) = exp(- (x-X(i,2))^2/(2*bdw^2));
    end
    mat1 = transpose(X)*W;
    theta = inv(mat1*X)*(mat1*Y);
    yrange(t) = theta(1) + theta(2)*x;
end
plot(xrange,yrange);
xlabel('x1');
ylabel('x2');