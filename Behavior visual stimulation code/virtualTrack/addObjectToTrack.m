function trk_m = addObjectToTrack(trk_m,obj)
%
%
%
%
%

% SRO - 3/31/12


rect = obj.rect;

switch obj.type
    
    case 1  % square
        tmp = ones(obj.size);
        
        if isfield(obj,'angle')
            tmp = single(tmp);
            if ~obj.angle == 0
                tmp = imrotate(tmp,obj.angle);
                size_tmp = size(tmp);
                add_pix = (size_tmp(1) - obj.size(1))/2;
                rect = round(obj.rect + [-1 -1 1 1]*add_pix);    % ** to do: store updated obj.rect
            end
            tmp=mkGrating(obj.size,obj.background_pix_val,obj.angle,obj.contrast);
            add_pix = (size(tmp,1) - obj.size(1))/2;
            rect = round(obj.rect + [-1 -1 1 1]*add_pix);    % ** to do: store updated obj.rect
            tmp = double(tmp);
            
         end
        
        
    case 2  % circle
        tmp = Circle(obj.size/2);
        tmp = double(tmp);
        
    case 3  % triangle
        tmp = ones(obj.size);
        tmp = tril(tmp);
        
    case 4
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\massimo.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp(1:size(im,1),1:size(im,2)) = im*255;
    case 5
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\shawn.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 6
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\baohua.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 7 
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\carsten.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 8 
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\dante.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 9
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\jamie.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 10
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\kim.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 11
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\matt.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 12
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\melanie.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 13
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\mingshan.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
    case 14
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\sarah.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
             
    case 15
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\tony.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
             
    case 16
        tmp = zeros(obj.size);
        im = imread('C:\SRO DATA\Code\virtualTrack\images\willy.jpg');
        im = im2double(im);
        im = rgb2gray(im);
        tmp = im*255;
        
end

% Kluge to show images
if obj.type < 4
    tmp(tmp==0) = obj.background_pix_val;
    tmp(tmp==1) = obj.pix_val;
    trk_m(rect(2):rect(4)-1,rect(1):rect(3)-1) = tmp;
    trk_m(1050:1080-1,rect(1):rect(3)+1) = 250; % AR: this line adds bar at the bottom of screen for photodiode

else
    trk_m(rect(2):rect(4)-1,rect(1):rect(3)-1) = tmp;
end

