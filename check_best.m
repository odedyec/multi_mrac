function [ best, best_error] = check_best( lines, test_data )
%CHECK_BEST Summary of this function goes here
%   Detailed explanation goes here
best = 0;
best_error = 0;
for i=1:length(lines)
    line = lines{i};
    y = polyval(line.p, test_data(1));
    error = abs(test_data(2) - y);
    if best == 0
        best = 1;
        best_error = error;
    else
        if best_error > error
            best_error = error;
            best = i;
        end
    end


end

