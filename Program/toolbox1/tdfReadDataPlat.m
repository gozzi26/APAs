function [startTime,frequency,platMap,labels,platData] = tdfReadDataPlat (filename)
%TDFREADDATAPLAT   Read Platform Data from TDF-file.
%   [STARTTIME,FREQUENCY,PLATMAP,LABELS,PLATDATA] = TDFREADDATAPLAT (FILENAME) retrieves
%   the platforms sampling start time ([s]), the platforms sampling rate ([Hz]), 
%   the correspondance map (PLATMAP) between platform logical channels and physical
%   channels, a matrix (LABELS) with the text strings of the tracks as rows
%   and the platforms data (PALTDATA) stored in FILENAME.
%   PLATMAP is a [nPlats,1] array such that PLATMAP(logical channel) == physical channel. 
%   PLATDATA is a [nPlats,nSamples,6] array whose submatrixes PLATDATA(p,:,:) 
%   are nSamplesx6 matrixes such that in the first 2 columns there are the samples of 
%   the position of the force application point, in the column 3 : 5 there are the samples 
%   of the force components and in the 6th column there are the samples of the torque.
%
%   If the format of the datablock is 'double' (or DBL) instead, PLATDATA is a [nPlats,nSamples,12]
%   whose submatrixes PLATDATA(p,:,:) is a nSamplesx12 such that in the
%   first 6 columns there are the application point,force and torque of the
%   right device, in the last 6 columns there are the same data about the left device.
%   
%
%   See also TDFWRITEDATAPLAT
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 6 $ $Date: 14/07/06 11.42 $

platMap  = []; 
labels   = [];
platData = [];

startTime         = 0;  
frequency         = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open file and datablock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fid,tdfBlockEntries] = tdfFileOpen (filename);   
if fid == -1
   return
end

tdfDataPlatBlockId = 9;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfDataPlatBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Platform Data not found in the file specified.')
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

nPlats    = fread (fid,1,'int32');
frequency = fread (fid,1,'int32');
startTime = fread (fid,1,'float32');
nSamples  = fread (fid,1,'int32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read platform map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

platMap = fread (fid,nPlats,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the output containter of the labels 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (3 == tdfBlockEntries(blockIdx).Format) | ... % ISS byTrack withLabels
   (4 == tdfBlockEntries(blockIdx).Format) | ... % ISS byFrame withLabels
   (7 == tdfBlockEntries(blockIdx).Format) | ... % DBL byTrack withLabels
   (8 == tdfBlockEntries(blockIdx).Format)       % DBL byFrame withLabels
  labels = char (zeros (nPlats,256));
else
  labels = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read platforms data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Format ISS (single)
if (1 == tdfBlockEntries(blockIdx).Format) | ... % byTrack 
   (2 == tdfBlockEntries(blockIdx).Format) | ... % byFrame
   (3 == tdfBlockEntries(blockIdx).Format) | ... % byTrack withLabels
   (4 == tdfBlockEntries(blockIdx).Format)       % byFrame withLabels

  platData = NaN * ones(nPlats,nSamples,6);      % each sample is [ Appl.Point (2 float), Force (3 float), Torque (float)  ]
  tempData = zeros(1,nPlats,6);
  
  if (1 == tdfBlockEntries(blockIdx).Format ) | (3 == tdfBlockEntries(blockIdx).Format)
    % by track
    for p = 1 : nPlats
      if (3 == tdfBlockEntries(blockIdx).Format)
        label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
        labels (p, 1:length (label)) = label;
      end
      nSegments  = fread (fid,1,'int32');
      fseek (fid,4,'cof');
      segments   = fread (fid,[2,nSegments],'int32');
      for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
            platData(p,f,:) = fread (fid,6,'float32');
         end
      end
    end
  elseif (2 == tdfBlockEntries(blockIdx).Format) | (4 == tdfBlockEntries(blockIdx).Format)     
    % by frame
    if (4 == tdfBlockEntries(blockIdx).Format)
      for p= 1 : nPlats
        label = strtok (char ((fread (fid,256,'uchar'))'), char (0));
        labels(p,1:length (label)) = label;
      end
    end
    for f = 1 : nSamples
      tempData(1,:,:) = fread (fid,[nPlats,6],'float32');
      platData(:,f,:) = permute(tempData,[2,1,3]);
    end
  end
  
end

% Format DBL (double)
if (5 == tdfBlockEntries(blockIdx).Format) | ... % byTrack 
   (6 == tdfBlockEntries(blockIdx).Format) | ... % byFrame
   (7 == tdfBlockEntries(blockIdx).Format) | ... % byTrack withLabels
   (8 == tdfBlockEntries(blockIdx).Format)       % byFrame withLabels

  platData = NaN * ones(nPlats,nSamples,6*2); % each sample is 
  tempData = zeros(1,nPlats,6*2);             % [ R.Appl.Point (2 float), R.Force (3 float), R.Torque (float), L.Appl.Point (2 float), L.Force (3 float), L.Torque (float)]
  
  if (5 == tdfBlockEntries(blockIdx).Format ) | (7 == tdfBlockEntries(blockIdx).Format)
    % by track
    for p = 1 : nPlats
      if (7 == tdfBlockEntries(blockIdx).Format)
        label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
        labels (p, 1:length (label)) = label;
      end
      nSegments  = fread (fid,1,'int32');
      fseek (fid,4,'cof');
      segments   = fread (fid,[2,nSegments],'int32');
      for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
            platData(p,f,:) = fread (fid,12,'float32');
         end
      end
    end
  elseif (6 == tdfBlockEntries(blockIdx).Format) | (8 == tdfBlockEntries(blockIdx).Format)     
    % by frame
    if (8 == tdfBlockEntries(blockIdx).Format)
      for p= 1 : nPlats
        label = strtok (char ((fread (fid,256,'uchar'))'), char (0));
        labels(p,1:length (label)) = label;
      end
    end
    for f = 1 : nSamples
      tempData(1,:,:) = fread (fid,[nPlats,12],'float32');
      platData(:,f,:) = permute(tempData,[2,1,3]);
    end
  end 
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tdfFileClose (fid);


