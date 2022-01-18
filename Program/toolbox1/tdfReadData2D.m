function [frequency,camMap,features] = tdfReadData2D (filename)
%TDFREADDATA2D   Read 2D data sequence from TDF-file.
%   [FREQUENCY,CAMMAP,FEATURES] = TDFREADDATA2D (FILENAME) retrieves from FILENAME
%   a 2D Data Sequence and stores it in FEATURES. FREQUENCY contains the frequency
%   ([Hz]) of the acquisition, CAMMAP the association map between camera logical
%   channels and physical channels.
%   CAMMAP is a [nCams,1] array such that CAMMAP(logical channel) == physical channel. 
%   FEATURES is a {nFrames,nCams} cell array such that FEATURES{F,C} is the [2,NPOINTS]
%   array of the NPOINTS features seen by camera C at frame F.
%
%   See also TDFWRITEDATA2D.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 4 $ $Date: 14/07/06 11.42 $

frequency=[]; camMap=[]; features=[];

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfData2DBlockId = 4;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfData2DBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Data 2D not found in the file specified.')
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

nCams       = fread (fid,1,'int32');
nFrames     = fread (fid,1,'int32');
frequency   = fread (fid,1,'int32');
startTime   = fread (fid,1,'float32');
fseek (fid,4,'cof');                              %skip Flags field

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read camera map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

camMap      = fread (fid,nCams,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read features data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

features = cell (nFrames,nCams);

if (1 == tdfBlockEntries(blockIdx).Format)        % RTS: Real Time Stream format
   for f = 1 : nFrames
      for c = 1 : nCams
         nFeatures = fread (fid,1,'int32');
         fseek (fid,4,'cof');
         features {f,c} = fread (fid,[2,nFeatures],'float32');
      end
   end
   
elseif (2 == tdfBlockEntries(blockIdx).Format)    % PCK: Packed Data format
   nFeatures = fread (fid,[nCams,nFrames],'int16');
   for f = 1 : nFrames
      for c = 1 : nCams
         features {f,c} = fread (fid,[2,nFeatures(c,f)],'float32');
      end
   end
   
elseif (3 == tdfBlockEntries(blockIdx).Format)    % SYNC: Synchronized Data format
   maxNFeatures = fread (fid,1,'int16');
   nFeatures    = fread (fid,[nCams,nFrames],'int16');
   for f = 1 : nFrames
      for c = 1 : nCams
         tmpBuffer = fread (fid,[2,maxNFeatures],'float32');
         features {f,c} = tmpBuffer(:,1:nFeatures(c,f));
      end
   end
   
end

tdfFileClose (fid);                               % close the file

   




