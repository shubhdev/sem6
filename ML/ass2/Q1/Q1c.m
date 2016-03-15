%%%% Gassian Kernel %%%%%%

X = importdata('train1.data',',');
Y = X(:,end);
X = X(:,1:end-1);
m = length(Y);
gamm = 2.5*1e-4;
sq = sum(X^.2,2);
K = bsxfun(@minus,sq,2*X*X');
K = bsxfun(@plus,sq',K);
K = gamm.*K;
K = exp(-K);
K = (Y*Y').*K;
alpha = SVM(K,Y,1);
threshold = 1e-4;
SV = [];
for i = 1:m
	if(alpha(i) > threshold && alpha(i) < 1.0-threshold)
		SV = [SV;i];
	end
end
%find out b
b = 0;
for sv = 1:length(SV)
	idx = SV(sv);
	b_i = Y(idx) - margin_gaussian(X,Y,X(idx,:));
	b += b_i;
end
b = b/length(SV);
save('sv_gaussian.txt','alpha','-ascii');
testdata = importdata('testdata',',');
testclass = testdata(:,end);
testdata = testdata(:,1:end-1);
%sum(αi*y(i)<x(i), x> + b)
correct = 0;

for tc = 1:length(testclass);
	x = testdata(tc,:);
	approx = margin_gaussian(X,Y,x) + b;
	actual = Y(tc);
	predicted = 1;
	if(approx < 0 ) 
		predicted = -1;
	end
	if(actual == predicted)
		correct += 1;
	end
end
fprintf(1,'correct: %d total: %d\n',correct,length(testclass));
acc = correct/length(testclass);
