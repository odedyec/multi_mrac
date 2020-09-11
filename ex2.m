close all;clc;clearvars
b = 1;
As = [-1, 3, 1, 5, -5];
a_actual = 3; 
y_dot = 0;
y = 0;
u = 1;
r = 2;

dt = 0.002;
Y = [];
E = [];
T = 0:dt:50;

noise = 0.0050;

for t = T
    if t - floor(t) == 0.0
        i = randi(length(As));
        a_actual = As(i);
    end
    if t/5 == floor(t/5)
        r = -r;
    end
    u = 10*(r - y);
    y_dot = u - a_actual .* y + noise * randn(1);
    y = y + y_dot * dt;
    Y = [Y, [y;y_dot;a_actual; u;r]];
end
I1 = find(Y(3,:)==1);
I2 = find(Y(3,:)==2);
I3 = find(Y(3,:)==3);
plot(T(:), Y(1,:), '')
hold on
plot(T(:), Y(end,:), '--r')
grid on
ylabel('x')
xlabel('t[sec]')
legend('x', 'r')
figure;
% figure; plot(T, E);
idx = find(abs(1-Y(4, :)) < 0.5);
% plot(Y(1,idx),Y(2,idx),'.b')
plot(Y(1,:),Y(2,:)-Y(4,:),'.b')
ylabel('$$\dot{x}-bu$$','interpreter','latex')
xlabel('x','interpreter','latex')
grid on
%% Train PKmeans
lines = mypolykmean(Y(2,:)-Y(4,:), Y(1,:), length(As), 1);
grid on
ylabel('$$\dot{x}-bu$$','interpreter','latex')
xlabel('x','interpreter','latex')
%% Adaptive controllers
b = 1;
a_actual = 3; 
for i=1:length(As)
%     lines{i}.p(1) = -As(i)+randn(1); 
    lines{i}.p(2) = 0;
end

ap = []; for i=1:length(As); ap = [ap -lines{i}.p(1)];end;ap
ap(5) = 1; ap(4) = 5;
y_dot = 0;
y = 0;
ym_dot = 0;
ym = 0;
u = 1;

a = -0;
gamma = 5;
r = -2;
e_dot = 0;
e = 0;

dt = 0.002;
Y = [];
E = [];
T = 50:dt:100;
counter = zeros(length(As));

for t = T
    if t - floor(t) == 0.0
        i = randi(length(As));
        a_actual = As(i);
    end
    if t/10 == floor(t/10)
        r = -r;
    end
    [idx,errors] = check_best(lines, [y, y_dot-u]);
%     idx = 1;
    counter(i,idx) = counter(i,idx) + 1;
    ym_dot = r - 2 * ym;
    ym = ym + ym_dot * dt;
    
    ay = ap(idx) - 2;
%     ay = a - 2;
%     [~, Idx] = min(u - ay .* y - r - 2 * e);
    %e = e + e_dot * dt;
    e = y - ym;
    E = [E; e];
    
    ay = ay - gamma * e .* y * dt;
    u = ay .* y + r;
    ap(idx) = ay + 2;
    lines{idx}.p(1) = -ap(idx);
    y_dot = u - a_actual .* y + noise * randn(1);
    y = y + y_dot * dt;
    Y = [Y [y;y_dot;ym;u;idx;i]];
end
figure
plot(T, Y(1, :), '-b')
hold on
plot(T, Y(3, :), '--r')
hold off
ylabel('x and x_m')
xlabel('t[sec]')
legend('x', 'x_m')
counter
ap
grid on
figure; 
plot(T, Y(6,:), '.b')
hold on
% plot(T, Y(5,:), '--r')
hold off
xlabel('t[sec]')
ylabel('active submodel')
% legend('actual submodel')
set(gca,'YTick',(1:1:4))
% legend('predicted submodel')

figure;
subplot(4, 1, 1)

plot(T, Y(6,:), '.b')
ylabel(sprintf('active\n submodel'))
set(gca,'XTick',[], 'YTick',(1:1:5))
% set(gca, 'Position', [ 0.130    0.6093    0.7750    0.2157])
axes('Color','none','XColor','none');
subplot(4, 1, 2:4)
plot(T, Y(1, :), '-b')
hold on
plot(T, Y(3, :), '--r')
hold off
ylabel('x and x_m')
xlabel('t[sec]')
legend('x', 'x_m')