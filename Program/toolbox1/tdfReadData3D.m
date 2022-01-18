function [frequency,D,R,T,labels,links,tracks] = tdfReadData3D (filename)
%TDFREADDATA3D   Read 3D data sequence from TDF-file.
%   [FREQUENCY,D,R,T,LABELS,LINKS,TRACKS] = TDFREADDATA3D (FILENAME) retrieves 
%   frequency ([Hz]), calibrated volume info, tracks, links and labels 
%   of the 3D data sequence stored in FILENAME.
%   D is the dimension vector, R the rotation matrix, T the translation vector of the
%   calibrated volume
%   LINKS is a [2,nLinks] adjacency list of links: if exists linkIdx such that 
%   links(:,linkIdx) == [track1;track2] then a link exists connecting track1 with track2.
%   TRACKS is a matrix where each row represents a frame: TRACKS(FRM,:) is the frame FRM.
%   3D coordinates of each frame are stored following the order X1 Y1 Z1 X2 Y2 Z2 ...
%   LABELS is a matrix whith the text strings of the labels as rows.
%
%   See also TDFWRITEDATA3D, TDFPLOTDATA3D.
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 6 $ $Date: 14/07/06 11.42 $

frequency=[]; D=[]; R=[]; T=[]; labels=[]; links=[]; tracks=[];

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfData3DBlockId = 5;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfData3DBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Data 3D not found in the file specified.')
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

nFrames   = fread (fid,1,'int32');
frequency = fread (fid,1,'int32');
startTime = fread (fid,1,'float32');
nTracks   = fread (fid,1,'int32');
D         = fread (fid,3,'float32');
R         = (fread (fid,[3,3],'float32'))';
T         = fread (fid,3,'float32');
fseek (fid,4,'cof'); %skip Flags field

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read links information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (1 == tdfBlockEntries(blockIdx).Format) | (3 == tdfBlockEntries(blockIdx).Format)        % with links
   nLinks = fread (fid,1,'int32');
   fseek (fid,4,'cof');
   links  = fread (fid,[2,nLinks],'int32');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read tracks information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labels = char (zeros (nTracks,256));
tracks = NaN * ones (nFrames,3*nTracks);

if (1 == tdfBlockEntries(blockIdx).Format) | (2 == tdfBlockEntries(blockIdx).Format)         % by track
   for trk=1:nTracks
      label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (trk,1:length (label)) = label;
      nSegments  = fread (fid,1,'int32');
      fseek (fid,4,'cof');
      segments   = fread (fid,[2,nSegments],'int32');
      for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
            tracks(f,3*(trk-1)+1:3*(trk-1)+3) = (fread (fid,3,'float32'))';
         end
      end
   end
elseif (3 == tdfBlockEntries(blockIdx).Format) | (4 == tdfBlockEntries(blockIdx).Format)     % by frame
   for trk=1:nTracks
      label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (trk,1:length (label)) = label;
   end
   tracks = (fread (fid,[3*nTracks,nFrames],'float32'))';
end
labels = deblank (labels);

tdfFileClose (fid);                               % close the file
