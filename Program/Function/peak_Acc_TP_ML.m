function [APA_peak, index_APA_peak,signal, RESULTS] =...
    peak_Acc_TP_ML(signal,signalName,TaskName,start_index,end_index,DOM,p)
RESULTS=0;
APA_peak=NaN;
index_APA_peak=NaN;

n=300; %numero di valori entro quale fare la sd
stdmax=0.1;

if ~DOM
    signal=-signal;
end

if std(signal(start_index-n:start_index))>stdmax
    %non rileva l'apa e interrompe la funzione poichè non è presente una
    %baseline
    RESULTS=1;
    disp([signalName ' - NO static part detected, SD= ' num2str(std(signal(start_index-n:start_index)))])
    figure
    plot(signal)
    hold on
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    legend ('Acc ML','start','toe off')
    title({signalName ; TaskName})
    xlabel('samples')
    ylabel('m/s^2')
    annotation('textbox', [0.15, 0.7, 0.1, 0.1], 'String', "Stance side")
    annotation('textbox', [0.15, 0.2, 0.1, 0.1], 'String', "Step side")
    return
end

altezza_min=2*std(signal(start_index-n:start_index));

%% TRIGGER
baseline=mean(signal(start_index-n:start_index));
trigger_vector=ones(length(signal),1)*altezza_min;

signal=signal-baseline;
%% APA finder
APA=zeros(length(signal),1);

if max(signal(start_index:end_index))>altezza_min
    INDEX=find(signal(start_index:end_index-1)==max(signal(start_index:end_index-1)));
    if signal(start_index+INDEX-2)< max(signal(start_index:end_index-1)) && signal(start_index+INDEX)< max(signal(start_index:end_index-1))
        APA_peak = max(signal(start_index:end_index-1));
        LOCS = INDEX ;
    else
    [APA_peak,LOCS]= findpeaks(signal(start_index:end_index),'MinPeakHeight',altezza_min,'MinPeakDistance',39);
    end
    
    if isempty(APA_peak)
        RESULTS=1;
    figure
    plot(signal)
    hold on
    plot(trigger_vector)
    plot(APA)
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    legend('Acc ML','trigger','baseline','start','toe off')
    title([signalName '-' TaskName])
    xlim([start_index-400 end_index+100])
    ylim([-1.5 1.5])
    xlabel('samples')
    ylabel('m/s^2')
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Stance side")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Step side")
    
    disp([signalName ' - no peak detected'])
    else
        
    %% valore del picco dell'APA
    APA_peak=APA_peak(1);
    %% indice del picco massimo
    index_APA_peak=start_index+LOCS(1)-1;
    %% PLOT
        figure
        plot(signal)
        hold on
        plot(trigger_vector)
        plot(APA)
        plot(start_index,signal(start_index), 'o')
        plot(end_index,signal(end_index), 's')
        plot(index_APA_peak,APA_peak,'*')
        if p==7
        legend('CoP AP','Trigger','baseline','start','mid swing','peak','Location','south')
        else
        legend('CoP AP','Trigger','baseline','start','toe-off','peak','Location','south')
        end
        legend('boxoff')
        title({signalName ; TaskName})
        xlim([start_index-400 end_index+100])
        ylim([-1.5 1.5])
        xlabel('samples')
        ylabel('m/s^2')
        annotation('textbox', [0.15, 0.7, 0.1, 0.1], 'String', "Stance side")
        annotation('textbox', [0.15, 0.2, 0.1, 0.1], 'String', "Step side")
    end
else
    RESULTS=1;
    
    figure
    plot(signal)
    hold on
    plot(trigger_vector)
    plot(APA)
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    legend('Acc ML','trigger','baseline','start','toe off')
    title([signalName '-' TaskName])
    xlim([start_index-400 end_index+100])
    ylim([-1.5 1.5])
    xlabel('samples')
    ylabel('m/s^2')
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Stance side")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Step side")
    
    disp([signalName ' - no peak detected'])
end

end

