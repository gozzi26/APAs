function [I] = ExtractImageFromStructure( X, camera, frame, imageSizeX, imageSizeY, NCams, NFrames );

% ExtractImageFromStructure     Get a specified image from multiple image structure.
%   [I] = ExtractImageFromStructure( X, camera, frame, imageSizeX, imageSizeY, NCams, NFrames ) 
%   retrieves a selected image I. X is the multiple image structure (see the notes below). 
%   NCams and NFrames are the number of cameras and the number of frames respectively, 
%   imageSizeX is the X size for each image, imageSizeY is the Y size for each image. 
%   camera specifies the index of camera related to the image selected.
%   frame specifies the index of frame related to the image selected.
%   I is the indexed image. 
%
%   See also : GetImagesFromFile, GetImagesInfoFromFIle
%
%   Copyright (c) 2004 by BTS S.p.A.
%   $Revision: 3 $ $Date: 14/07/06 11.42 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTES 
%
%       X has the following structure:
%
%         ----------- ----------- ----------- ----------- ----------- -----------
%        |           |           |                       |           | image     |
%        | image     | image     |                       |           |  camera:  |
%        | camera: 1 | camera: 2 |      . . . . .        |           | nCameras  |
%        | frame: 1  | frame : 1 |                       |           |  frame:   |
%        |           |           |                       |           | nFrames   |
%        |           |           |                       |           |           |
%         ----------- ----------- ----------- ----------- ----------- -----------
%
%             ------------------------------ ------------------------------
%                                           V
%                                      NCams * NFrames
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Check number of input arguments
if nargin < 7, error('Not enough input arguments.'); end

% Check input arguments values 
if camera <= 0 | camera > NCams, error('Invalid camera index.'); end 
if frame <= 0 | frame > NFrames, error('Invalid frame index.'); end

% Array is 0 based
camera = camera -1;
frame = frame -1;

% preallocate space
I = zeros( imageSizeY, imageSizeX );

% Extract selected image
I = X(: , ( camera+frame*NCams )*imageSizeX +1 : ( camera+frame*NCams + 1 )*imageSizeX );


