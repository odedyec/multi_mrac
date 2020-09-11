function data = mypolykmean(y,x,k,polydeg,data, recursive_iteration)
if nargin < 5
    data = initializePartition(x,y,k, polydeg);
    recursive_iteration = 4;
end 
if recursive_iteration == 5
    return;
end
% k = 1;
% mov(1000) = struct('cdata', [], 'colormap', []);
% figure(11);drawPartitions(data);
% title('Randomly partitioning the data')
% [mov, k] = record_frame(mov, k, 48);
figure(11);
drawPartitions(data);
for itr=1:100
    new_data = repartitionData(data,x,y);
%     subplot(2, 5, itr)
    drawPartitions(new_data);
    title('Repartitioning data based on K polynoms')
    
    % [mov, k] = record_frame(mov, k, 48);
    new_data = generatePolynom(new_data,polydeg);
%     subplot(2, 5, itr + 5)
    drawPartitions(new_data);
    title('Calculate polynom parameters for each partition')
    
    % [mov, k] = record_frame(mov, k, 48);
    % pause(0.3)
    if noChange(data,new_data)
        data = new_data;
        break;
    end
    data = new_data;
end
worst = should_recluster(data, 1);
% worst = 0;  % never retry
if worst
    disp(['We should retrain.', ' worst is ', num2str(worst), ' with ', num2str(data{worst}.R), ' --- ', num2str(data{worst}.p)])
    saved_data = data;
    data = pool_out(data, worst);
    data = mypolykmean(y,x,k,polydeg,data, recursive_iteration+1);
    sum_new = 0;
    sum_old = 0;
    for i=1:length(data)
        sum_new = sum_new + data{i}.R;
        sum_old = sum_old + saved_data{i}.R;
    end
    if sum_old < sum_new
        data = saved_data;
    end
else
    disp(['great  result', '  R values are:'])
    for i=1:length(data)
        disp([num2str(i), ' ', num2str(data{i}.R), ' --- ', num2str(data{i}.p)])
    end
end
% v = VideoWriter('my_algo.avi','MPEG-4');
% open(v)
% v.writeVideo(mov(1:k-1));
% close(v)
function res = should_recluster(data, thresh)
res = 1;
for i=2:length(data)
    if abs(data{i}.p(end)) > abs(data{res}.p(end))
        res = i;
    end
end
if data{res}.R < thresh
    res = 0;
end
return;

function data = pool_out(data, worst)
data{worst}.p = zeros(size(data{worst}.p));
% data{worst}.p(2) = 30;
% data = data;
return;

function res = noChange(data,new_data)
sum_test = 0;
res = 1;
for k=1:length(data)
    sum_test = sum_test + sum((data{k}.p-new_data{k}.p).^2);
end
if sum_test > 0.00001
    res = 0;
end
return;

function new_data = repartitionData(data,x,y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Repartition data x and y that correspond to to the best fitting %
% polynom in data{k}.p, where k=1,...,K.                          %
% The repartitioned data is saved inside new_data and returened   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

k = length(data);
new_data = cell(k, 1);
yest = zeros(length(y), k);
for i=1:k
    yest(:,i) = polyval(data{i}.p, x);
end
conf_mat  = (repmat(y',1,k) - yest).^2;
[~,I] = min(conf_mat, [], 2);
for i=1:k
    idx = find(i==I);
    new_data{i}.p = data{i}.p;
    new_data{i}.x = x(idx);
    new_data{i}.y = y(idx);
    new_data{i}.R = sum(conf_mat(idx, i));
end
return

function data = initializePartition(x,y,k, polydeg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This function initializes the partition seperation     %%%
%%% The y values are sorted and x is rearagned according   %%%
%%% to the indices of y, the the data is seperated into    %%%
%%% k equal number of data                                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     data = cell(numOfPartitions,1);
%     cuts = linspace(min(y), max(y), numOfPartitions);
%     for k=1:numOfPartitions
%         data{k}.p = zeros(polydeg,1);
%         data{k}.p(numOfPartitions) = cuts(k);
%     end
%     return
%     [yy, I] = sort(y);
%     I = randperm(length(x));  
%     yy = y(I);
%     xx = x(I);
%     l = length(y);
%     for k=1:numOfPartitions
%         data{k}.x = xx(floor(l*(k-1)/numOfPartitions)+1:floor(l*k/numOfPartitions));
%         data{k}.y = yy(floor(l*(k-1)/numOfPartitions)+1:floor(l*k/numOfPartitions));
%     end
%     data = generatePolynom(data,polydeg);
    y_m = max(y);
    y_n = min(y);
    data = cell(k, 1);
    dy = (y_m - y_n) / k;
    for i=1:k
        data{i}.p = zeros(1, polydeg+1);
        data{i}.p(end-1) = 2 * randi(k);
        data{i}.p(end) = y_n + i * dy;
    end
    data = repartitionData(data, x, y);
return

function data = generatePolynom(data,polydeg)
for k=1:length(data)
    [data{k}.p,data{k}.S] = polyfit(data{k}.x,data{k}.y,polydeg);
end
return;

function drawPartitions(data)
% color_bank = ['.b' '.-'; '.r' '.-r'; '.g', '.-g'];
color_bank = ['b', 'r', 'g', 'k', 'y', 'm', 'c', 'w'];
ps = [];
leg_str = cell(1);
for i=1:length(data)
    x = data{i}.x;
    y = data{i}.y;
    poly_y = polyval(data{i}.p, data{i}.x);
    [x, I] = sort(x);
    y = y(I);
    poly_y = poly_y(I);
    st = sprintf('o%c', color_bank(i));
    p1 = plot(x,y,st,'MarkerSize',1,'MarkerFaceColor', color_bank(i));
    hold on
    st = sprintf('--%c', color_bank(i));
    p2 = plot(x,poly_y,st,'MarkerSize',10);
    xlabel('x')
    ylabel('y')
    ps = [ps, p2];
    leg_str{i} = poly2str(data{i}.p, 'x');
end
legend(ps, leg_str)
hold off
drawnow;
pause(0.005)

return

function [f, k] = record_frame(f, k, loops)

for i=1:loops
f(k) = getframe(gcf);
k = k + 1;
end
return
