function [accuracy] = SVM_predict(alpha,b,X,kernel,testdata,testclass)
	m = length(alpha);
	n = length(testclass);
	correct_predictions = 0;
	for eno = 1:n
		res = b;
		for id = 1:m
			res = res + alpha(id)*Y(id)*kernel(X(id,:),testdata(eno,:));
		end
		predicted_class = 1;
		if(res < 0) predicted_class = -1;
		if(predicted_class == testclass(eno)) correct_predictions += 1;
	end
	accuracy = correct_predictions/n;
	fprintf(1,'correct: %d total: %d\n',correct_predictions,n);
end