function res = tdfWriteDataPlat (filename,startTime,frequency,platMap,labels,platData,varargin)
%TDFWRITEDATAPLAT   Write Platform Data to TDF-file.
%   RES = TDFWRITEDATAPLAT (FILENAME,STARTTIME,FREQUENCY,PLATMAP,LABELS,PLATDATA) writes 
%   to FILENAME the platform data sampling start time ([s]) and sampling rate ([Hz]),
%   the correspondance map between platform logical channels and physical 
%   channels stored in PLATMAP and the platforms data stored in PLATDATA.
%   PLATMAP must be a [nPlats,1] array such that PLATMAP(logical channel) == physical channel. 
%   PLATDATA must be an array of size nPlats x nSamples x 6 (or 12 if you use DBL format )
%   with fields such that the PLATDATA(p,:,:) submatrixes are nSamples x 6 (or 12 if you use DBL format )
%   matrixes where in the first 2 columns there are the samples of the position of the force application point, 
%   in the columns 3 : 5 there are the samples of the force components 
%   and in the 6th column there are the samples of the torque.
%   See Tdf File format documentation for using the 'double' (or DBL) format.
%
%   If there are any label, set the input LABELS as an empty arry [].
%
%   res = TDFWRITEDATAPLAT (...,FORMAT) specifies the format for the platform data block.
%   Valid entries for FORMAT are: 'bytrack' (default) and 'byframe'.
%
%   See Tdf File format documentation for further details.
%
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADDATAPLAT
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 7 $ $Date: 28/07/06 16.28 $

res = -1;
tdfDataPlatBlockId = 9;

if (nargin == 6)
   strFormat   = 'bytrack';
else
   strFormat   = varargin{1};
end

switch strFormat
case 'bytrack'
   if ( size(platData,3) == 6 )
     if ( isempty(labels) )
       blockFormat = 1;     % TDF_DATAPLAT_FORMAT_BYTRACK_ISS
     else
       blockFormat = 3;     % TDF_DATAPLAT_FORMAT_BYTRACK_WL_ISS
     end
   else
     if ( isempty(labels) )
       blockFormat = 5;     % TDF_DATAPLAT_FORMAT_BYTRACK_DBL
     else
       blockFormat = 7;     % TDF_DATAPLAT_FORMAT_BYTRACK_WL_DBL
     end 
   end
case 'byframe'
   if ( size(platData,3) == 6 )
     if ( isempty(labels) )
       blockFormat = 2;     % TDF_DATAPLAT_FORMAT_BYFRAME_ISS
     else
       blockFormat = 4;     % TDF_DATAPLAT_FORMAT_BYFRAME_WL_ISS
     end
   else
     if ( isempty(labels) )
       blockFormat = 6;     % TDF_DATAPLAT_FORMAT_BYFRAME_DBL
     else
       blockFormat = 8;     % TDF_DATAPLAT_FORMAT_BYFRAME_WL_DBL
     end 
   end
otherwise
   disp ('Error: invalid block format')
   return
end

[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfDataPlatBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nPlats = length (platMap);
nSamples = size (platData,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nPlats,   'int32');
fwrite (fid,frequency,'int32');
fwrite (fid,startTime,'float32');
fwrite (fid,nSamples, 'int32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write platform map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,platMap,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write platforms data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Labels
if ( blockFormat == 3 ) | ...
   ( blockFormat == 4 ) | ...
   ( blockFormat == 7 ) | ...
   ( blockFormat == 8 )
 
  labelsToWrite = char (zeros (nSamples,256));
  labelLen = size (labels,2);
  for l = 1 : size (labels,1)
     labelsToWrite(l,1:labelLen) = labels(l,:);
  end
  
end

% Format ISS (single)
if (1 == blockFormat) | ... % byTrack 
   (2 == blockFormat) | ... % byFrame
   (3 == blockFormat) | ... % byTrack withLabels
   (4 == blockFormat)       % byFrame withLabels
 
   if (blockFormat == 1) | (blockFormat == 3)              
     % by track
     for p = 1 : nPlats
       if (blockFormat == 3) 
         fwrite (fid,labelsToWrite(p,:),'char');
       end
       invalidFrames = cat(2,0,find (~isfinite (platData(p,:,1)) | ~isfinite (platData(p,:,2)) | ~isfinite (platData(p,:,3)) |...
                                     ~isfinite (platData(p,:,4)) | ~isfinite (platData(p,:,5)) | ~isfinite (platData(p,:,6))),nSamples+1);
       segLens = diff (invalidFrames)-1;
       segments = cat (1,invalidFrames (find (segLens>0)),segLens (find (segLens>0)));
       nSegments = size (segments,2);
       fwrite (fid,nSegments,'int32');
       fwrite (fid,0,'uint32');
       fwrite (fid,segments,'int32');
       for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
           fwrite (fid,platData(p,f,:),'float32');
         end
       end
     end
   elseif (blockFormat == 2) | (blockFormat == 4)
     % by frame
     if (blockFormat == 4)
      for t = 1 : nPlats
        fwrite (fid,labelsToWrite(t,:),'char');
      end
     end
     for f = 1 : nSamples
       fwrite (fid,permute(platData(:,f,:),[2,1,3]),'float32');
     end
   end

end 

% Format DBL (double)
if (5 == blockFormat) | ... % byTrack 
   (6 == blockFormat) | ... % byFrame
   (7 == blockFormat) | ... % byTrack withLabels
   (8 == blockFormat)       % byFrame withLabels

   if (blockFormat == 5) | (blockFormat == 7)              
     % by track
     for p = 1 : nPlats
       if (blockFormat == 7) 
         fwrite (fid,labelsToWrite(p,:),'char');
       end
       invalidFrames = cat(2,0,find (~isfinite (platData(p,:,1))  | ~isfinite (platData(p,:,2))  | ~isfinite (platData(p,:,3)) |   ...
                                     ~isfinite (platData(p,:,4))  | ~isfinite (platData(p,:,5))  | ~isfinite (platData(p,:,6)) |   ...
                                     ~isfinite (platData(p,:,7))  | ~isfinite (platData(p,:,8))  | ~isfinite (platData(p,:,9)) |   ...
                                     ~isfinite (platData(p,:,10)) | ~isfinite (platData(p,:,11)) | ~isfinite (platData(p,:,12)) ), ...
                           nSamples+1);
       segLens = diff (invalidFrames)-1;
       segments = cat (1,invalidFrames (find (segLens>0)),segLens (find (segLens>0)));
       nSegments = size (segments,2);
       fwrite (fid,nSegments,'int32');
       fwrite (fid,0,'uint32');
       fwrite (fid,segments,'int32');
       for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
           fwrite (fid,platData(p,f,:),'float32');
         end
       end
     end
   elseif (blockFormat == 6) | (blockFormat == 8)
     % by frame
     if (blockFormat == 8)
       for t = 1 : nPlats
         fwrite (fid,labelsToWrite(t,:),'char');
       end
     end
     for f = 1 : nSamples
       fwrite (fid,permute(platData(:,f,:),[2,1,3]),'float32');
     end
   end
    
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfDataPlatBlockId,'uint32');
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


