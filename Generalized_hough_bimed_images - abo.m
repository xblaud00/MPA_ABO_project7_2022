%Part of this script are retrieved from Shellyhan. https://github.com/Shellyhan
clc;
close all;
clearvars;

%
%Load reference and target image
target = imread("LU.jpg");
reference = imread("SE.jpg");
orig_reference = reference;
orig_target = target; %save original target image to another variable for later

% Show loaded images
% figure
% imshow(target)
% title("Target image")
% 
% figure
% imshow(reference)
% title("Reference image")

%%
% Convert images to grayscale

target = rgb2gray(target);
reference = rgb2gray(reference);

% edge detection via canny detector
target = edge(target, "canny");
reference = edge(reference, "canny");

% find middle point in reference image
refPointX = round(size(reference,1)/2);
refPointY = round(size(reference,2)/2);

%save all values that are 1 in reference image to "x" and "y"

[x,y]=find(reference>0);

maxPoints = size(x,1); %how many 1 point is in reference image
maxAngles = 180;

% Convert reference image indo gradient image
dy = imfilter(double(reference),[1; -1],'same');
dx = imfilter(double(reference),[1 -1],'same');
reference_gradient = atan2(dy,dx)*180/pi(); %create gradient image and convert radians to degrees

%Create 3 R-tables, for rotation, scaling and basic images
rtable = zeros(2*maxAngles, maxPoints, 2);
binCount = zeros(2*maxAngles,1);


for i=1:1:maxPoints

    k = reference_gradient(x(i),y(i)) + 180;
    binCount(k) = binCount(k) + 1;
  
    Dx = x(i) - refPointX;
    Dy = y(i) - refPointY;
    
    rtable(k, binCount(k), 1) = Dx;
    rtable(k, binCount(k), 2) = Dy;

    
end

%%
% Accumulator

% save all 1 in target image to "a" and "b"
[a,b] = find(target > 0);
maxPoints_target = size(a,1); %get number of points in target image

% convert into gradient image
dy_targ = imfilter(double(target),[1; -1],'same'); 
dx_targ = imfilter(double(target),[1 -1],'same');
target_gradient = atan2(dy_targ,dx_targ)*180/pi();

% Create Hough space
[w,z] = size(target);
size_target = size(target);
accumulator = zeros(w,z);


for i=1:1:maxPoints_target 
    h = target_gradient(a(i), b(i)) + 180;
    
    for j = 1:1:binCount(h)

    tx = a(i) - rtable(h, j, 1);
    ty = b(i) - rtable(h, j, 2);

        if (tx>0) && (tx<size_target(1)) && (ty>0) && (ty<size_target(2))
            accumulator(tx, ty) = accumulator(tx, ty)+1;

        end
    end
end



max_value1 = max(max(accumulator)); %find maximum in accumulator
[raw1,col1] = find(accumulator == max_value1); %get row and column of the maximum in accumulator

%display reference image and target image
subplot(1,2,1),imshow(orig_reference);title("Reference Image");
subplot(1,2,2),imshow(orig_target);title("Target Image");hold on,plot(col1,raw1,'r.'); %red dots, that corespod with referrecne image





