function [APA_peak, START_peak, end_peak, index_APA_peak, RESULTS] =...
          peak_APA_ML(signal,signalName,TaskName,start_index,end_index,DOM,p)
RESULTS=0;
APA_peak=NaN;
START_peak=NaN;
end_peak=NaN;
index_APA_peak=NaN;

n=300; %numero di valori entro quale fare la sd
stdmax=0.01;

if end_index<800
    disp(['recond not enough long: ' num2str(length(signal)) ' samples'])
    RESULTS=1;
    figure
    plot(signal)
    hold on
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    legend ('CoP ML','start','toe off')
    title({signalName ; TaskName})
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Step side")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Stance side")
    xlim([start_index-400 end_index+100])
    ylim([-0.1 0.1])
    xlabel('samples')
    ylabel('metri')
    return
end


if DOM
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
    title({signalName ; TaskName})
    xlabel('samples')
    ylabel('metri')
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Step side")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Stance side")
    return
end

%% TRIGGER
baseline=mean(signal(start_index-n:start_index));
soglia=abs(2*std(signal(start_index-n:start_index)));
trigger_vector=ones(length(signal),1)*(baseline+soglia);

%% APA finder
j=0;
APA=ones(length(signal),1)*(baseline);

for i=start_index-2:end_index %la parte di segnale analizzata per trovare l'apa sta tra lo 'start' e l'heel-off 
    
        if  j==0 && signal(i-1)> baseline+soglia
            continue
        end
        
        if signal(i)> baseline+soglia && i>start_index
            j=j+1;
            continue
        end
        
        if j>=10 && j<=150 %tra 10 e 150 campioni
            
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
            
            %% PLOT
            figure
            plot(signal,'k','LineWidth',1.3)
            hold on
           % plot(start_index-n:start_index,ones(length(signal(start_index-n:start_index)),1)*baseline,'LineWidth',2) 
            plot(trigger_vector,'--r') %il vettore trigger
            plot(APA,'r')
            plot(start_index,signal(start_index), 'or')
            plot(end_index,signal(end_index), 'sr')
            plot(index_APA_peak,APA_peak_absolute,'*r')
            if p==7
            legend('CoP ML','Trigger','APA','start','mid swing','peak','Location','south') %'3s before start',
            else
            legend('CoP ML','Trigger','APA','start','toe-off','peak','Location','south') %'3s before start',
            end
            legend('boxoff')
%             title({signalName ; TaskName})
            xlim([start_index-400 end_index+100])
            ylim([-0.1 0.1])
%             ylabel('meter')
            annotation('textbox', [0.15, 0.7, 0.1, 0.1], 'String', "Step side")
            annotation('textbox', [0.15, 0.2, 0.1, 0.1], 'String', "Stance side")
            return
        end
        j=0;
end   
    RESULTS=1;
    
    figure
    plot(signal)
    hold on
    plot(trigger_vector)
    plot(APA)
    plot(start_index,signal(start_index), 'o')
    plot(end_index,signal(end_index), 's')
    legend('CoP ML','trigger','APA','start','toe off')
    xlim([start_index-400 end_index+100])
    ylim([-0.1 0.1])
    annotation('textbox', [0.15, 0.8, 0.1, 0.1], 'String', "Step side")
    annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "Stance side")
    title({signalName ; TaskName})
    xlabel('samples')
    ylabel('metri')
    disp([signalName ' - NO APA detected'])
end   