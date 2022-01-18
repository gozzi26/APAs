function res = tdfWriteData2D4CameraCal (filename,frequency,camMap,axesFeatures,wandFeatures,axesPars,wandPars,varargin)
%TDFWRITEDATA2D4CAMERACAL   Write Axes and Wand 2D data sequences to TDF-file.
%   res = TDFWRITEDATA2D4CAMERACAL (FILENAME,FREQUENCY,CAMMAP,AXESFEATURES,WANDFEATURES,AXESPARS,WANDPARS)
%   writes to FILENAME the 2D data sequences stored in AXESFEATURES and WANDFEATURES
%   needed by the cameras calibration algorithm, characterized by FREQUENCY ([Hz]),
%   the cameras association map stored in CAMMAP, and the calibration set geometric
%   parameters stored in AXESPARS, WANDPARS.
%   All the arguments must have the same structure as the ones retrieved by
%   TDFREADDATA2D4CAMERACAL.
%   res = TDFWRITEDATA2D4CAMERACAL (...,FORMAT) specifies the format for the 2D data blocks.
%   Valid entries for FORMAT are 'rts' (default), 'pck', 'sync'.
%   See Tdf File format documentation for further details.
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADDATA2D, TDFREADDATA2D4CAMERACAL.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 5 $ $Date: 14/07/06 11.43 $

res = -1;

if (nargin == 7)
   strFormat   = 'rts';
else
   strFormat   = varargin{1};
end

switch strFormat
case 'rts'
   blockFormat = 1;
case 'pck'
   blockFormat = 2;
case 'sync'
   blockFormat = 3;
otherwise
   disp ('Error: invalid block format')
   return
end

tdfData2D4CBlockId = 3;

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfData2D4CBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nAxesFrames     = size (axesFeatures,1);
nWandFrames     = size (wandFeatures,1);
nAxesCams       = size (axesFeatures,2);
nWandCams       = size (wandFeatures,2);
nCams           = length (camMap);

if (nAxesCams ~= nCams) | (nWandCams ~= nCams)
   disp ('Error: the number of cameras in camMap, axesFeatures, wandFeatures')
   disp ('       must be consistent')
   tdfFileClose (fid)
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nCams,'int32');
fwrite (fid,nAxesFrames,'int32');
fwrite (fid,nWandFrames,'int32');
fwrite (fid,frequency,'int32');
fwrite (fid,nCams,'int32');
fwrite (fid,axesPars,'float32');
fwrite (fid,wandPars,'float32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write camera map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,camMap,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write features data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1 == blockFormat)                             % RTS: Real Time Stream format
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         fwrite (fid,size(axesFeatures{f,c},2),'int32');
         fwrite (fid,0,'uint32');
         fwrite (fid,axesFeatures{f,c},'float32');
      end
   end
   for f = 1 : nWandFrames
      for c = 1 : nCams
         fwrite (fid,size(wandFeatures{f,c},2),'int32');
         fwrite (fid,0,'uint32');
         fwrite (fid,wandFeatures{f,c},'float32');
      end
   end
   
elseif (2 == blockFormat)                         % PCK: Packed Data format
   nAxesFeatures = zeros (nCams,nAxesFrames);
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         nAxesFeatures(c,f) = size(axesFeatures{f,c},2);
      end
   end
   fwrite (fid,nAxesFeatures,'int16');
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         fwrite (fid,axesFeatures{f,c},'float32');
      end
   end
   nWandFeatures = zeros (nCams,nWandFrames);
   for f = 1 : nWandFrames
      for c = 1 : nCams
         nWandFeatures(c,f) = size(wandFeatures{f,c},2);
      end
   end
   fwrite (fid,nWandFeatures,'int16');
   for f = 1 : nWandFrames
      for c = 1 : nCams
         fwrite (fid,wandFeatures{f,c},'float32');
      end
   end
   
elseif (3 == blockFormat)                         % SYNC: Synchronized Data format
   nAxesFeatures = zeros (nCams,nAxesFrames);
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         nAxesFeatures(c,f) = size(axesFeatures{f,c},2);
      end
   end
   maxNAxesFeatures = max (max (nAxesFeatures));
   fwrite (fid,maxNAxesFeatures,'int16');
   fwrite (fid,nAxesFeatures,'int16');
   for f = 1 : nAxesFrames
      for c = 1 : nCams
         tmpBuffer = NaN * ones (2,maxNAxesFeatures);
         tmpBuffer(:,1:nAxesFeatures(c,f)) = axesFeatures {f,c};
         fwrite (fid,tmpBuffer,'float32');
      end
   end
   nWandFeatures = zeros (nCams,nWandFrames);
   for f = 1 : nWandFrames
      for c = 1 : nCams
         nWandFeatures(c,f) = size(wandFeatures{f,c},2);
      end
   end
   maxNWandFeatures = max (max (nWandFeatures));
   fwrite (fid,maxNWandFeatures,'int16');
   fwrite (fid,nWandFeatures,'int16');
   for f = 1 : nWandFrames
      for c = 1 : nCams
         tmpBuffer = NaN * ones (2,maxNWandFeatures);
         tmpBuffer(:,1:nWandFeatures(c,f)) = wandFeatures {f,c};
         fwrite (fid,tmpBuffer,'float32');
      end
   end
   
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfData2D4CBlockId,'uint32');
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

