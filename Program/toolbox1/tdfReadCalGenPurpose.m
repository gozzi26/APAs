function [nChannels,Data,Map] = tdfReadCalGenPurpose (filename)
%TDFREADCALGENPURPOSE Read Calibration Data from a TDF-file.
%   [NCHANNELS,DATA,CHMAP] = TDFREADCALGENPURPOSE (FILENAME) 
%   retrieves from FILENAME the number of calirated devices (NCHANNELS) 
%   and their calibration parameters (DATA).
%   DATA is a [NCANNELS, 3] array and the three fields of the i-th row is 
%   the calibration parameters: device type, M factor, Q factor.
%   CHMAP is a [NCHANNELS,1] array such that CHMAP(logical channel) == physical channel. 
%
%   See also TDFWRITECALGENPURPOSE
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 2 $ $Date: 27/07/06 12.26 $

Data =[];
Map  =[];
nChannels = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,tdfBlockEntries] = tdfFileOpen (filename);   
if fid == -1
   return
end

tdfDataVolumeBlockId = 15;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfDataVolumeBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Data not found in the file specified.')
   tdfFileClose (fid);
   return
end

if (-1 == fseek (fid,tdfBlockEntries(blockIdx).Offset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nSignals  = fread (fid,1,'int32');
fseek (fid,4,'cof');                  % skip the reserved DWORD

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read signal map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Map = fread (fid,nSignals,'int16');    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read calibration data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data     = NaN * ones(nSignals,3);

for s = 1 : nSignals
  Data(s, 1) = fread (fid,1,'int32');   % get the DWORD which define the device type as a int32
  Data(s, 2:3) = (fread (fid,2,'float'))'; % get M and Q
end

nChannels = nSignals;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tdfFileClose (fid);                               


