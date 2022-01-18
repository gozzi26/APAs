function res = tdfWritePlatCalParams (filename,platMap,platParams)
%TDFWRITEPLATCALPARAMS   Write Platforms Calibration Parameters to TDF-file.
%   RES = TDFREADPLATCALPARAMS (FILENAME,PLATMAP,PLATPARAMS) writes the correspondance
%   map between platform logical channels and physical channels (PLATMAP) and 
%   the platforms calibration parameters (PLATPARAMS) to FILENAME.
%   PLATMAP must be a [nPlats,1] array such that PLATMAP(logical channel) == physical channel. 
%   PLATPARAMS must be a struct array of size nPlats with fields: 
%     Label:      a brief description of the platform (max 256 chars)
%     Size:       a 2x1 array containing the size [m] of the platform
%     Position:   a 3x4 matrix whose columns are the positions of the 4 vertices of the
%                 platforms in the calibrated volume
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADPLATCALPARAMS
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 6 $ $Date: 14/07/06 11.43 $

for p = 1 : length (platParams)
   if (length (platParams(p).Label) > 256)
      disp ('Error: invalid label')
      return
   end
end

res = -1;
tdfCalPlatBlockId = 7;

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfCalPlatBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nPlats = length (platMap);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nPlats,'int32');
fwrite (fid,0,'uint32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write platform map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,platMap,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write platforms parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for p = 1:nPlats
   label = char (zeros (1,256));
   label (1:length (platParams(p).Label)) = platParams(p).Label;
   fwrite (fid,label,'uchar');
   fwrite (fid,platParams(p).Size,'float32');
   fwrite (fid,platParams(p).Position,'float32');
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blockFormat = 1;

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfCalPlatBlockId,'uint32');
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








