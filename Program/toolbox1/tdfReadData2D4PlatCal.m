function [frequency,camMap,platMap,platInfo,platFeatures] = tdfReadData2D4PlatCal (filename)
%TDFREADDATA2D4PLATCAL   Read platform 2D data sequences for platforms calibration from TDF-file.
%   [FREQUENCY,CAMMAP,PLATMAP,PLATINFO,PLATFEATURES] = TDFREADDATA2D4PLATCAL (FILENAME) 
%   retrieves from FILENAME the 2D Data Sequences acquired for the platforms calibration procedure,
%   the frequency ([Hz]) of the acquisition (FREQUENCY), the association map between camera logical
%   channels and physical channels (CAMMAP), the association map between platform logical channels
%   and physical channels (PLATMAP) and additonal info about the platforms (PLATINFO).
%   CAMMAP is a [nCams,1] array such that CAMMAP(logical channel) == physical channel. 
%   PLATMAP is a [nPlats,1] array such that PLATMAP(logical channel) == physical channel. 
%   PLATINFO is a struct array of size nPlats whose fields are: 
%     Label:      a brief description of the platform
%     Size:       a 2x1 array containing the size [m] of the platform
%   PLATFEATURES is a {1,nPlats} cell array whose cells are {nFrames,nCams} cell arrays such that
%   if PF = PLATFEATURES{platIdx}, then PF{F,C} is the [2,NPOINTS] array of the NPOINTS features
%   seen by camera C at frame F during the acquisition of the platform platIdx.
%
%   See also TDFWRITEDATA2D, TDFWRITEDATA2D4PLATCAL.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 4 $ $Date: 14/07/06 11.42 $

frequency=[]; camMap=[]; platMap=[]; platInfo=[]; platFeatures=[];

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfData2D4PBlockId = 8;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfData2D4PBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Data 2D for Platforms Calibration not found in the file specified.')
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
nCams     = fread (fid,1,'int32');
frequency = fread (fid,1,'int32');
fseek (fid,4,'cof');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read camera and platform map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

camMap    = fread (fid,nCams,'int16');
platMap   = fread (fid,nPlats,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read features data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

platFeatures = cell (1,nPlats);
platInfo = struct ( ...
   'Label',platFeatures, ...
   'Size',platFeatures);

for p = 1 : nPlats
   platInfo(p).Label = strtok (char ((fread (fid,32,'uchar'))'), char (0));
   nPlatFrames       = fread (fid,1,'int32');
   platInfo(p).Size  = fread (fid,2,'float32'); 
   features = cell (nPlatFrames,nCams);
   
   if (1 == tdfBlockEntries(blockIdx).Format)     % RTS: Real Time Stream format
      for f = 1 : nPlatFrames
         for c = 1 : nCams
            nFeatures = fread (fid,1,'int32');
            fseek (fid,4,'cof');
            features {f,c} = fread (fid,[2,nFeatures],'float32');
         end
      end
      
   elseif (2 == tdfBlockEntries(blockIdx).Format) % PCK: Packed Data format
      nFeatures = fread (fid,[nCams,nPlatFrames],'int16');
      for f = 1 : nPlatFrames
         for c = 1 : nCams
            features {f,c} = fread (fid,[2,nFeatures(c,f)],'float32');
         end
      end
      
   elseif (3 == tdfBlockEntries(blockIdx).Format) % SYNC: Synchronized Data format
      maxNFeatures 	= fread (fid,1,'int16');
      nFeatures      = fread (fid,[nCams,nPlatFrames],'int16');
      for f = 1 : nPlatFrames
         for c = 1 : nCams
            tmpBuffer = fread (fid,[2,maxNFeatures],'float32');
            features {f,c} = tmpBuffer(:,1:nFeatures(c,f));
         end
      end
      
   end
   platFeatures{p} = features;
   
end

tdfFileClose (fid);                               % close the file

