function [margin] = margin_gaussian(X,Y,x)
	sq = sum(X.^2);
	sq = sq.+(xx');
	K1 = X*x;
	K1 = sq - 2*K1;
	K1 = exp(-gamm*K1);
	margin = dot(alpha,Y)*K1;
end