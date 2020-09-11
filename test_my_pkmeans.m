x = -5:0.1:5; x = x';
sigma = 3;
y1 = 0*x.^3 - 0*x .^ 2 - 3 * x + 10 + randn(length(x), 1) * sigma;
y2 = 2*x.^3 -0* x .^ 2 + 4 * x - 5 + randn(length(x), 1) * sigma;
y3 = -2*x.^3 + 5 * x .^ 2 + 1 * x + 8 + randn(length(x), 1) * sigma;
figure(1)
plot(x, y1, 'bo', 'MarkerSize', 1, 'MarkerFaceColor', 'b')
hold on 
plot(x, y2, 'bo', 'MarkerSize', 1, 'MarkerFaceColor', 'b')
plot(x, y3, 'bo', 'MarkerSize', 1, 'MarkerFaceColor', 'b')
hold off
grid on
xlabel('x')
ylabel('y')
legend(' - 3x + 10', ...
       ' 2x^3 + 4x - 5', ...
       '-2x^3 + 5x^2 +  x + 8')
%% RUN MY ALGO
data = [x y1; x y2; x y3];clc
clust = mypolykmean(data(:,2)', data(:,1)', 3, 3);
clust = mypolykmean(data(:,2)', data(:,1)', 3, 3, clust, 1);
grid on
title('')
