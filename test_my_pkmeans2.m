sigma = 2.2;
x = -5:0.1:5; x = x';
y1 = x.^2 - 3 * x + 5 + randn(length(x), 1) * sigma;
y2 = 4 * x - 5 + randn(length(x), 1) * sigma;
y3 = x + 8 + randn(length(x), 1) * sigma;
figure(1)
plot(x, y1, '.:b', 'MarkerSize', 1)
hold on 
plot(x, y2, '.:b', 'MarkerSize', 1)
plot(x, y3, '.:b', 'MarkerSize', 1)
hold off
grid on
xlabel('x')
ylabel('y')
legend('x^2 - 3x + 5', ...
       ' 4x -  5', ...
       ' x + 8')
%% RUN MY ALGO
data = [x y1; x y2; x y3];
clust = mypolykmean(data(:,2)', data(:,1)', 3, 2);
% clust = mypolykmean(data(:,2), data(:,1), 3, 2, clust, 5);
title('')
grid on
disp('-------------')
for c=1:length(clust)
    try
        clust{c}.p
        R = clust{c}.S.R;
        df = clust{c}.S.df;
        normr = clust{c}.S.normr;
        sum(sum(inv(R) * inv(R)' * normr ^2 / df))
    catch
        disp('useless point')
        length(clust{c}.x)
    end
end
disp('===============')
