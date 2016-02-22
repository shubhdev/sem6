V = importdata('data/mesh_q1.dat');
x = V(:,1);
y = V(:,2);
z = V(:,3);
%plot3(x,y,z,'o');
X = importdata('data/q1x.dat');
Y = importdata('data/q1y.dat');
for i = 1:size(X,2)
        X(:,i) = X(:,i) - mean(X(:,i));
        X(:,i) = X(:,i) / std(X(:,i));
end
X = [ones(size(X,1),1) X];
%disp(X);
finaltheta = theta;
fprintf('Final theta : [%.4f,%.4f]\n',finaltheta(1),finaltheta(2));
theta1 = linspace(-1,11,20);
theta2 = linspace(-1,11,20);
m = size(X,1);
%disp(m);
Z = zeros(length(theta1),length(theta2));
for t0 = 1:length(theta1)
    for t1 = 1:length(theta2)
        err = 0.0;
        for i = 1:m
            %disp(t0);
            h_theta = X(i,:)*[theta1(t0);theta2(t1)];
            %disp(h_theta);
            %disp(Y(i));
            
            err = err + (Y(i)-h_theta)^2;
            %disp(err);
        end
        %disp(err);
        %pause(1);
        err = err * 0.5 * 1.0/m;
        %disp(err);
        Z(t1,t0) = err;
       
    end
end
plot3(x,y,z,'o');
hold on;
meshc(theta1,theta2,Z);
hold on;
plot(x,y,'bx');