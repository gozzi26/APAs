function res = tdfWriteData2D (filename,frequency,camMap,features,varargin)
%TDFWRITEDATA2D   Write 2D data sequence to a TDF-file.
%   res = TDFWRITEDATA2D (FILENAME,FREQUENCY,CAMMAP,FEATURES) writes to 
%   FILENAME the 2D data sequence whose features are stored in FEATURES, 
%   characterized by FREQUENCY ([Hz]), and  by the cameras association map
%   stored in CAMMAP.
%   All the arguments must have the same structure as the ones retrieved by
%   TDFREADDATA2D.
%   res = TDFWRITEDATA2D (...,FORMAT) specifies the format for the 2D data block.
%   Valid entries for FORMAT are 'rts' (default), 'pck', 'sync'.
%   See Tdf File format documentation for further details.
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADDATA2D.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 7 $ $Date: 14/07/06 11.43 $

res = -1;

if (nargin == 4)
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

tdfData2DBlockId = 4;

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfData2DBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nFrames     = size (features,1);
nCams       = size (features,2);
startTime   = 0.0;
dwFlags     = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nCams,'int32');
fwrite (fid,nFrames,'int32');
fwrite (fid,frequency,'int32');
fwrite (fid,startTime,'float32');
fwrite (fid,dwFlags,'uint32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write camera map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,camMap,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write features data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1 == blockFormat)                             % RTS: Real Time Stream format
   for f = 1 : nFrames
      for c = 1 : nCams
         fwrite (fid,size(features{f,c},2),'int32');
         fwrite (fid,0,'uint32');
         fwrite (fid,features{f,c},'float32');
      end
   end
   
elseif (2 == blockFormat)                         % PCK: Packed Data format
   nFeatures = zeros (nCams,nFrames);
   for f = 1 : nFrames
      for c = 1 : nCams
         nFeatures(c,f) = size(features{f,c},2);
      end
   end
   fwrite (fid,nFeatures,'int16');
   for f = 1 : nFrames
      for c = 1 : nCams
         fwrite (fid,features{f,c},'float32');
      end
   end
   
elseif (3 == blockFormat)                         % SYNC: Synchronized Data format
   nFeatures = zeros (nCams,nFrames);
   for f = 1 : nFrames
      for c = 1 : nCams
         nFeatures(c,f) = size(features{f,c},2);
      end
   end
   maxNFeatures = max (max (nFeatures));
   fwrite (fid,maxNFeatures,'int16');
   fwrite (fid,nFeatures,'int16');
   for f = 1 : nFrames
      for c = 1 : nCams
         tmpBuffer = NaN * ones (2,maxNFeatures);
         tmpBuffer(:,1:nFeatures(c,f)) = features {f,c};
         fwrite (fid,tmpBuffer,'float32');
      end
   end
   
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfData2DBlockId,'uint32');
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

   

