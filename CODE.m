close all
clear all
clc
%%
% Read images:
target = imread('target.png');
reference = imread('reference2.png');
figure 
imshow(target)
figure
imshow(reference)

%% 
% Convert Images to Grayscale:
% First save the original because at the end we will put marks on found
% templates from original image
original_target = target;
target = rgb2gray(target);
reference = rgb2gray(reference);

% Get edges with default threshold:
% I have tried different combinations of Sobel, Prewitt, Canny and Roberts.
% Almost all combinations are working(With different maximum values). The
% Canny seems the most slowest one but it seems like Canny is better in
% means of False Alarm situations. Probably thats why everybody is using
% Canny with Hough transfrom. I have also tried without applying any edge
% method and the code works fine. As far as I read, Hough transform doesn't
% have to work on binary images so, we can actually omit this step. But
% just for the sake of this assignment I will use the edge method which
% will help me get the best hough space in means of being observable by
% human eyes. With the "Sobel/Canny or Prewitt/Canny" 3 template image
% clearly visible but there are also very close maximas everywhere around
% the accumulator, but when I try Canny Canny there is a huge gap between
% true local maximas and others, therefore it has better visibility

%tic
target = edge(target,'Canny');
reference = edge(reference,'Canny');
%toc

% Reference Point: (Middle point)
refX = round(size(reference,1)/2);
refY = round(size(reference,2)/2);

% Get Reference edge point:
[x,y] = find(reference> 0);

maxAngels = 180;
maxPoints = size(x,1);

% Gradient of reference image:
dy = imfilter(double(reference),[1; -1],'same');
dx = imfilter(double(reference),[1 -1],'same');
reference_grad = atan2(dy,dx)*180/pi();

% Gradient je vektor, ktery ma smer nejrychlejsı zmeny. Mame-li
%liniovou hranu (jejız smer je dan sklonem teto line), je v kazdem jejım bode gradient
%kolmy na linii a tım i na smer hrany

% Rtable:
rtable = zeros(maxAngels, maxPoints, 2);
binCount = zeros(maxAngels);

for i=1:1:maxPoints
bin = reference_grad(x(i), y(i)) + maxAngels;
binCount(bin) = binCount(bin) + 1;

Dx = x(i) - refX;
Dy = y(i) - refY;

rtable(bin, binCount(bin), 1) = Dx;
rtable(bin, binCount(bin), 2) = Dy;
end
%% 
%%--------------------------------------------------------------------------
%Accumulator:

% Get the target edge points
[x,y] = find(target > 0);
maxPoints_target = size(x,1);

% Gradient of target:
dy = imfilter(double(target),[1; -1],'same');
dx = imfilter(double(target),[1 -1],'same');
target_grad = atan2(dy,dx)*180/pi();

% Accumulator(Hough space):
size_target = size(target);
accumulator = zeros(size_target);

% Total match:
for i=1:1:maxPoints_target
% The gradient angle:
bin = target_grad(x(i), y(i)) + maxAngels;

for j = 1:1:binCount(bin)
tx = x(i) - rtable(bin, j, 1);
ty = y(i) - rtable(bin, j, 2);
if (tx>0) && (tx<size_target(1)) && (ty>0) && (ty<size_target(2))
accumulator(tx, ty) = accumulator(tx, ty)+1;
end
end
end
%--------------------------------------------------------------------------
%%
% Find local maxima:
max_value1 = max(max(accumulator));
[raw1,col1] = find(accumulator == max_value1);

% Second local maxima
max_value2 = max(max(accumulator(accumulator < (max_value1))));
[raw2,col2] = find(accumulator == max_value2);

% Display:
% P.S: When displaying all the graphs together on subplot, sometimes
% maximum points in accumulator image doesn't look as shiny as they
% actually are. If we display them seperately, we can clearly see them.

imshow(accumulator, []);
pause

imshow(target);
pause

imshow(original_target);
hold on;
plot(col1,raw1,'r.');
plot(col2,raw2,'r.');
pause

subplot(2,2,1),imshow(target),title('Target Image with Edges');
%%
% ----------------------------------
% This part is just for Graph Title:
str = "Accumulator(x,y): ";
for i=1:size(raw1)
str1 = sprintf('(%d, %d) ',raw1(i),col1(i));
str = strcat(str,str1);
end
for i=1:size(raw2)
str2 = sprintf('(%d, %d) ',raw2(i),col2(i));
str = strcat(str,str2);
end
% ----------------------------------


subplot(2,2,[3,4]),imshow(original_target),title('Target Image with Found Templates ( Red Dots )');
hold on;
plot(col1,raw1,'r.'); % Put red dot
plot(col2,raw2,'r.');
