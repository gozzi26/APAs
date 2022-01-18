function [frequency,camMap,axesFeatures,wandFeatures,varargout] = tdfReadData2D4CameraCal (filename)
%TDFREADDATA2D4CAMERACAL   Read Axes and Wand 2D data sequences from TDF-file.
%   [FREQUENCY,CAMMAP,AXESFEATURES,WANDFEATURES] = TDFREADDATA2D4CAMERACAL (FILENAME) 
%   retrieves from FILENAME the frequency ([Hz]), the association map between cameras
%   logical channels and physical channels and the features of the 2D data sequences
%   acquired during the calibration procedure.
%   CAMMAP is a [nCams,1] array such that CAMMAP(logical channel) == physical channel. 
%   AXESFEATURES and WANDFEATURES are {nFrames,nCams} cell arrays such that
%   xxxxFEATURES{F,C} is the [2,NPOINTS] array of the NPOINTS features seen by camera C
%   at frame F.
%   [...,AXESPARS,WANDPARS] = TDFREADDATA2D4CAMERACAL (FILENAME) also retrieves the
%   geometric parameters that describe the calibration set used.
%   AXESPARS is a [9,1] array while WANDPARS is a [2,1] array. 
%   See Tdf File format documentation for further details.
%
%   See also TDFWRITEDATA2D, TDFWRITEDATA2D4CAMERACAL.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 5 $ $Date: 14/07/06 11.42 $

frequency=[]; camMap=[]; axesFeatures=[]; wandFeatures=[];
if (nargout == 6)
   varargout{5} = [];
   varargout{6} = [];
end

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfData2D4CBlockId = 3;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfData2D4CBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Data 2D for Cameras Calibration not found in the file specified.')
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
nAxesFrames = fread (fid,1,'int32');
nWandFrames = fread (fid,1,'int32');
frequency   = fread (fid,1,'int32');
fseek (fid,4,'cof');
axesPars    = fread (fid,9,'float32');
wandPars    = fread (fid,2,'float32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read camera map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

camMap      = fread (fid,nCams,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read features data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

axesFeatures = cell (nAxesFrames,nCams);
wandFeatures = cell (nWandFrames,nCams);

if (1 == tdfBlockEntries(blockIdx).Format)        % RTS: Real Time Stream format
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         nAxesFeatures = fread (fid,1,'int32');
         fseek (fid,4,'cof');
         axesFeatures {f,c} = fread (fid,[2,nAxesFeatures],'float32');
      end
   end
   for f = 1 : nWandFrames
      for c = 1 : nCams
         nWandFeatures = fread (fid,1,'int32');
         fseek (fid,4,'cof');
         wandFeatures {f,c} = fread (fid,[2,nWandFeatures],'float32');
      end
   end
   
elseif (2 == tdfBlockEntries(blockIdx).Format)    % PCK: Packed Data format
   nAxesFeatures = fread (fid,[nCams,nAxesFrames],'int16');
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         axesFeatures {f,c} = fread (fid,[2,nAxesFeatures(c,f)],'float32');
      end
   end
   nWandFeatures = fread (fid,[nCams,nWandFrames],'int16');
   for f = 1 : nWandFrames
      for c = 1 : nCams
         wandFeatures {f,c} = fread (fid,[2,nWandFeatures(c,f)],'float32');
      end
   end
   
elseif (3 == tdfBlockEntries(blockIdx).Format)    % SYNC: Synchronized Data format
   maxNAxesFeatures 	= fread (fid,1,'int16');
   nAxesFeatures 		= fread (fid,[nCams,nAxesFrames],'int16');
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         tmpBuffer = fread (fid,[2,maxNAxesFeatures],'float32');
         axesFeatures {f,c} = tmpBuffer(:,1:nAxesFeatures(c,f));
      end
   end
   maxNWandFeatures 	= fread (fid,1,'int16');
   nWandFeatures 		= fread (fid,[nCams,nWandFrames],'int16');
   for f = 1 : nWandFrames
      for c = 1 : nCams
         tmpBuffer = fread (fid,[2,maxNWandFeatures],'float32');
         wandFeatures {f,c} = tmpBuffer(:,1:nWandFeatures(c,f));
      end
   end
   
end

if (nargout == 6)
   varargout {1} = axesPars;
   varargout {2} = wandPars;
end

tdfFileClose (fid);                               % close the file

