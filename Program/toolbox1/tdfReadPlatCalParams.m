function [platMap,platParams] = tdfReadPlatCalParams (filename)
%TDFREADPLATCALPARAMS   Read Platforms Calibration Parameters from TDF-file.
%   [PLATMAP,PLATPARAMS] = TDFREADPLATCALPARAMS (FILENAME) retrieves the
%   correspondance map between platform logical channels and physical channels and 
%   the platforms calibration parameters (PLATPARAMS) stored in FILENAME.
%   PLATMAP is a [nPlats,1] array such that PLATMAP(logical channel) == physical channel. 
%   PLATPARAMS is a struct array of size nPlats whose fields are: 
%     Label:      a brief description of the platform
%     Size:       a 2x1 array containing the size [m] of the platform
%     Position:   a 3x4 matrix whose columns are the positions of the 4 vertices of the
%                 platforms in the calibrated volume
%
%   See also TDFWRITEPLATCALPARAMS
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 5 $ $Date: 14/07/06 11.43 $

platMap=[]; platParams=[];

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfCalPlatBlockId = 7;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfCalPlatBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Platforms Calibration Parameters not found in the file specified.')
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

nPlats  = fread (fid,1,'int32');
fseek (fid,4,'cof');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read platform map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

platMap = fread (fid,nPlats,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read platforms parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initPlatParams = cell (1,nPlats);

platParams = struct ( ...
   'Label',initPlatParams, ...
   'Size',initPlatParams, ...
   'Position',initPlatParams);

for p = 1:nPlats
   platParams(p).Label 		= strtok (char ((fread (fid,256,'uchar'))'), char (0));
   platParams(p).Size 		= fread (fid,2,'float32');
   platParams(p).Position 	= fread (fid,[3,4],'float32');
end

tdfFileClose (fid);                               % close the file







