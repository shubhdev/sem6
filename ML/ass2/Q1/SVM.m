function [alfa] = SVM(kernel,X,Y,C)
m = size(Y,1);
Q = zeros(m,m);
disp(m);
disp(C);
for i = 1:m
    for j = 1:m
        %disp(i);
        Q(i,j) = dot(X(i,:),X(j,:))*Y(i)*Y(j);
    end
end

%fprintf(1,'saving..\n');
save('Q.mat','Q');
%fprintf(1,'loading...\n');
%load('Q.mat');
B = ones(m,1);
fprintf(1,'starting optimization\n');
cvx_begin
    variable alfa(m);
    maximize(-0.5.*alfa'*Q*alfa + B'*alfa);
    subject to
        0 <= alfa <= C;
        Y'*alfa == 0;
cvx_end
end