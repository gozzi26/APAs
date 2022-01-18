function [startTime,frequency,labels,VolumeData] = tdfReadVolume (filename)
%TDFREADVOLUMEDATA Read Volume Data from TDF-file.
%   [STARTTIME,FREQUENCY,LABELS,VOLUMEDATA] = TDFREADVOLUME (FILENAME) retrieves
%   the volume sampling start time ([s]) and sampling rate ([Hz]), 
%   and the VOLUME data stored in FILENAME.
%   LABELS is a matrix with the text strings of the VOLUME tracks as rows.
%   VOLUMEDATA is a [nTracks,nSamples] array such that VOLUMEDATA(s,:) stores 
%   the samples of the track s. 
%
%   See also TDFWRITEVOLUME
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 1 $ $Date: 14/07/06 11.44 $

VolumeData=[];
frequency=0;

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfDataVolumeBlockId = 13; % 
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfDataVolumeBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Volume Data not found in the file specified.')
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

nTracks   = fread (fid,1,'int32');
frequency = fread (fid,1,'int32');
startTime = fread (fid,1,'float32');
nSamples  = fread (fid,1,'int32');   % nFrames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read Volume data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labels   = char (zeros (nTracks,256));
VolumeData  = NaN * ones(nSamples,nTracks*5);

if (1 == tdfBlockEntries(blockIdx).Format)         

   % BY TRACK (TDF_VOLUME_FORMAT_BYTRACK_OEP4)
   % -----------------------------------------
  
   for trackID = 1 : nTracks
      label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (trackID,1:length (label)) = label;
      nSegments  = fread (fid,1,'int32');
      fseek (fid,4,'cof');                          % skip a DWORD
      segments = fread (fid,[2,nSegments],'int32'); % = [ (startframe1, nframes1); ... ; (startframeN, nframesN) ]
      for s = 1 : nSegments
        for f = segments(1,s)+1 : (segments(1,s)+segments(2,s))
            VolumeData(f, 5*(track-1)+1:5*(track-1)+4) = (fread (fid,4,'float32'))';
            VolumeData(f, 5*(track-1)+5) = fread (fid,1,'int32');
        end
      end
   end
   
elseif (2 == tdfBlockEntries(blockIdx).Format)     
  
   % BY FRAME (TDF_VOLUME_FORMAT_BYFRAME_OEP4)
   % -----------------------------------------
   
   for trk = 1 : nTracks
      label = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (trk,1:length (label)) = label;
   end
   
   for frm = 1:nSamples
     for trk = 1:nTracks
       VolumeData(frm, 5*(trk-1)+1:5*(trk-1)+4 ) = (fread (fid,4,'float32'))';
       VolumeData(frm, 5*(trk-1)+5 ) = fread (fid,1,'int32');
     end
   end
end

tdfFileClose (fid);                               % close the file


