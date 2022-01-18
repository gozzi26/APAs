function res = tdfWriteData3D (filename,frequency,D,R,T,labels,links,tracks,varargin)
%TDFWRITEDATA3D   Write 3D data sequence to a TDF-file.
%   res = TDFWRITEDATA3D (FILENAME,FREQUENCY,D,R,T,LABELS,LINKS,TRACKS) writes to
%   FILENAME the 3D data sequence stored in TRACKS, characterized by FREQUENCY
%   ([Hz]), the calibrated volume info stored in (D,R,T), the connectivity links
%   stored in LINKS and the track labels stored in LABELS.
%   All the arguments must have the same structure as the ones retrieved by TDFREADDATA3D.
%
%   res = TDFWRITEDATA3D (...,FORMAT) specifies the format for the 3D data block.
%   Valid entries for FORMAT are 'bytrack' (default), 'byframe'.
%   See Tdf File format documentation for further details.
%
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADDATA3D.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 7 $ $Date: 14/07/06 11.43 $

tdfData3DBlockId = 5;
res = -1;

if (nargin == 8)
   strFormat   = 'bytrack';
else
   strFormat   = varargin{1};
end

switch strFormat
case 'bytrack'
   blockFormat = 1;
case 'byframe'
   blockFormat = 3;
otherwise
   disp ('Error: invalid block format')
   return
end


[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfData3DBlockId);
if fid == -1
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nFrames     = size (tracks,1);
nTracks     = size (tracks,2) / 3;
dwFlags     = 1;
startTime   = 0.0;
if isempty (links)
   blockFormat = blockFormat + 1;
   nLinks = 0;
else
   nLinks = size (links,2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nFrames,'int32');
fwrite (fid,frequency,'int32');
fwrite (fid,startTime,'float32');
fwrite (fid,nTracks,'int32');
fwrite (fid,D,'float32');
fwrite (fid,R','float32');
fwrite (fid,T,'float32');
fwrite (fid,dwFlags,'uint32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write links information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1 == blockFormat) | (3 == blockFormat)
   fwrite (fid,nLinks,'int32');
   fwrite (fid,0,'uint32');
   fwrite (fid,links,'int32');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write tracks information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labelsToWrite = char (zeros (nTracks,256));
labelLen = size (labels,2);
for l = 1 : size (labels,1)
   labelsToWrite(l,1:labelLen) = labels(l,:);
end

if (1 == blockFormat) | (2 == blockFormat)         % by track
   for t = 1 : nTracks
      fwrite (fid,labelsToWrite(t,:),'char');
      invalidFrames = cat (2,0,find (~isfinite (tracks(:,(t-1)*3+1)') | ~isfinite (tracks(:,(t-1)*3+2)') | ~isfinite (tracks(:,(t-1)*3+3)')),nFrames+1);
      segLens = diff (invalidFrames)-1;
      segments = cat (1,invalidFrames (find (segLens>0)),segLens (find (segLens>0)));
      nSegments = size (segments,2);
      fwrite (fid,nSegments,'int32');
      fwrite (fid,0,'uint32');
      fwrite (fid,segments,'int32');
      for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
            fwrite (fid,(tracks(f,3*(t-1)+1:3*(t-1)+3))','float32');
         end
      end
   end
elseif (3 == blockFormat) | (4 == blockFormat)     % by frame
   for t = 1 : nTracks
      fwrite (fid,labelsToWrite(t,:),'char');
   end
   fwrite (fid,tracks','float32');
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfData3DBlockId,'uint32');
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
