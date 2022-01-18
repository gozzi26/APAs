function [max_AP] = max_CoP_AP(signal,TaskName,start_index,end_index)
%find the max CoP_AP  

[max_AP,I]=max(signal(start_index:end_index));


figure
plot(signal)
title(TaskName)
hold on
plot(start_index,signal(start_index), 'o')
plot(end_index,signal(end_index), 's')
plot(I+start_index-1,max_AP,'*')
end

