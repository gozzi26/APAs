clc
clear all
close all

load ('Francesco');

for i=1:2
%% FILTRO
%filtro pedana con cutoff frequency of 20Hz
platData{i} = filter_low(800,20,4,platData{i});

%% RICAMPIONAMENTO
%piattaforma
platData{i}=platData{i}(1:8:end,:);
%marker
track{i}=track{i}(1:2:end,:);
    
     
%% procedimento generico per la sincronizzazione
%DATI GENERICI -- inserisci i dati che vuoi sincronizzare
%piattaforma
platData_forceZ=platData{i}(:,5);
%IMU
AccY=IMU_acc{9*i-7};


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
        IMU_acc{j+9*(i-1)}=[alpha; IMU_acc{j+9*(i-1)}];
    end
    for j=1:9
        IMU_gyr{j+9*(i-1)}=[alpha; IMU_gyr{j+9*(i-1)}];
    end
else
    for j=1:9
        IMU_acc{j+9*(i-1)}=IMU_acc{j+9*(i-1)}(Scarto_Zero:end);
    end
    for j=1:9
        IMU_gyr{j+9*(i-1)}=IMU_gyr{j+9*(i-1)}(Scarto_Zero:end);
    end
end
 
figure
plot(platData_forceZ)
hold on
AccY=IMU_acc{9*i-7};
plot(AccY);
%% tolgo la parte iniziale
plot(track{i}(:,1)+500)
pause
[x0,y0]=ginput(1);
Start_index=round(x0);

%% dati definitivi
%pedana
platData{i}=platData{i}(Start_index:end,:);
%marker (parte con la pedana. di conseguenza deve essere tolta la prima parte anche qui)
track{i}=track{i}(Start_index:end,:);
%IMU
for j=1:9
    IMU_acc{j+9*(i-1)}=IMU_acc{j+9*(i-1)}(Start_index:end);
end
for j=1:9
    IMU_gyr{j+9*(i-1)}=IMU_gyr{j+9*(i-1)}(Start_index:end);
end



%% filtro i dati dell'IMU con una ft=3.5Hz,
for j=1:9
    IMU_acc{j+9*(i-1)}=filter_low(100,3.5,8,IMU_acc{j+9*(i-1)});
end
for j=1:9
    IMU_gyr{j+9*(i-1)}=filter_low(100,3.5,8,IMU_gyr{j+9*(i-1)});
end


figure
plot(platData{i}(:,5))
hold on
plot(IMU_acc{i*9-7})
end
save('sincro_Francesco','IMU_acc','IMU_gyr','platData','track')
