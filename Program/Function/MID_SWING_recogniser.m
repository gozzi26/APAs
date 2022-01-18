function [end_index,RESULTS] = MID_SWING_recogniser(signal,start_index,TaskName,DOM)
RESULTS=0;
end_index=NaN;

signal=signal*180/pi;
if DOM
signal=-signal;
end

stdmax=1.5;
altezza_min=50;%°/sec

%cerchi un momento stabile e calcola la baseline
if std(signal(start_index-300:start_index))>stdmax
     figure
     plot(signal)
     title([TaskName '- GyrZ'])
    RESULTS=1;
    disp(['ustable signal, SD = ' num2str(std(signal(start_index-300:start_index)))])
    return
end


if max(signal(start_index:end))>altezza_min
    
    [PKS,LOCS]= findpeaks(signal(start_index:end),...
        'MinPeakHeight',altezza_min,'MinPeakDistance',40);
    end_index=LOCS(1)+start_index-1;
    
    %plot
%     figure
%     plot(signal)
%     hold on
%     plot(end_index,PKS(1), '*')
%     plot(start_index-300:start_index,ones(length(signal(start_index-300:start_index)),1)*mean(signal(start_index-300:start_index)),'--','LineWidth',2)
%     title(taskName)
%     legend('Acc dom','APA end','motionless period')
else
    figure
    plot(signal)
    hold on
    plot(start_index-300:start_index,ones(length(signal(start_index-300:start_index)),1)*mean(signal(start_index-300:start_index)),'--','LineWidth',2)
    title([TaskName '- GyrZ'])
    RESULTS=1;
    return
end
end