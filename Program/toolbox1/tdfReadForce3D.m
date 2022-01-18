function [frequency,D,R,T,labels,tracks] = tdfReadForce3D (filename)
%TDFREADFORCE3D   Read force 3D data sequence from TDF-file.
%   [FREQUENCY,D,R,T,LABELS,TRACKS] = TDFREADFORCE3D (FILENAME) retrieves 
%   frequency ([Hz]), calibrated volume info, tracks and labels 
%   of the Force3D data sequence stored in FILENAME.
%   D is the dimension vector, R the rotation matrix, T the translation vector of the
%   calibrated volume
%   TRACKS is a matrix where each row represents a frame: TRACKS(FRM,:) is the frame FRM.
%   
%   LABELS is a matrix whith the text strings of the labels as rows.
%
%   See also TDFWRITEFORCE3D
%
%   Copyright (c) 2004 by BTS S.p.A.
%   $Revision: 3 $ $Date: 14/07/06 11.43 $

frequency=[]; D=[]; R=[]; T=[]; labels=[]; links=[]; tracks=[];

% Open the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[fid,tdfBlockEntries] = tdfFileOpen (filename);   if fid == -1
   return
end

% Search Force3D Block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tdfDataBlockId = 12;    % see TdfSpecs 
blockIdx = 0;

for e = 1 : length (tdfBlockEntries)
   if (tdfDataBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end

if blockIdx == 0
   disp ('Force 3D datablock not found in the file specified.')
   tdfFileClose (fid);
   return
end

if (-1 == fseek (fid,tdfBlockEntries(blockIdx).Offset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

% read header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nTracks   = fread (fid,1,'int32');
frequency = fread (fid,1,'int32');
startTime = fread (fid,1,'float32');
nFrames   = fread (fid,1,'int32');
D         = fread (fid,3,'float32');
R         = (fread (fid,[3,3],'float32'))';
T         = fread (fid,3,'float32');
fseek (fid,4,'cof'); %skip a DWORD (Flags field)

% read tracks information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labels = char (zeros (nTracks,256));
tracks = NaN * ones (nFrames,9*nTracks);

if (1 == tdfBlockEntries(blockIdx).Format)         % by track
   for trk=1:nTracks
      label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (trk,1:length (label)) = label;
      nSegments  = fread (fid,1,'int32');
      fseek (fid,4,'cof');
      segments   = fread (fid,[2,nSegments],'int32');
      for s = 1 : nSegments
         for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
            tracks(f,3*(trk-1)+1:3*(trk-1)+9) = (fread (fid,9,'float32'))';
         end
      end
   end
elseif (2 == tdfBlockEntries(blockIdx).Format)     % by frame
   for trk=1:nTracks
      label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (trk,1:length (label)) = label;
   end
   tracks = (fread (fid,[9*nTracks,nFrames],'float32'))';
end
labels = deblank (labels);

tdfFileClose (fid);                                % close the file
