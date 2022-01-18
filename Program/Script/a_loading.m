clc
clear all
close all
%IMU
%frequency=100Hz
% AccX = accelerazione ortogonale al terreno
% AccY = medio-laterale
% AccZ = antero-posteriore
%% ACCELEROMETRO L3-L4 ----> t
 [frequency_IMU,~,AccX_t_1,AccY_t_1,AccZ_t_1,GyrX_t_1,GyrY_t_1,GyrZ_t_1,~,~,~] = loadIMU('Francesco_TP_1.txt');
 [~,~,AccX_t_2,AccY_t_2,AccZ_t_2,GyrX_t_2,GyrY_t_2,GyrZ_t_2,~,~,~] = loadIMU('Francesco_TP_2.txt');
%ACCELEROMETRO GAMBA DX ----> dx
 [~,~,AccX_dx_1,AccY_dx_1,AccZ_dx_1,GyrX_dx_1,GyrY_dx_1,GyrZ_dx_1,~,~,~] = loadIMU('Francesco_RF_1.txt');
 [~,~,AccX_dx_2,AccY_dx_2,AccZ_dx_2,GyrX_dx_2,GyrY_dx_2,GyrZ_dx_2,~,~,~] = loadIMU('Francesco_RF_2.txt');
%ACCELEROMETRO GAMBA SX ----> sx
 [~,~,AccX_sx_1,AccY_sx_1,AccZ_sx_1,GyrX_sx_1,GyrY_sx_1,GyrZ_sx_1,~,~,~] = loadIMU('Francesco_LF_1.txt');
 [~,~,AccX_sx_2,AccY_sx_2,AccZ_sx_2,GyrX_sx_2,GyrY_sx_2,GyrZ_sx_2,~,~,~] = loadIMU('Francesco_LF_2.txt');
 
 IMU_acc={AccX_t_1,AccY_t_1,AccZ_t_1,...
     AccX_dx_1,AccY_dx_1,AccZ_dx_1,...
     AccX_sx_1,AccY_sx_1,AccZ_sx_1,...
     AccX_t_2,AccY_t_2,AccZ_t_2,...
     AccX_dx_2,AccY_dx_2,AccZ_dx_2,...
     AccX_sx_2,AccY_sx_2,AccZ_sx_2};
 
 IMU_gyr={GyrX_t_1,GyrY_t_1,GyrZ_t_1...
     GyrX_dx_1,GyrY_dx_1,GyrZ_dx_1,...
     GyrX_sx_1,GyrY_sx_1,GyrZ_sx_1,...
     GyrX_t_2,GyrY_t_2,GyrZ_t_2,...
     GyrX_dx_2,GyrY_dx_2,GyrZ_dx_2,...
     GyrX_sx_2,GyrY_sx_2,GyrZ_sx_2};

% %Pedana
% %frequency=800Hz
% % colum 1 -- medio-lateral CoP
% % colum 2 -- antero-posterior CoP
% % 3 -- force componet X
% % 4 -- force component Y
% % 5 -- force comonent Z
% % 6 -- Momentum on Z

 [~,frequency_plat,~,~,platData_1] = tdfReadDataPlat ('Francesco_1.tdf');
 platData_1=squeeze(platData_1);
 [~,~,~,~,platData_2] = tdfReadDataPlat ('Francesco_2.tdf');
 platData_2=squeeze(platData_2);
 
 platData={platData_1,platData_2};

% Stereofotogrammetria
[frequencyStereo,~,~,~,~,~,track_1] = tdfReadData3D ('Francesco_1.tdf');
[~,~,~,~,~,~,track_2] = tdfReadData3D ('Francesco_2.tdf');

track={track_1,track_2};

save('Francesco','IMU_acc','IMU_gyr','platData','track')