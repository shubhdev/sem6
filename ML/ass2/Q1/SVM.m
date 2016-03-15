function [alfa] = SVM(Q,Y,C)
m = size(Q,1);
%Q = zeros(m,m);
disp(m);
disp(C);
% for i = 1:m
%     for j = 1:m
%         %disp(i);
%         Q(i,j) = dot(X(i,:),X(j,:))*Y(i)*Y(j);
%     end
% end
%fprintf(1,'saving..\n');
%save('Q.mat','Q');
%fprintf(1,'loading...\n');
%load('Q.mat');
B = ones(m,1);
fprintf(1,'starting optimization\n');
cvx_begin
    variable alfa(m);
    minimize(0.5.*alfa'*Q*alfa - B'*alfa);
    subject to
        0 <= alfa <= 1;
        Y'*alfa == 0;
cvx_end
end