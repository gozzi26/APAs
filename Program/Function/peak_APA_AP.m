function [APA_peak, START_peak, end_peak, index_APA_peak, RESULTS] =...
    peak_APA_AP(signal,signalName,TaskName,start_index,end_index,mid_swing_index,p)
RESULTS=0;
APA_peak=NaN;
START_peak=NaN;
end_peak=NaN;
index_APA_peak=NaN;

n=300;
stdmax=0.008;
limy=0.2;
if p==7
    signal=-signal;
end

if end_index<800
    disp(['recond not enough long: ' num2str(length(signal)) ' samples'])
    RESULTS=1;
    figure
    plot(signal)
    hold on
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    title([signalName '-' TaskName])
    if p==7
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Forward")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Back")
    else
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Back")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Forward")
    end
    return
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
    title([signalName ' - ' TaskName])
    xlabel('samples')
    ylabel('meter')
    legend ('CoP AP','start','toe off')
    if p==7
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Forward")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Back")
    else
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Back")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Forward")
    end
    return
end

%% TRIGGER
baseline=mean(signal(start_index-n:start_index));
soglia=abs(2*std(signal(start_index-n:start_index)));
trigger_vector=ones(length(signal),1)*(baseline+soglia);

%% APA finder
j=0;
k=0;
APA=ones(length(signal),1)*(baseline);

for i=start_index-2:mid_swing_index+30
    if  j==0 && signal(i-1)> baseline+soglia
        continue
    end
    
    if signal(i)> baseline+soglia && i>start_index
        j=j+1;
        continue
    end
    
    if j>=10 && j<=150 && k~=0
        if (end_peak-START_peak)>j %se il picco è più breve di quello precentemente misurato allora skippa
            continue
        end
    end
    
    if j>=10 && j<=150
        APA=ones(length(signal),1)*(baseline);
        [APA_peak_absolute,I]=max(signal(i-j:i-1));
        
        for u=i-j:i-1
            APA(u)=APA_peak_absolute;
        end
        
        %% inizio del picco
        START_peak=i-j;
        %% fine del picco
        end_peak=i;
        %% valore del picco dell'APA
        APA_peak=APA_peak_absolute-baseline;
        %% indice del picco massimo
        index_APA_peak=i-j+I-1;
        
        k=k+1;
    end
    j=0;
end
if k==0
    %se non sono stati rilevati APA
    RESULTS=1;
    
    figure
    plot(signal)
    hold on
    plot(trigger_vector)
    plot(APA)
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    legend ('CoP AP', 'trigger','baseline','start','toe off')
    xlim([start_index-400 end_index+100])
    ylim([-limy limy])
    xlabel('samples')
    ylabel('meter')
    title({signalName ; TaskName})
    disp([signalName ' - NO APA detected'])
    if p==7
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Forward")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Back")
    else
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Back")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Forward")
    end
else
    % PLOT
    figure
    plot(signal)
    hold on
    plot(start_index-n:start_index,ones(length(signal(start_index-n:start_index)),1)*baseline,'LineWidth',2)
    plot(trigger_vector) %il vettore trigger
    plot(APA)
    plot(start_index,signal(start_index), 'o')
    plot(index_APA_peak,APA_peak_absolute,'*')
if p==7
    plot(end_index,signal(end_index), 's')
    legend('CoP AP','3s before start','Trigger','APA','start','peak','mid swing','Location','best')
else
    plot(end_index,signal(end_index), 's')
    plot(mid_swing_index,signal(mid_swing_index), 's')
    legend('CoP AP','3s before start','Trigger','APA','start','peak','toe-off','mid-swing','Location','best')
end
    legend('boxoff')
    title({signalName ; TaskName})
    xlim([start_index-400 end_index+100])
    ylim([-limy limy])
    xlabel('samples')
    ylabel('meter')
    if p==7
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
end