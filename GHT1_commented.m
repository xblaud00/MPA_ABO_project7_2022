close all
clear all
clc
%%
% Read images:
target = imread('target.png');
reference = imread('reference.png');
% figure 
% imshow(target)
% figure
% imshow(reference)

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

%get edges of refrernce and target image - Canny method
target = edge(target,'Canny');
reference = edge(reference,'Canny');
%toc

% Reference Point: (Middle point) - find middle point in reference image
refX = round(size(reference,1)/2);
refY = round(size(reference,2)/2);

% Get Reference edge point - all pixels that are 1 and save their positions
[x,y] = find(reference> 0);

maxAngels = 180;
maxPoints = size(x,1); %calculate number of points

% Gradient of reference image:
dy = imfilter(double(reference),[1; -1],'same');%multidimensional filtering, [1; -1] assign this values
dx = imfilter(double(reference),[1 -1],'same');%same = same size as input
reference_grad = atan2(dy,dx)*180/pi(); %creates gradient image, finds inverse tangent of point dy,dx + converts from radiant to degrees

% Gradient je vektor, ktery ma smer nejrychlejsÄ± zmeny. Mame-li
%liniovou hranu (jejÄ±z smer je dan sklonem teto line), je v kazdem jejÄ±m bode gradient
%kolmy na linii a tÄ±m i na smer hrany

% Rtable: create r table
rtable = zeros(maxAngels, maxPoints, 2);%rtable from maxAngles, number of point in reference image and 2 dimensions
binCount = zeros(maxAngels); %matrix 180x180 of zeros 

for i=1:1:maxPoints %iteration of one step to number of maxPoints
bin = reference_grad(x(i), y(i)) + maxAngels; %assign to bin
binCount(bin) = binCount(bin) + 1;

Dx = x(i) - refX; %substract refx (middle) coordiante from refrence image from every egde point in referencce image and save it to Dx
Dy = y(i) - refY; %same but for refY and Dy

rtable(bin, binCount(bin), 1) = Dx;
rtable(bin, binCount(bin), 2) = Dy;
end
%% 
%%--------------------------------------------------------------------------
%Accumulator:

% Get the target edge points
[x,y] = find(target > 0); %get every 1 in target image and save its values to x and y
maxPoints_target = size(x,1); %get number of 1 in target image

% Gradient of target:
dy = imfilter(double(target),[1; -1],'same'); %same filtering as in reference image
dx = imfilter(double(target),[1 -1],'same');
target_grad = atan2(dy,dx)*180/pi(); %create gradient image asi in ref image

% Accumulator(Hough space):
size_target = size(target); %get the size of target image
accumulator = zeros(size_target); %create matrix called accumulator full of zeros and size of target image

% Total match:
for i=1:1:maxPoints_target %iterate with step one throught number of 1 point in target img
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
max_value1 = max(max(accumulator)); %find maximum in accumulator
[raw1,col1] = find(accumulator == max_value1); %get row and column of the maximum in accumulator

% Second local maxima - pro nalezení objektů, které nejsou 100% viditelné -
% druhá největší veličina
max_value2 = max(max(accumulator(accumulator < (max_value1)))); %get second highest value
[raw2,col2] = find(accumulator == max_value2); %save it to row and col

% Display:


figure
imshow(accumulator, []);
pause

figure
imshow(target);
pause

figure
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
hold on;
Circle(col2,raw2, Dy, 10);
%Circle(col1,raw1, Dy, 10);
hold on;

function Circle(centery, centerx, reference, r)
radius = reference + r;
angle = 0:0.01:2*pi; 
d_x = radius*cos(angle);
d_y = radius*sin(angle);
plot(centery+d_y, centerx+d_x, 'r');
end