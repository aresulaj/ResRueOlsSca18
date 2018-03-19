function [maskMat,maskSizePix,maskRefRect] = makeAperture(p,d,visSizeStim,white,black)
%
%   INPUT:
%       white: luminance for white in cd/m^2
%       black: luminance for black in cd/m^2
%

% Created: Shawn R Olsen - 4/17/13

x_offset = p.xLocMask;
y_offset = -p.yLocMask;
maskSizeDeg = p.size;

% Set gray value
gray = (white + black)/2;

% Convert mask size in degrees to pixels
maskSizePix = ceil(maskSizeDeg/d.degPerPix);
maskSizePix = 500; 

% Set width of entire matrix
width = visSizeStim;
height = width;    

% Gray background
maskMat = ones(height,width,2)*gray;

% Find center of mask
centerLeft = round(width/2 - maskSizePix/2);
centerRight = centerLeft + maskSizePix;

% Set alpha (transparency channel)
% maskMat(:,:,2) = white;
% maskMat(centerLeft:centerRight,centerLeft:centerRight,2) = black;

% Make aperture circle
tmp_Circ = Circle(ceil((-centerLeft + centerRight)/2));
tmp_Circ = double(tmp_Circ);
tmp_Circ(tmp_Circ==0) = white;
tmp_Circ(tmp_Circ==1) = black;

tmp_loc = [0 0 size(tmp_Circ,2) size(tmp_Circ,1)];
tmp_loc = CenterRect(tmp_loc,[0 0 visSizeStim visSizeStim]);

tmp_Circ = tmp_Circ(1:(centerRight-centerLeft),1:(centerRight-centerLeft));

maskMat(:,:,2) = white;
tmp_r = centerLeft + size(tmp_Circ,1)-1;
maskMat(centerLeft+y_offset:tmp_r+y_offset,centerLeft+x_offset:tmp_r+x_offset,2) = tmp_Circ;

tmp_size = size(maskMat(:,:,2),1);
maskRefRect = [0 0 tmp_size tmp_size];  % [left top right bottom]

% Convert luminance to pixel value
maskMat = lum2pixVal(maskMat);









