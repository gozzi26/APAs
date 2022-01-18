function [D,R,T,distModel,camMap,camParams] = tdfReadCameraCalParams (filename)
%TDFREADCAMERACALPARAMS   Read Cameras Calibration Parameters from TDF-file.
%   [D,R,T,DISTMODEL,CAMMAP,CAMPARAMS] = TDFREADCAMERACALPARAMS (FILENAME) 
%   retrieves from FILENAME the calibrated volume dimension vector(D),
%   rotation matrix (R) and translation vector (T), the distortion model
%   applied (distModel), the association map between camera logical channels
%   and physical channels (CAMMAP), the cameras calibration parameters (CAMPARAMS).
%   CAMMAP is a [nCams,1] array such that CAMMAP(logical channel) == physical channel. 
%   CAMPARAMS is a struct array of size nCams whose fields and meanings depend 
%   on the calibration and distortion models used.
%
%   See also TDFWRITECAMERACALPARAMS
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 5 $ $Date: 14/07/06 11.42 $

D=[]; R=[]; T=[]; camMap=[]; camParams=[]; distModel = '';

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfCalibDataBlockId = 2;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfCalibDataBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Cameras Calibration Parameters not found in the file specified.')
   tdfFileClose (fid);
   return
end

if (-1 == fseek (fid,tdfBlockEntries(blockIdx).Offset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nCams   = fread (fid,1,'int32');
dModel  = fread (fid,1,'uint32');
D       = fread (fid,3,'float32');
R       = (fread (fid,[3,3],'float32'))';
T       = fread (fid,3,'float32');

switch (dModel)
case 0
   distModel = 'none';
case 1
   distModel = 'kali';
case 2
   distModel = 'amass';
case 3
   distModel = 'thor';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read camera map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

camMap  = fread (fid,nCams,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read camera parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initCamParams = cell (1,nCams);

if (1 == tdfBlockEntries(blockIdx).Format)        % Seelab type 1 calibration
   camParams = struct ( ...
      'R',initCamParams, ...
      'T',initCamParams, ...
      'F',initCamParams, ...
      'C',initCamParams, ...
      'K1',initCamParams, ...
      'K2',initCamParams, ...
      'K3',initCamParams, ...
      'ViewPort',initCamParams);
   for c = 1:nCams
      camParams(c).R        = (fread (fid,[3,3],'float64'))';
      camParams(c).T        = fread (fid,3,'float64');
      camParams(c).F        = fread (fid,2,'float64');
      camParams(c).C        = fread (fid,2,'float64');
      camParams(c).K1       = fread (fid,2,'float64');
      camParams(c).K2       = fread (fid,2,'float64');
      camParams(c).K3       = fread (fid,2,'float64');
      camParams(c).ViewPort = fread (fid,[2,2],'int32');  % Origin = ViewPort(:,1); Size = ViewPort(:,2)
   end
   
elseif (2 == tdfBlockEntries(blockIdx).Format)    % Bts calibration
   camParams = struct ( ...
      'R',initCamParams, ...
      'T',initCamParams, ...
      'F',initCamParams, ...
      'C',initCamParams, ...
      'KX',initCamParams, ...
      'KY',initCamParams, ...
      'ViewPort',initCamParams);
   for c = 1:nCams
      camParams(c).R        = (fread (fid,[3,3],'float64'))';
      camParams(c).T        = fread (fid,3,'float64');
      camParams(c).F        = fread (fid,1,'float64');
      camParams(c).C        = fread (fid,2,'float64');
      camParams(c).KX       = fread (fid,70,'float64');
      camParams(c).KY       = fread (fid,70,'float64');
      camParams(c).ViewPort = fread (fid,[2,2],'int32');  % Origin = ViewPort(:,1); Size = ViewPort(:,2)
   end
end   

tdfFileClose (fid);                               % close the file

