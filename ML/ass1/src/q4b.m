%calculated from q4a
phi = 0.5000;
mean0 = [137.4600;366.6200];
mean1 = [98.3800;429.6600];
sigma =   [2.874820000000001e+02,-26.747999999999983;-26.747999999999983,1.123250000000000e+03];
X = importdata('data/q4x.dat');
Y = importdata('data/q4y.dat');

classA = [];
classB = [];
m = size(X,1);
for i = 1:m
    if(strcmp(Y(i),'Alaska'))
        classA = [classA;X(i,:)];
    else
        classB = [classB;X(i,:)];
    end
end
plot(classA(:,1),classA(:,2),'+');
hold on;
plot(classB(:,1),classB(:,2),'*');
% the equation simplifies to    2*transpose(X)*inv(sigma)*mean -
% transpose(mean)*inv(sigma)*mean
%where
% X = x-mean0;
% mean = mean1-mean0
% the final equation works out to be -0.262*(x1-137.46) + 0.106*(x2-366.62)
% - 8.4611 = 0
syms x y
f(x,y) = -0.262*(x-137.46) + 0.106*(y-366.62) - 8.4611;
ezplot(f,[40,180,250,550]);