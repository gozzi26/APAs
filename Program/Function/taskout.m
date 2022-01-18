function [AccX_t,AccY_t,AccZ_t, AccX_dx,AccY_dx,AccZ_dx, AccX_sx,AccY_sx,AccZ_sx,...
          GyrX_t,GyrY_t,GyrZ_t, GyrX_dx,GyrY_dx,GyrZ_dx, GyrX_sx,GyrY_sx,GyrZ_sx, plat,marker] =...
          taskout(indice,IMU_acc,IMU_gyr,platData,track,N)
%   dati in ingresso tempi di inizio e fine restituisce la curva copresa
%   tra di essi
%trasformare tempi in indici
inizio=round(indice(1));
fine=round(indice(2));
%cambiare i vettori
AccX_t=IMU_acc{N*9+1}(inizio:fine);
AccY_t=IMU_acc{N*9+2}(inizio:fine);
AccZ_t=IMU_acc{N*9+3}(inizio:fine);

AccX_dx=IMU_acc{N*9+4}(inizio:fine);
AccY_dx=IMU_acc{N*9+5}(inizio:fine);
AccZ_dx=IMU_acc{N*9+6}(inizio:fine);

AccX_sx=IMU_acc{N*9+7}(inizio:fine);
AccY_sx=IMU_acc{N*9+8}(inizio:fine);
AccZ_sx=IMU_acc{N*9+9}(inizio:fine);

%Gyr
GyrX_t=IMU_gyr{N*9+1}(inizio:fine);
GyrY_t=IMU_gyr{N*9+2}(inizio:fine);
GyrZ_t=IMU_gyr{N*9+3}(inizio:fine);

GyrX_dx=IMU_gyr{N*9+4}(inizio:fine);
GyrY_dx=IMU_gyr{N*9+5}(inizio:fine);
GyrZ_dx=IMU_gyr{N*9+6}(inizio:fine);

GyrX_sx=IMU_gyr{N*9+7}(inizio:fine);
GyrY_sx=IMU_gyr{N*9+8}(inizio:fine);
GyrZ_sx=IMU_gyr{N*9+9}(inizio:fine);

plat=platData{N+1}(inizio:fine,:);

marker=track{N+1}(inizio:fine,:);
end

