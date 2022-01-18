clc
clear
close
load('partecipanti')
%dati SOGGETTO 1 :IMU e platData
load('sincro_Francesco')
p=3;

%% Suddivisione delle varie tracce
% in questa sezione un ciclo for permette l'individuazione delle tre prove
% fatte in una task. Gli 8 vettori che ne descrivono l'andamento in
% quell'intevallo vengono a loro volta salvati in un cell array
% precedentemente definito 'task%%' RICORDA di salvare il cell array nella
% struttura al termine dell'esecuzione

task = {'task1' 'task3' 'task5' 'task7' 'task9' 'task10' 'task11'};
prova = {'try1' 'try2' 'try3'};

signal=platData{1}(:,5);
mrk=track(:,1)+500;
figure
plot(signal)
hold on
plot(mrk)
title('1')
h=1;
for j=1:7
    for i=1:3
        %cerca inizio
        for q=h:length(signal)
            if ((isnan(mrk(q))) && (signal(q)>500))
                inizio=q;
                h=q;
                break
            end
        end
        %cerca fine
        for q=h:length(signal)
            if (isnan(mrk(q))==0) && (signal(q)<500)
                fine=q+100;
                h=q+100;
                break
            end
        end
        indice=[inizio fine];
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
        
        plot(inizio,560,'*')
        plot(fine,560,'s')
    end
end


task = {'task2' 'task4' 'task15' 'task12' 'task13' 'task8' 'task14' 'task6'};
prova = {'try1' 'try2' 'try3'};

signal=platData{2}(:,5);
mrk=track{2}(:,1)+500;
figure
plot(signal)
hold on
plot(mrk)
title('2')
h=1;
for j=1:8
    for i=1:3
        %cerca inizio
        for q=h:length(signal)
            if ((isnan(mrk(q))) && (signal(q)>500))
                inizio=q;
                h=q;
                break
            end
        end
        %cerca fine
        for q=h:length(signal)
            if (isnan(mrk(q))==0) && (signal(q)<500)
                fine=q+100;
                h=q+100;
                break
            end
        end
        indice=[inizio fine];
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
        
        plot(inizio,560,'*')
        plot(fine,560,'s')
    end
end

save('partecipanti','participant')

