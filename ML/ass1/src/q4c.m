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
%sigma = zeros(n,n);
sigma0 = zeros(n,n);
sigma1 = zeros(n,n);
for i = 1:m
    if(strcmp(Y(i),'Alaska'))
        W = transpose(X(i,:)) - mean1;
        sigma1 = sigma1 + W*transpose(W);
    else
        W = transpose(X(i,:)) - mean0;
        sigma0 = sigma0 + W*transpose(W);
    end
end
sigma = sigma/m;
sigma0 = sigma0/(m-phi);
sigma1 = sigma1/phi;
disp(phi);
phi = phi/m;
disp(phi);
disp(mean0);
disp(mean1);
%disp(sigma);
disp(sigma0);
disp(sigma1);