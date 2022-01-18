function [startTime,frequency,labels,Data,ChMap] = tdfReadDataGenPurpose (filename)
%TDFREADDATAGENPURPOSE Read Data from a General Purpose Datablock in a TDF-file.
%   [STARTTIME,FREQUENCY,LABELS,DATA,CHMAP] = TDFREADDATAGENPURPOSE (FILENAME) retrieves
%   the data sampling start time ([s]) and sampling rate ([Hz]), 
%   and the data of the GENPURP datablock stored in FILENAME.
%   LABELS is a matrix with the text strings of the data tracks as rows.
%   DATA is a [nTracks,nSamples] array such that DATA(s,:) stores 
%   the samples of the track s. 
%   CHMAP is a [nSignals,1] array such that CHMAP(logical channel) == physical channel. 
%
%   See also TDFWRITEDATAGENPURPOSE
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 2 $ $Date: 27/07/06 12.26 $

Data  = [];
ChMap = [];
frequency=0;
startTime=0;
labels = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,tdfBlockEntries] = tdfFileOpen (filename);   
if fid == -1
   return
end

tdfDataVolumeBlockId = 14;
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
% read header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nSignals  = fread (fid,1,'int32');
frequency = fread (fid,1,'int32');
startTime = fread (fid,1,'float32');
nFrames   = fread (fid,1,'int32');  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read channel map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ChMap = fread (fid,nSignals,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labels   = char (zeros (nSignals,256));
Data     = NaN * ones(nSignals,nFrames);

if (1 == tdfBlockEntries(blockIdx).Format)         
  
  % by track
  % --------
   for e = 1 : nSignals
      label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (e,1:length (label)) = label;
      nSegments  = fread (fid,1,'int32');
      fseek (fid,4,'cof');
      segments   = fread (fid,[2,nSegments],'int32');
      for s = 1 : nSegments
        Data(e,segments(1,s)+1 : (segments(1,s)+segments(2,s))) = (fread (fid,segments(2,s),'float32'))';
      end
   end
elseif (2 == tdfBlockEntries(blockIdx).Format)     
  
  % by frame
  % --------
   for e = 1 : nSignals
      label = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (e,1:length (label)) = label;
   end
   Data = (fread (fid,[nSamples,nSignals],'float32'))';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tdfFileClose (fid);                               


