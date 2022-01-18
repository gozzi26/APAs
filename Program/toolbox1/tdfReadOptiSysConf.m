function cameraChannels = tdfReadOptiSysConf (filename)
%TDFREADOPTISYSCONF   Read Cameras Physical Configuration from TDF-file.
%   CAMERACHANNELS = TDFREADOPTISYSCONF (FILENAME) retrieves from FILENAME
%   information about the optical system configuration.
%   CAMERACHANNELS is a struct array of size nChannels with the following fields: 
%     LogicCamIndex:  the logical camera index associated to that physical channel
%     LensName:       a description of the lens mounted
%     CamType:        a description of the camera type
%     CamName:        the camera name
%     CamViewport:    a 2x2 matrix whose first column is the origin, the second is
%                     the size of the camera view port
%
%   See also TDFWRITEOPTISYSCONF
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 3 $ $Date: 14/07/06 11.43 $

cameraChannels=[];

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfOptiSetupBlockId = 6;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfOptiSetupBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Cameras Physical Configuration not found in the file specified.')
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

nChannels	= fread (fid,1,'int32');
fseek (fid,4,'cof');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read channels information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initChannels = cell (1,nChannels);
cameraChannels = struct ( ...
   'LogicCamIndex',initChannels, ...
   'LensName',initChannels, ...
   'CamType',initChannels, ...
   'CamName',initChannels, ...
   'CamViewport',initChannels);

for c = 1:nChannels
   cameraChannels(c).LogicCamIndex 	= fread (fid,1,'int32');
   fseek (fid,4,'cof');
   lensName                       = char ((fread (fid,32,'uchar'))');
   camType                        = char ((fread (fid,32,'uchar'))');
   camName                        = char ((fread (fid,32,'uchar'))');
   cameraChannels(c).CamViewport  = fread (fid,[2,2],'int32');
   cameraChannels(c).LensName = strtok (lensName,char (0));
   cameraChannels(c).CamType  = strtok (camType,char (0));
   cameraChannels(c).CamName  = strtok (camName,char (0));
end

tdfFileClose (fid);                               % close the file


