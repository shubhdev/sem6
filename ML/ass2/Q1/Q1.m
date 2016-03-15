%%%%%%  PART A %%%%%
train = importdata('train1.data',',');
class = train(:,end);
train = train(:,1:end-1);
strain = sparse(train);
lin_kernel = @(x1,x2)dot(x1,x2);
bandwidth = 2.5*1e-4;
gaussian_kernel = @(x1,x2)exp(-norm(x1-x2)/2*bandwidth^2);
alph = SVM(lin_kernel,strain,class,1.0);

%%%%%%% PART B  %%%%%%%%
% w = sum(alph(i)*y(i)*x(i))
 m = length(class);
 W = zeros(1,m);
 for i = 1:m
     W(i) = W(i) + alph(i)*class(i)*train(i,:);
 end
 W = W';
