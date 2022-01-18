function res = tdfWriteCameraCalParams (filename,D,R,T,distModel,camMap,camParams)
%TDFWRITECAMERACALPARAMS   Write Cameras Calibration Parameters to TDF-file.
%   RES = TDFWRITECAMERACALPARAMS (FILENAME,D,R,T,DISTMODEL,CAMMAP,CAMPARAMS) 
%   writes to FILENAME the calibrated volume dimension vector(D), rotation matrix
%   (R) and translation vector (T), the distortion model applied (distModel), the
%   association map between camera logical channels and physical channels (CAMMAP)
%   and the cameras calibration parameters (CAMPARAMS).
%   CAMMAP must be a [nCams,1] array such that CAMMAP(logical channel) == physical channel.
%   CAMPARAMS must be a struct array of size nCams, its fields and meanings depend 
%   on the calibration and distortion models used.
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADCAMERACALPARAMS
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 5 $ $Date: 14/07/06 11.43 $

res = -1;
tdfCalibDataBlockId = 2;

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfCalibDataBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nCams = length (camMap);
switch (distModel)
case 'none'
   dModel = 0;
   if isfield (camParams,'KX')
      blockFormat = 2;
   else
      blockFormat = 1;
   end
case 'kali'
   dModel = 1;
   blockFormat = 2;
case 'amass'
   dModel = 2;
   blockFormat = 2;
case 'thor'
   dModel = 3;
   blockFormat = 1;
otherwise
   disp ('Error: distorsion model not recognized')
   tdfFileClose (fid);
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nCams,'int32');
fwrite (fid,dModel,'uint32');
fwrite (fid,D,'float32');
fwrite (fid,R','float32');
fwrite (fid,T,'float32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write camera map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,camMap,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write camera parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1 == blockFormat)                             % Seelab type 1 calibration
   for c = 1:nCams
      fwrite (fid,camParams(c).R','float64');
      fwrite (fid,camParams(c).T,'float64');
      fwrite (fid,camParams(c).F,'float64');
      fwrite (fid,camParams(c).C,'float64');
      fwrite (fid,camParams(c).K1,'float64');
      fwrite (fid,camParams(c).K2,'float64');
      fwrite (fid,camParams(c).K3,'float64');
      fwrite (fid,camParams(c).ViewPort,'int32'); % Origin = ViewPort(:,1); Size = ViewPort(:,2)
   end
   
elseif (2 == blockFormat)                         % Bts calibration
   for c = 1:nCams
      fwrite (fid,camParams(c).R','float64');
      fwrite (fid,camParams(c).T,'float64');
      fwrite (fid,camParams(c).F,'float64');
      fwrite (fid,camParams(c).C,'float64');
      fwrite (fid,camParams(c).KX,'float64');
      fwrite (fid,camParams(c).KY,'float64');
      fwrite (fid,camParams(c).ViewPort,'int32'); % Origin = ViewPort(:,1); Size = ViewPort(:,2)
   end
end   

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfCalibDataBlockId,'uint32');
fwrite (fid,blockFormat,'uint32');
fwrite (fid,blockOffset,'int32');
fwrite (fid,newBlockOffset-blockOffset,'int32');
tdfTime = (now - datenum ('02-Jan-1970 00:00:00') ) * 24 * 60 * 60;
fwrite (fid,tdfTime,'int32');
fwrite (fid,tdfTime,'int32');
fwrite (fid,tdfTime,'int32');
fwrite (fid,0,'uint32');
fwrite (fid,char (zeros (1,256)),'char');

tdfFileFinalize (fid,newBlockOffset);             % close the file
res = 0;

