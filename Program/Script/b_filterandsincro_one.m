clc
clear
close all
nome='Michele';

load(nome);


%% FILTRO
%filtro pedana con cutoff frequency of 20Hz
platData = filter_low(800,20,4,platData);

%% RICAMPIONAMENTO
%piattaforma
platData=platData(1:8:end,:);
%marker
track=track(1:2:end,:);
    
     
%% procedimento generico per la sincronizzazione
%DATI GENERICI -- inserisci i dati che vuoi sincronizzare
%piattaforma
platData_forceZ=platData(:,5);
%IMU
AccY=IMU_acc{2};


%% find peaks
figure
plot(platData_forceZ);
hold on
%devi prendere il terzo picco della terza prova
pause
[LOCS_plat,PKS_plat]=ginput(1);
plot(LOCS_plat,PKS_plat,'*');
Zero_plat=round(LOCS_plat);
%plot_IMU
plot(AccY);
pause
[LOCS_IMU,PKS_IMU]=ginput(1);
Zero_IMU=round(LOCS_IMU);%indice che corrisponde a zero nell'IMU


%% sincronizzazione
Scarto_Zero=Zero_IMU-Zero_plat;
%lascio il vettori derivanti dalla piattaforma lì dove sono 
%accelerazioni
if Scarto_Zero<0
    alpha=zeros(abs(Scarto_Zero),1);
    for j=1:9
        IMU_acc{j}=[alpha; IMU_acc{j}];
    end
    for j=1:9
        IMU_gyr{j}=[alpha; IMU_gyr{j}];
    end
else
    for j=1:9
        IMU_acc{j}=IMU_acc{j}(Scarto_Zero:end);
    end
    for j=1:9
        IMU_gyr{j}=IMU_gyr{j}(Scarto_Zero:end);
    end
end
 
figure
plot(platData_forceZ)
hold on
AccY=IMU_acc{2};
plot(AccY);
%% tolgo la parte iniziale
plot(track(:,1)+500)
pause
[x0,y0]=ginput(1);
Start_index=round(x0);

%% dati definitivi
%pedana
platData=platData(Start_index:end,:);
%marker (parte con la pedana. di conseguenza deve essere tolta la prima parte anche qui)
track=track(Start_index:end,:);
%IMU
for j=1:9
    IMU_acc{j}=IMU_acc{j}(Start_index:end);
end
for j=1:9
    IMU_gyr{j}=IMU_gyr{j}(Start_index:end);
end



%% filtro i dati dell'IMU con una ft=3.5Hz,
for j=1:9
    IMU_acc{j}=filter_low(100,3.5,8,IMU_acc{j});
end
for j=1:9
    IMU_gyr{j}=filter_low(100,3.5,8,IMU_gyr{j});
end


figure
plot(platData(:,5))
hold on
plot(IMU_acc{2})

save(['sincro_' nome],'IMU_acc','IMU_gyr','platData','track')