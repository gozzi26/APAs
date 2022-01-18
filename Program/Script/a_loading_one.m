clc
clear
close all
nome='Michele';

%IMU
%frequency=100Hz
% AccX = accelerazione ortogonale al terreno
% AccY = medio-laterale
% AccZ = antero-posteriore
%% ACCELEROMETRO L3-L4 ----> t
 [frequency_IMU,~,AccX_t,AccY_t,AccZ_t,GyrX_t,GyrY_t,GyrZ_t,~,~,~] = loadIMU([nome '_TP.txt']);
%ACCELEROMETRO GAMBA DX ----> dx
 [~,~,AccX_dx,AccY_dx,AccZ_dx,GyrX_dx,GyrY_dx,GyrZ_dx,~,~,~] = loadIMU([nome '_RF.txt']);
%ACCELEROMETRO GAMBA SX ----> sx
 [~,~,AccX_sx,AccY_sx,AccZ_sx,GyrX_sx,GyrY_sx,GyrZ_sx,~,~,~] = loadIMU([nome,'_LF.txt']);
 
 IMU_acc={AccX_t,AccY_t,AccZ_t,...
     AccX_dx,AccY_dx,AccZ_dx,...
     AccX_sx,AccY_sx,AccZ_sx};
 
 IMU_gyr={GyrX_t,GyrY_t,GyrZ_t...
     GyrX_dx,GyrY_dx,GyrZ_dx,...
     GyrX_sx,GyrY_sx,GyrZ_sx};

% %Pedana
% %frequency=800Hz
% % colum 1 -- medio-lateral CoP
% % colum 2 -- antero-posterior CoP
% % 3 -- force componet X
% % 4 -- force component Y
% % 5 -- force comonent Z
% % 6 -- Momentum on Z

 [~,frequency_plat,~,~,platData] = tdfReadDataPlat([nome '.tdf']);
 platData=squeeze(platData);

 
% platData={platData};

% Stereofotogrammetria
[frequencyStereo,~,~,~,~,~,track] = tdfReadData3D ([nome '.tdf']);

%track={track_1};

save(nome,'IMU_acc','IMU_gyr','platData','track')