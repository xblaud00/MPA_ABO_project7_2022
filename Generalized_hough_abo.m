%Part of this script are retrieved from Shellyhan. https://github.com/Shellyhan

clc;
close all;
clearvars;

%
%Load reference and target image
target = imread("q_test.png");
reference = imread("q.jpg");

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

%Create 2 R-tables, one for rotation
rtable = zeros(2*maxAngles, maxPoints, 2);
binCount = zeros(2*maxAngles,1);
rtable_sc = zeros(2*maxAngles, maxPoints, 2); 
rtable_rot = zeros(2*maxAngles, maxPoints, 2); 

for i=1:1:maxPoints

    k = reference_gradient(x(i),y(i)) + 180;
    binCount(k) = binCount(k) + 1;
  
    Dx = x(i) - refPointX;
    Dy = y(i) - refPointY;
    
    rtable(k, binCount(k), 1) = Dx;
    rtable(k, binCount(k), 2) = Dy;

    rtable_sc(k, binCount(k), 1) = round(1.5*Dx);
    rtable_sc(k, binCount(k), 2) = round(1.5*Dy);

    angle=-90*pi()/180; 
    rtable_rot(k, binCount(k),1)= round(cos(angle)*Dx - sin(angle)*Dy);
    rtable_rot(k, binCount(k),2)= round(sin(angle)*Dx + cos(angle)*Dy);

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

accumulator2 = zeros(w,z); %accumulator for scaling

for i=1:1:maxPoints_target 
    h = target_gradient(a(i), b(i)) + 180;
  
    for j = 1:1:binCount(h)

        tx = a(i) - rtable_sc(h, j, 1);
        ty = b(i) - rtable_sc(h, j, 2);

        if (tx>0) && (tx<size_target(1)) && (ty>0) && (ty<size_target(2))
            accumulator2(tx, ty) = accumulator2(tx, ty)+1;

        
        end
   
    end
end

accumulator3 = zeros(w,z); %accumulator for rotation

for i=1:1:maxPoints_target 
    h = target_gradient(a(i), b(i)) + 180;
  
    for j = 1:1:binCount(h)

        tx = a(i) - rtable_rot(h, j, 1);
        ty = b(i) - rtable_rot(h, j, 2);

        if (tx>0) && (tx<size_target(1)) && (ty>0) && (ty<size_target(2))
            accumulator3(tx, ty) = accumulator3(tx, ty)+1;

        
        end
   
    end
end

max_value1 = max(max(accumulator)); %find maximum in accumulator
[raw1,col1] = find(accumulator == max_value1); %get row and column of the maximum in accumulator

max_value2 = max(max(accumulator2)); %find maximum in accumulator2 for rotation
[raw2,col2] = find(accumulator2 == max_value2); %get row and column of the maximum in accumulator2

max_value3 = max(max(accumulator3)); %find maximum in accumulator2 for rotation
[raw3,col3] = find(accumulator3 == max_value3); %get row and column of the maximum in accumulator2


%display reference image and target image
subplot(1,2,1),imshow(reference);title("Reference Image");
subplot(1,2,2),imshow(orig_target);title("Target Image");hold on,plot(col1,raw1,'r.'),hold on,plot(col2,raw2,'r.'),hold on,plot(col3,raw3,'r.'); %red dots, that corespod with referrecne image



