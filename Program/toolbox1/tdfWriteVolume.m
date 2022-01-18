function res = tdfWriteVolume (filename,frequency,labels,tracks,varargin)
%TDFWRITEVOLUME   Write 3D data sequence to a TDF-file.
%   res = TDFWRITEVOLUME (FILENAME,FREQUENCY,LABELS,TRACKS) writes to
%   FILENAME the volume data sequence stored in TRACKS, characterized by FREQUENCY
%   ([Hz]) and the track labels stored in LABELS.
%   All the arguments must have the same structure as the ones retrieved by TDFREADVOLUME.
%
%   res = TDFWRITEVOLUME (...,FORMAT) specifies the format for the data block.
%   Valid entries for FORMAT are 'bytrack' (default), 'byframe'.
%   See Tdf File format documentation for further details.
%
%   If the file specified does not exist, a new one is created.
%   RES is 0 in case of success, -1 otherwise.
%
%   See also TDFREADVOLUME.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 1 $ $Date: 14/07/06 11.44 $

tdfVolumeBlockId = 13;
res = -1;

if (nargin == 4)
   strFormat   = 'bytrack';
else
   strFormat   = varargin{1};
end

switch strFormat
case 'bytrack'
   blockFormat = 1;
case 'byframe'
   blockFormat = 2;
otherwise
   disp ('Error: invalid block format')
   return
end


[fid,entryOffset,blockOffset] = tdfFileTest (filename,tdfVolumeBlockId);
if fid == -1
   disp ('Error: file check failed.')
   return
end

if (-1 == fseek (fid,blockOffset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

nFrames     = size (tracks,1);
nTracks     = size (tracks,2) / 5;
dwFlags     = 1;
startTime   = 0.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fwrite (fid,nTracks,'int32');
fwrite (fid,frequency,'int32');
fwrite (fid,startTime,'float32');
fwrite (fid,nFrames,'int32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write tracks information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labelsToWrite = char (zeros (nTracks,256));
labelLen = size (labels,2);
for l = 1 : size (labels,1)
   labelsToWrite(l,1:labelLen) = labels(l,:);
end

if (1 == blockFormat)
  % by track
  % --------
  for t = 1 : nTracks
      fwrite (fid,labelsToWrite(t,:),'char');
      invalidFrames = cat (2,0,find (~isfinite (tracks(:,(t-1)*5+1)') | ~isfinite (tracks(:,(t-1)*5+2)') | ~isfinite (tracks(:,(t-1)*5+3)') | ~isfinite (tracks(:,(t-1)*5+4)') | ~isfinite (tracks(:,(t-1)*5+5)')),nFrames+1);
      segLens = diff (invalidFrames)-1;
      segments = cat (1,invalidFrames (find (segLens>0)),segLens (find (segLens>0)));
      nSegments = size (segments,2);
      fwrite (fid,nSegments,'int32');
      fwrite (fid,0,'uint32');
      fwrite (fid,segments,'int32');
      for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
            fwrite (fid,(tracks(f,5*(t-1)+1:5*(t-1)+4))','float32');
            fwrite (fid,(tracks(f,5*(t-1)+5))','int32');
         end
      end
  end
elseif (2 == blockFormat)     
  % by frame
  % --------
  for t = 1 : nTracks
    fwrite (fid,labelsToWrite(t,:),'char');
  end
  for f = 1:nFrames
    for t = 1 : nTracks
      fwrite (fid,tracks( f, 5*(trk-1)+1 : 5*(trk-1)+4 ), 'float32' );
      fwrite (fid,tracks( f, 5*(trk-1)+5 ), 'int32' );
    end
  end 
end

newBlockOffset = ftell (fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write entry information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fseek (fid,entryOffset,'bof');
fwrite (fid,tdfVolumeBlockId,'uint32');
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
