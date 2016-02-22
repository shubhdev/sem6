X = importdata('data/q2x.dat');
Y = importdata('data/q2y.dat');
n = size(X,2);
m = size(X,1);
X = [ones(m,1) X];
n = n+1;
del = zeros(n,1);
hessian = zeros(n,n);
theta = zeros(n,1);
delta_theta = flintmax;
while delta_theta > 1e-6
    %calculate del
    for i = 1:n
         sum = 0.0;
        for j = 1:m
            %iterate over all exmaples
            h = 1/(1 + exp(-X(j,:)*theta));
            sum = sum + (Y(j)-h)*X(j,i);
        end
        del(i) = sum;
    end
    %calculate the hessian
    for i = 1:n
        for j = 1:n
            sum = 0.0;
            for k = 1:m
                h = 1/(1 + exp(-X(k,:)*theta));
                sum = sum - X(k,i)*X(k,j)*h*(1-h);
            end
            hessian(i,j) = sum;
        end
    end
    update = inv(hessian)*del;
    delta_theta = sqrt(transpose(update)*update);
    theta = theta - update;
end
disp(theta);
x1 = linspace(0,8);
x2 = -theta(1)/theta(3) - (theta(2)/theta(3))*x1;
plot(x1,x2);