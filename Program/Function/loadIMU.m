function [fc,M,AccX,AccY,AccZ,GyrX,GyrY,GyrZ,MagX,MagY,MagZ] = loadIMU(filenames)
M=load(filenames); % Nx16 Matrix, AccData 5°,6°,7° coloumn
						        % GyroData 8°,9°,10° coloumn
						        % MagData 11°,12°,13° coloumn

fc = 100;
Ka = 8 * 9.81 / 2^15; % 2^15 bit = 32768, AccFS=8 [g] def
Kg = 1000 / 2^15 *(pi/180); % 2^15 bit = 32768, GyrFS=1000 [dps] def
Km = (1200 / 2^15); % 1200/32768, MagFS=1200 [uT] fixed;
 
% Acc
AccX = M(:,5) * Ka; %[m/s^2]
AccY = M(:,6) * Ka;
AccZ = M(:,7) * Ka;
 
% Gyr
GyrX = M(:,8) * Kg; %[rad/s]
GyrY = M(:,9) * Kg;
GyrZ = M(:,10) * Kg;
 
% Mag
MagX = M(:,11) * Km; %[uT]
MagY = M(:,12) * Km;
MagZ = M(:,13) * Km;
end

