clc
clear
close
%load('partecipanti')
%dati SOGGETTO 1 :IMU e platData
load('sincro_Camilla')
p=1;

%% Suddivisione delle varie tracce
% in questa sezione un ciclo for permette l'individuazione delle tre prove
% fatte in una task. Gli 8 vettori che ne descrivono l'andamento in
% quell'intevallo vengono a loro volta salvati in un cell array
% precedentemente definito 'task%%' RICORDA di salvare il cell array nella
% struttura al termine dell'esecuzione

task = {'task3' 'task4' 'task10' 'task7' 'task9' 'task11' 'task8'};
prova = {'try1' 'try2' 'try3'};
figure
plot(platData{1}(:,5))
hold on
plot(track{1}(:,1)+500)
pause
for j=1:7
    for i=1:3
        pause
        [indice,~]=ginput(2);
        [AccX_t,AccY_t,AccZ_t, AccX_dx,AccY_dx,AccZ_dx,...
            AccX_sx,AccY_sx,AccZ_sx,...
            GyrX_t,GyrY_t,GyrZ_t, GyrX_dx,GyrY_dx,GyrZ_dx,...
            GyrX_sx,GyrY_sx,GyrZ_sx,...
            plat,marker] = taskout(indice,IMU_acc,IMU_gyr,platData,track,0);
        
        participant(p).(task{j}).(prova{i}).plat=plat;
        participant(p).(task{j}).(prova{i}).IMUacc=[AccX_t,AccY_t,AccZ_t,...
            AccX_dx,AccY_dx,AccZ_dx,AccX_sx,AccY_sx,AccZ_sx];
        participant(p).(task{j}).(prova{i}).IMUgyr=[GyrX_t,GyrY_t,GyrZ_t,...
            GyrX_dx,GyrY_dx,GyrZ_dx,GyrX_sx,GyrY_sx,GyrZ_sx,];
        participant(p).(task{j}).(prova{i}).MK=marker;
    end
end

task = {'task1' 'task5' 'task15' 'task13' 'task14' 'task6' 'task12' 'task2'};
prova = {'try1' 'try2' 'try3'};

figure
plot(platData{2}(:,5))
hold on
plot(track{2}(:,1)+500)
pause
for j=1:8
    for i=1:3
        pause
        [indice,~]=ginput(2);
      [AccX_t,AccY_t,AccZ_t, AccX_dx,AccY_dx,AccZ_dx,...
            AccX_sx,AccY_sx,AccZ_sx,...
            GyrX_t,GyrY_t,GyrZ_t, GyrX_dx,GyrY_dx,GyrZ_dx,...
            GyrX_sx,GyrY_sx,GyrZ_sx,...
            plat,marker] = taskout(indice,IMU_acc,IMU_gyr,platData,track,1);
        
        participant(p).(task{j}).(prova{i}).plat=plat;
        participant(p).(task{j}).(prova{i}).IMUacc=[AccX_t,AccY_t,AccZ_t,...
            AccX_dx,AccY_dx,AccZ_dx,AccX_sx,AccY_sx,AccZ_sx];
        participant(p).(task{j}).(prova{i}).IMUgyr=[GyrX_t,GyrY_t,GyrZ_t,...
            GyrX_dx,GyrY_dx,GyrZ_dx,GyrX_sx,GyrY_sx,GyrZ_sx,];
        participant(p).(task{j}).(prova{i}).MK=marker;
    end
end

save('partecipanti','participant')