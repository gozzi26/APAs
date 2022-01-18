function [APA_peak, index_APA_peak, signal, RESULTS] =...
    peak_Acc_TP_AP(signal,signalName,TaskName,start_index,end_index,p)
RESULTS=0;
APA_peak=NaN;
index_APA_peak=NaN;
stdmax=0.1;
n=300;
limy=3.2;

if p~=7
    signal=-signal;
end

%disp( std(signal(start_index-n:start_index)) )

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
    legend ('Acc AP','start','toe off')
    xlabel('samples')
    ylabel('m/s^2')
    title({signalName ; TaskName})
    if p~=7
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Forward")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Back")
    else
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Back")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Forward")
    end
    return
end

altezza_min=2*std(signal(start_index-n:start_index));
%% TRIGGER
baseline=mean(signal(start_index-n:start_index));
trigger_vector=ones(length(signal),1)*altezza_min;

signal=signal-baseline;
%% APA finder
if max(signal(start_index:end_index-1))>altezza_min
    INDEX=find(signal(start_index:end_index-1)==max(signal(start_index:end_index-1)));
    if signal(start_index+INDEX-2)< max(signal(start_index:end_index-1)) && signal(start_index+INDEX)< max(signal(start_index:end_index-1))
        PKS = max(signal(start_index:end_index-1));
        LOCS = INDEX ;
    else
    [PKS,LOCS]= findpeaks(signal(start_index:end_index-1),...
        'MinPeakHeight',altezza_min,'MinPeakDistance',40);
    end
    
    
    if isempty(PKS)
        RESULTS=1;
        figure
        plot(signal)
        hold on
        plot(trigger_vector)
        plot(start_index,signal(start_index), 'o')
        plot(end_index,signal(end_index), 's')
        legend('Acc AP','trigger','start','toe off')
        title({signalName ; TaskName})
        xlim([start_index-400 end_index+100])
        ylim([-limy limy])
        xlabel('samples')
        ylabel('m/s^2')
        if p~=7
            annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Forward")
            annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Back")
        else
            annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Back")
            annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Forward")
        end
        
        disp([signalName ' - no peak detected'])
    else
        %% valore del picco dell'APA
        APA_peak=PKS(1);
        %% indice del picco massimo
        index_APA_peak=start_index+LOCS(1)-1;
        %% PLOT
        figure
        plot(signal)
        hold on
        plot(trigger_vector)
        plot(start_index,signal(start_index), 'o')
        plot(end_index,signal(end_index), 's')
        plot(index_APA_peak,APA_peak,'*')
        if p==7
        legend('Acc AP','trigger','start','mid swing','peak','Location','south')
        else
        legend('Acc AP','trigger','start','toe off','peak','Location','south')
        end
        legend('boxoff')
        title({signalName ; TaskName})
        xlabel('samples')
        ylabel('m/s^2')
        xlim([start_index-400 end_index+100])
        ylim([-limy limy])
        if p~=7
            annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Forward")
            annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Back")
        else
            annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Back")
            annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Forward")
        end
    
        if p==7
            %% RICORDA
            APA_peak=-APA_peak;
        end
    
        
    end
    
else
    RESULTS=1;
    
    figure
    plot(signal)
    hold on
    plot(trigger_vector)
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    legend('Acc AP','trigger','start','toe off')
    title({signalName ; TaskName})
    xlim([start_index-400 end_index+100])
    ylim([-limy limy])
    xlabel('samples')
    ylabel('m/s^2')
    if p~=7
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Forward")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Back")
    else
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Back")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Forward")
    end
    
    disp([signalName ' - no peak detected'])
end

end