
function [NCams, NFrames, imageSizeX, imageSizeY] = GetImagesInfoFromFile( FileName );

% GetImagesInfoFromFIle    Get image data from a file.
%   [ NCams, NFrames, imageSizeX, imageSizeY] = GetImagesInfoFromFIle( FileName ) retrieves
%   the number of cameras (NCams), number of frames (NFrames), the X size for each image 
%   (imageSizeX), the Y size for each image (imageSizeY) stored in FileName. 
%   
%   Internal use
%
%   See also : GetImagesFromFile, ExtractImageFromStructure
%
%   Copyright (c) 2004 by BTS S.p.A.
%   $Revision: 3 $ $Date: 14/07/06 11.42 $


% Check number of input arguments
if nargin < 1, error('Not enough input arguments.'); end

% Object reference to file
fid = fopen( FileName , 'r' );     % open for read only

% Extract common data
NCams = fread( fid, 1, 'int32' );      % 32-bit dimension objects
NFrames = fread( fid, 1, 'int32' );    
imageSizeX = fread( fid, 1, 'int32' ); 
imageSizeY = fread( fid, 1, 'int32' ); 

% Extract image data from file
% [F, count] = fread( fid ); 

fclose(fid);

clear count;