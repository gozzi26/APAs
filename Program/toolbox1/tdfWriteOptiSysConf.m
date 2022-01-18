function res = tdfWriteOptiSysConf (filename,cameraChannels)
%TDFWRITEOPTISYSCONF   Write Cameras Physical Configuration to TDF-file.
%   RES = TDFWRITEOPTISYSCONF (FILENAME,CAMERACHANNELS) writes to FILENAME
%   the optical system configuration info stored in CAMERACHANNELS
%   CAMERACHANNELS must be a struct array of size nChannels with the following fields: 
%     LogicCamIndex:  the logical camera index associated to that physical channel
%     LensName:       a description of the lens mounted (max 32 chars)
%     CamType:        a description of the camera type (max 32 chars)
%     CamName:        the camera name (max 32 chars)
%     CamViewport:    a 2x2 matrix whose first column is the origin, the second is
%                     the size of the camera view port
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADOPTISYSCONF
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 6 $ $Date: 14/07/06 11.43 $

res = -1;
tdfOptiSetupBlockId = 6;

for c = 1 : length (cameraChannels)
   if (length (cameraChannels(c).LensName) > 32) | ...
         (length (cameraChannels(c).LensName) > 32) | ...
         (length (cameraChannels(c).LensName) > 32)
      disp ('Error: invalid labels')
      return
   end
end

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfOptiSetupBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nChannels = length (cameraChannels);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nChannels,'int32');
fwrite (fid,0,'uint32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write channels information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for c = 1:nChannels
   lensName = char (zeros (1,32));
   camType = lensName;
   camName = lensName;
   lensName(1:length (cameraChannels(c).LensName)) = cameraChannels(c).LensName;
   camType(1:length (cameraChannels(c).CamType)) = cameraChannels(c).CamType;
   camName(1:length (cameraChannels(c).CamName)) = cameraChannels(c).CamName;
   fwrite (fid,cameraChannels(c).LogicCamIndex,'int32');
   fwrite (fid,0,'uint32');
   fwrite (fid,lensName,'uchar');
   fwrite (fid,camType,'uchar');
   fwrite (fid,camName,'uchar');
   fwrite (fid,cameraChannels(c).CamViewport,'int32');
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blockFormat = 1;

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfOptiSetupBlockId,'uint32');
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


