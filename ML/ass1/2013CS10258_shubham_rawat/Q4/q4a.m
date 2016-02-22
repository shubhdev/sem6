X = importdata('data/q4x.dat');
Y = importdata('data/q4y.dat');

m = size(X,1);
n = size(X,2);
phi = 0.0;
mean0 = [0;0];
mean1 = [0;0];
for i = 1:m
    if(strcmp(Y(i),'Alaska'))
        phi = phi + 1;
        mean1 = mean1 + transpose(X(i,:));
    else
        mean0 = mean0 + transpose(X(i,:));
    end
end
mean1 = mean1/phi;
mean0 = mean0/(m-phi);
phi = phi/m;
sigma = zeros(n,n);
for i = 1:m
    if(strcmp(Y(i),'Alaska'))
        mean = mean1;
    else
        mean = mean0;
    end
    W = transpose(X(i,:)) - mean;
    sigma = sigma + W*transpose(W);
    %disp(W);
    %disp('----');
end
sigma = sigma/m;
disp(phi);
disp(mean0);
disp(mean1);
disp(sigma);