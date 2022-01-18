clc
close all
clear
load partecipanti.mat
%% genero il file excel
% filename='Analisi3.xlsx';
% Nome_partecipanti={'P1','P2','P3','P4','P5'};
% tablename={'copML peak value', 'AccML peak value', 'copAP peak value', 'AccAP peak value',...
%     'Duration','time to peak ML', 'time to peak AP'};
% 
% for sheet=1:length(tablename)
% A={tablename{sheet},'task1','task2','task3','task4','task5','task6','task7', ...
%      'task8', 'task9', 'task10', 'task11', 'task12', 'task13', 'task14', 'task15'};
% xlswrite(filename,A,sheet,'A1')
%  for part=1:length(Nome_partecipanti)
%         NOME=Nome_partecipanti{part};
%         xlswrite(filename,{NOME},sheet,['A',num2str(2+3*(part-1))] )
%         %disp(strcat('A',num2str(2+3*(part-1))))
%  end
% end

task = {'task1' 'task2' 'task3' 'task4' 'task5' 'task6' 'task7' ...
     'task8' 'task9' 'task10' 'task11' 'task12' 'task13' 'task14' 'task15'};
prova = {'try1' 'try2' 'try3'};
signalName={'CoP ML','CoP AP','Acc TP ML','Acc TP AP'};
for p=1
    for j=1
        for i=1
            
            taskName=['soggetto' num2str(p) ' - task' num2str(j) ' - try' num2str(i)];
            disp(taskName)
            
             %% prendo il dato
            %ML - positivi verso la gamba destra
            CoP_ML=participant(p).(task{j}).(prova{i}).plat(:,1);
            Acc_TP_ML=participant(p).(task{j}).(prova{i}).IMUacc(:,2);
            %AP - positivi nella direzione opposta al cammino
            CoP_AP=participant(p).(task{j}).(prova{i}).plat(:,2);
            Acc_TP_AP=participant(p).(task{j}).(prova{i}).IMUacc(:,3);
                
            %LA GAMBA CON CUI INIZIA
            if p==1 || p==2  %gamba sinistra 
                GyrZ_domleg=participant(p).(task{j}).(prova{i}).IMUgyr(:,9);
                DOM=1; 
            else %gamba destra
                GyrZ_domleg=participant(p).(task{j}).(prova{i}).IMUgyr(:,6);
                DOM=0; 
            end
            marker_signal=participant(p).(task{j}).(prova{i}).MK(:,1);           
            
            
            %% elaboro il dato
            toe_off_index=NaN;
            START_peak_ML=NaN;
            START_peak_AP=NaN;
            index_APA_peak_ML=NaN;
            index_APA_peak_AP=NaN;
            APA_peak_ML=NaN;
            APA_peak_TP_ML=NaN;
            APA_peak_AP=NaN;
            APA_peak_TP_AP=NaN;
            
            %indice corrispondente allo 'start'
            [start_index,RESULTS]=startAPA_recogniser(marker_signal); 
            if RESULTS
                disp('NO START detected')
                continue
            end
            %indice corrispondente al MID SWING
            [mid_swing_index,RESULTS] = MID_SWING_recogniser(GyrZ_domleg,start_index,taskName,DOM); 
            if RESULTS || mid_swing_index<start_index
                  disp('NO MID-SWING detected')
                continue
            end
            %TOE-OFF
            [toe_off_index,RESULTS] = TOE_OFF_recogniser...
                (GyrZ_domleg, start_index, mid_swing_index, taskName, DOM,j);
            if RESULTS
                disp('NO TOE-OFF detected')
                continue
            end
            
            
            %indica la disposizione del cop dallo start al mid swing
            figure
            plot(CoP_ML(start_index:mid_swing_index),-CoP_AP(start_index:mid_swing_index),'k','LineWidth',1.3)
            hold on
            plot(CoP_ML(start_index),-CoP_AP(start_index),'*r')
            plot(CoP_ML(toe_off_index),-CoP_AP(toe_off_index),'*r')
            plot(CoP_ML(mid_swing_index),-CoP_AP(mid_swing_index),'*r')
            ylabel('meter')
            xlabel('meter')
