function res = tdfWriteCalGenPurpose (filename,nChannels,Data,ChMap)
%TDFWRITECALGENPURPOSE  Write General Purpose Calibration Data to TDF-file.
%   RES = TDFWRITECALGENPURPOSE (FILENAME,NCHANNELS,DATA,CHMAP) writes 
%   to FILENAME the number of calibrated devices (NCHANNELS)
%   and for each one the calibration parameters Type,M,Q (DATA).
%   CHMAP is a [NCHANNELS,1] array such that CHMAP(logical channel) == physical channel. 
%
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADCALGENPURPOSE
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 1 $ $Date: 27/07/06 12.25 $

res = -1;
tdfDataBlockId = 15;
dwFlags     = 1;

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfDataBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nSamples = size (Data,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nChannels,'int32'); % nSignals
fwrite (fid,dwFlags,'uint32');  % reserved DWORD

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write channel map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,ChMap,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write calibration data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% fwrite (fid,Data','float32');

for s = 1 : nChannels
  fwrite(fid,Data(s, 1),'int32'); % set the DWORD which define the device type as a int32
  fwrite(fid,Data(s,2),'float'); % M
  fwrite(fid,Data(s,3),'float'); % Q
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

blockFormat = 1;

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfDataBlockId,'uint32');
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


