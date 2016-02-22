dat_x = 'q1x.dat';
dat_y = 'q1y.dat';
alpha = 1e-6;
eps = 2e-6;
normalize = true;
if isempty(normalize)
    normalize = false;
end
x = importdata(dat_x);
y = importdata(dat_y);
%normalize data

if(normalize)
    for i = 1:size(x,2)
        x(:,i) = x(:,i) - mean(x(:,i));
        x(:,i) = x(:,i) / std(x(:,i));
    end
end
x = [ones(size(x,1),1) x ]; %add intercept terms

theta = zeros(size(x,2),1);

delta_J = flintmax;

n_training_data = size(x,1);

J = 0.0;
iter = 0;

%Setup the timer

fileID = fopen('mesh_q1_e.dat','w');
t = timer('TimerFcn','fprintf(fileID,''%.5f %.5f %.5f\n'',theta(1),theta(2),J);','Period',0.2,'ExecutionMode','fixedRate');
start(t);
while delta_J > eps
    iter = iter + 1; 
    J1 = 0.0;
    update = [0.0;0.0];
    for i = 1:n_training_data
       h_theta = x(i,:)*theta;
        J1 = J1 + (y(i)-h_theta)^2;
        for j = 1:length(update)
            update(j) = update(j) + ( y(i) - h_theta ) *  x(i,j);
        end
    end
    J1 = J1 * 0.5;
    theta = theta + alpha*update;
    delta_J = abs(J-J1);
    J = J1;
end
stop(t);
delete(t);
fclose(fileID);
disp(iter);
disp(J);

yy = y;
for i = 1:size(yy,1)
    yy(i) = x(i,:) * theta;
end
plot(x(:,2:end),y,'.',x(:,2:end),yy);