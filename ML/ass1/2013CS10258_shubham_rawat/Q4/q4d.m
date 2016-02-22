phi = 0.5;
mean0 = [1.374600000000000e+02;3.666200000000000e+02];
mean1 = [98.380000000000000;4.296600000000000e+02];
sigma0 = [3.195683999999999e+02,1.308348000000000e+02;1.308348000000000e+02,8.753956000000000e+02];
sigma1 = [2.553956000000001e+02,-1.843308000000000e+02;-1.843308000000000e+02,1.371104400000000e+03];
%sigma0 = [2.874820000000001e+02,-26.747999999999983;-26.747999999999983,1.123250000000000e+03];
%sigma1 = [2.874820000000001e+02,-26.747999999999983;-26.747999999999983,1.123250000000000e+03];
%the boundary equation
det0 = det(sigma0);
det1 = det(sigma1);
% 2*log((1-phi)/phi) + log(det1/det0) = X'*inv(sigma0)*X -
% (X-mean)'*inv(sigma1)*(X-mean)
% where X = x-mean0 and mean = mean1-mean0
%the RHS simplifies to
% X'inv(sigma0)X - X'inv(sigma1)X + 2*X'inv(sigma1)*mean - mean'inv(sigma1)mean 
%{
    let inv(sigma0) = [a0 b0;c0 d0] ; note that b0=c0 since sigma0 is symmetric so is inv(sigma0)
        inv(sigma1) = [a1 b1;c1 d1] ; note that b1=c1
        mean'inv(sigma1)mean = cons
        2*inv(sigma1)*mean = [p1;p2]
        X = [x1;x2]
    then the expression reduces to
    (a0-a1)*x1^2 + (d0-d1)*x2^2 + 2*x1*x2(b0-b1) + p1*x1 + p2*x2 -cons -
    log(det1/det0) - 2*log((1-phi)/phi);
    Then we can simply replace x1 by x1-mean0(1) and x2 by x2-mean0(2)
%}
isigma0 = inv(sigma0);
mean = mean1-mean0;
a0 = isigma0(1,1);
b0 = isigma0(1,2);
d0 = isigma0(2,2);
isigma1 = inv(sigma1);
a1 = isigma1(1,1); b1 = isigma1(1,2); d1 = isigma1(2,2);
p = 2*isigma1*mean;
p1 = p(1);
p2 = p(2);
cons = mean'*isigma1*mean;
xx = mean0(1);
yy = mean0(2);
cons1 = cons+log(det1/det0) + 2*log((1-phi)/phi);
syms x y
f(x,y) = (a0-a1)*(x-xx)^2 + (d0-d1)*(y-yy)^2 + 2*(x-xx)*(y-yy)*(b0-b1) + p1*(x-xx) + p2*(y-yy) - cons1;
ezplot(f,[40,180,250,550]);

