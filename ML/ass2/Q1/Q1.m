%%%%%%  PART A %%%%%
X = importdata('train1.data',',');
Y = X(:,end);
X = X(:,1:end-1);
%strain = sparse(train);
lin_kernel = (Y*Y').*(X*X');
%bandwidth = 2.5*1e-4;
%gaussian_kernel = @(x1,x2)exp(-norm(x1-x2)/2*bandwidth^2);
%alph = SVM(lin_kernel,Y,1.0);
alph = load('dual_solution_gcl.txt','-ascii');
threshold = 1e-5;
cnt = 0;
SV = [];
for i = 1:length(Y)
    if(alph(i) > threshold && alph(i) < 0.9999)
        cnt = cnt+1;
        %disp(Y(i));
        SV = [SV;i];
    end
end
%SV = load('sv_linear.txt','-ascii');
%%%%%%% PART B  %%%%%%%%
% w = sum(alph(i)*y(i)*x(i))
  m = length(Y);
  W = zeros(1,size(X,2));
  for i = 1:m
      W = W + (alph(i)*Y(i))*X(i,:);
  end
  W = W';

  % calculate b, by using the margin vectors
  b = 0;
  for i = 1:length(SV)
    idx = SV(i);
    b_i = Y(idx) - X(idx,:)*W;
    disp(b_i);
    %fprintf(1,'%.4f %d\n',b_i,Y(i));
    b = b + b_i;
  end
  b = b/length(SV);