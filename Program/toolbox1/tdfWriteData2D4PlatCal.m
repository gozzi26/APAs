function res = tdfWriteData2D4PlatCal (filename,frequency,camMap,platMap,platInfo,platFeatures,varargin)
%TDFWRITEDATA2D4PLATCAL   Write platform 2D data sequences for platforms calibration to TDF-file.
%   RES = TDFWRITEDATA2D4PLATCAL (FILENAME,FREQUENCY,CAMMAP,PLATMAP,PLATINFO,PLATFEATURES) 
%   writes to FILENAME the 2D data sequences stored in PLATFEATURES needed by the platforms
%   calibration algorithm, characterized by FREQUENCY ([Hz]), the cameras association map 
%   stored in CAMMAP, the platforms association map stored in PLATMAP, and  the additional
%   info about the platforms stored in PLATINFO.
%   All the arguments must have the same structure as the ones retrieved by
%   TDFREADDATA2D4PLATCAL. The platform labels stored in PLATINFO must be no more than 32
%   chars long.
%   res = TDFWRITEDATA2D4PLATCAL (...,FORMAT) specifies the format for the 2D data blocks.
%   Valid entries for FORMAT are 'rts' (default), 'pck', 'sync'.
%   See Tdf File format documentation for further details.
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADDATA2D, TDFREADDATA2D4PLATCAL.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 4 $ $Date: 14/07/06 11.43 $

res = -1;

if (nargin == 6)
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

tdfData2D4PBlockId = 8;

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfData2D4PBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nPlats      = length (platMap);
nCams       = length (camMap);

for p = 1 : nPlats
   if (length (platInfo(p).Label) > 32)
      disp ('Error: a platform label is too long.')
      tdfFileClose (fid);
      return
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nPlats,'int32');
fwrite (fid,nCams,'int32');
fwrite (fid,frequency,'int32');
fwrite (fid,0,'uint32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write camera and platform map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,camMap,'int16');
fwrite (fid,platMap,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write features data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for p = 1 : nPlats
   label = char (zeros (1,32));
   label (1:length (platInfo(p).Label)) = platInfo(p).Label;
   features = platFeatures{p};
   nFrames = size (features,1);
   
   fwrite (fid,label,'uchar');
   fwrite (fid,nFrames,'int32');
   fwrite (fid,platInfo(p).Size,'float32');
   
   if (1 == blockFormat)                          % RTS: Real Time Stream format
      for f = 1 : nFrames
         for c = 1 : nCams
            fwrite (fid,size(features{f,c},2),'int32');
            fwrite (fid,0,'uint32');
            fwrite (fid,features{f,c},'float32');
         end
      end
      
   elseif (2 == blockFormat)                      % PCK: Packed Data format
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
      
   elseif (3 == blockFormat)                      % SYNC: Synchronized Data format
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
   
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfData2D4PBlockId,'uint32');
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

