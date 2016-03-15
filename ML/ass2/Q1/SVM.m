function [alfa] = SVM(Q,Y,C)
m = size(Q,1);
disp(m);
disp(C);
B = ones(m,1);
cvx_begin
    variable alfa(m);
    minimize(0.5.*alfa'*Q*alfa - B'*alfa);
    subject to
        0 <= alfa <= 1;
        Y'*alfa == 0;
cvx_end
end