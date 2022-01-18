
function [X] = GetImagesFromFile( FileName, cams, frames );
% GetImagesFromFile    Get a collection of indexed images from a file.
%
%   [X] = GetImagesFromFile( FileName, cams, frames );
%
%   X is an images array (see the notes below). 
%
%   See also : GetImagesInfoFromFIle, ExtractImageFromStructure
%
%   Copyright (c) 2004 by BTS S.p.A.
%   $Revision: 4 $ $Date: 14/07/06 11.42 $
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTES:
%       
%       The structure of file is depicted below. It present a common and image data 
%       sections.
%
%       Common data section
%       It consists of four element, that are 32-bit sized.
%
%                                  ------------
%                                 |    NCams   |          |
%                                  ------------           | 
%                                  ------------           |
%                                 |   NFrames  |          |
%                                  ------------            >   4 * 32-bit size
%                                  ------------           |
%                                 | imageSizeX |          |
%                                  ------------           |
%                                  ------------           |
%                                 | imageSizeY |          |
%                                  ------------              
%
%
%       Image data section 
%       Each image is stored row-wise. The structure containing the data  has 
%       (imageSizeX * imageSizeY * NCams * NFrames) X 1  dimensions
%       Each pixel is 8-bit depth. 
%
%
%                                           --------------
%                                          |              |
%                <-  imageSizeX ->         |              |
%            ^    ---------------          |       ---------------
%            |   |               |         |      |               |      
%            |   |               |         |      |               |
%            |   |  image        |         |      |               |     |
%  imageSizeY    |    camera:1   |         |      |               |     | 
%            |   |    frame: 1   |         |      |               |     |
%            |   |               |         |      |               |     |
%            |   |               |         |      |               |     |
%            v    ---------------          |       ---------------      |
%                |               |         |      |               |     |
%                |               |         |      |               |     |
%                |  image        |         |      |               |     |
%                |    camera:2   |         |      |               |     |
%                |    frame: 1   |                |               |     |
%                |               |                |               |     |
%                |               |         .      |               |      >  NCams
%                 ---------------          .       ---------------      |
%                |               |         .      |               |     |
%                |       .       |         .      |       .       |     |
%                |       .       |         .      |       .       |     |
%                |       .       |         .      |       .       |     |
%                |       .       |         .      |       .       |     |
%                |       .       |                |       .       |     |
%                |               |                |               |     |
%                 ---------------          |       ---------------      |
%                |               |         |      |               |     |
%                |               |         |      |  image        |     |
%                |               |         |      |    camera:    |     |
%                |               |         |      |      nCameras |     
%                |               |         |      |    frame:     |
%                |               |         |      |      nFrames  |
%                |               |         |      |               |
%                 ---------------          |       ---------------       
%                        |                 |
%                        |                 | 
%                        |                 |
%                         -----------------
%
%                          --------------- ---------------
%                                         V
%                                      NFrames
%
%
%
%
%       X is a multiframe (if necessary) images structure. Each image is a general indexed 
%       image, that can be manipulated by Image Processing Toolbox MatLab.
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
%                                     NCams * NFrames
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Check number of input arguments
if nargin < 1, error('Not enough input arguments.'); end
if nargin ~= 3, error('Wrong input arguments number.'); end

% Obtain structure info from file
[NCams, NFrames, imageSizeX, imageSizeY] = GetImagesInfoFromFile( FileName );

HeadSize  = 16;						  % [bytes]
ImageSize = imageSizeX*imageSizeY; % [bytes]
nOutCams  = max(size(cams));
nOutFrms  = max(size(frames));

fid = fopen( FileName , 'r' );     % open for read only

% Check values
if ( fid < 0 ) 									  	 error('File not found.');end
if ( min(cams) <= 0 | max(cams) > NCams )     error('Bad cam value.');end
if ( min(frames) < 0 | max(frames) > NFrames) error('Bad frame value.');end
if ( nOutCams <= 0 | nOutFrms <= 0 )          error('Bad input value.');end

% preallocate output space  
X = zeros( imageSizeY, imageSizeX * nOutCams * nOutFrms );

% skip header
if ( 0 ~= fseek(fid,HeadSize,'bof') )
  msg = ferror(fid);
  error( strcat('Reading error: ',msg) );
end

Xcount = 0;
framek_old = 0;

% extracting loop
for k = 1:nOutFrms
   framek = frames(k);
   % jump to current frame
	if ( 0 ~= fseek(fid, (framek -framek_old -1)*NCams*ImageSize,'cof') )
  	  msg = ferror(fid);
     error( strcat('Reading error: ',msg) );
   end
   for i = 1:nOutCams 
     cami = cams(i);
     disp(strcat('frame ',num2str(framek),', cam ',num2str(cami))) 
     % jump to image of cami in current frame
     fseek(fid,ImageSize*(cami-1),'cof');
     % read image 
     [D, counter] = fread(fid,ImageSize,'uchar');   
     % store in output matrix X
     Xcount = Xcount +1;
     X(:,((Xcount-1)*imageSizeX+1):(Xcount*imageSizeX)) = reshape( D, imageSizeX,  imageSizeY )';
     % points again to start of current frame
     fseek(fid,-(ImageSize*(cami-1)+counter),'cof');
  end
  framek_old = framek;
end

fclose(fid);

% Delete scratch matrix
clear D;