%             legend('CoP','start','toe off','mid swing')
%             legend('boxoff')
%     annotation('textbox', [0.15, 0.7, 0.1, 0.1], 'String', "Forward")
%     annotation('textbox', [0.15, 0.2, 0.1, 0.1], 'String', "Back")
%     annotation('textbox', [0.80, 0.1, 0.1, 0.1], 'String', "right")
%     annotation('textbox', [0.15, 0.1, 0.1, 0.1], 'String', "left")
            
           %% ML
           %CoP
           [APA_peak_ML, START_peak_ML, end_peak_ML, index_APA_peak_ML, RESULTS] = peak_APA_ML...
               (CoP_ML,[signalName{1}],taskName,start_index,mid_swing_index,DOM,j);
            
            %Acc_TP_ML
            [APA_peak_TP_ML, index_APA_peak_TP_ML, Acc_TP_ML, ~] = peak_Acc_TP_ML...
               (Acc_TP_ML,[signalName{3}],taskName,start_index,toe_off_index,DOM,j);
            
           
            %% AP
            [APA_peak_AP, START_peak_AP, end_peak_AP, index_APA_peak_AP, RESULTS1] = peak_APA_AP...
                (CoP_AP,[signalName{2}],taskName,start_index,toe_off_index,mid_swing_index,j);
             
            %Acc_TP_AP
%             [APA_peak_TP_AP, index_APA_peak_TP_AP, Acc_TP_AP, ~] = peak_Acc_TP_AP...
%                 (Acc_TP_AP,[signalName{4}],taskName,start_index,toe_off_index,j);
            
            if RESULTS
                continue
            end
            if RESULTS1
                continue
            end
            
           %apa duration
% if START_peak_ML<=START_peak_AP
%     START=START_peak_ML;
% else
%     START=START_peak_AP;
% end

%coversione unità di misura
%  duration = (toe_off_index-START); %centesimi di secondo
%  timetopeak_ML=(index_APA_peak_ML-START);
%  timetopeak_AP=(index_APA_peak_AP-START);
%  APA_peak_ML=APA_peak_ML*100; %cm
%  APA_peak_TP_ML=APA_peak_TP_ML; %m/s^2
%  APA_peak_AP=APA_peak_AP*100; %cm
%  APA_peak_TP_AP=APA_peak_TP_AP; %m/s^2
 
%  column={'B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'};            
%             xlswrite(filename,APA_peak_ML,1,[column{j} num2str(3*(p-1)+i+1)])
%             xlswrite(filename,APA_peak_TP_ML,2,[column{j} num2str(3*(p-1)+i+1)])
%             xlswrite(filename,APA_peak_AP,3,[column{j} num2str(3*(p-1)+i+1)])
%             xlswrite(filename,APA_peak_TP_AP,4,[column{j} num2str(3*(p-1)+i+1)])
%             xlswrite(filename,duration,5,[column{j} num2str(3*(p-1)+i+1)])
%             xlswrite(filename,timetopeak_ML,6,[column{j} num2str(3*(p-1)+i+1)])
%             xlswrite(filename,timetopeak_AP,7,[column{j} num2str(3*(p-1)+i+1)])  
            

%matrice con righe partecipanti e colonne le prove
% S(1).(task{j})(p,i)=APA_peak_ML;
% S(2).(task{j})(p,i)=APA_peak_TP_ML;
% S(3).(task{j})(p,i)=APA_peak_AP;
% S(4).(task{j})(p,i)=APA_peak_TP_AP;
% S(5).(task{j})(p,i)=duration;
% S(6).(task{j})(p,i)=timetopeak_ML;
% S(7).(task{j})(p,i)=timetopeak_AP;

           
%            figure
%             plot(GyrZ_domleg)            
%             hold on
%             plot(Acc_TP_ML)
%             plot(Acc_TP_AP)             
            
        end       
    end 
end

%close all
%tableforICC(S,filename)
%tablefortask(S)
%close all


