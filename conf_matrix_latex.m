clc;
for i=1:5
    fprintf('&%d ', i);
    for j=1:5
        fprintf('&%d ', counter(i, j));
    end
    fprintf('\\\\\n\\cline{3-7}\n');
end