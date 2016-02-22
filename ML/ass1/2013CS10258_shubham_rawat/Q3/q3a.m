X = importdata('data/q2x.dat');
Y = importdata('data/q2y.dat');
classA = [];
classB = [];
for i = 1:length(Y)
    if(Y(i) > 1e-5)
        classA = [classA;X(i,:)];
    else
        classB = [classB;X(i,:)];
    end
end
plot(classA(:,1),classA(:,2), '+');
hold on;
plot(classB(:,1),classB(:,2), '*');