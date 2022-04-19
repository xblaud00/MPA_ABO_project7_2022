%Part of this script are retrieved from...
clc;
close all;
clearvars;

%%--
%Nahr�n� referen�n�ho a target obrazu
target = imread("target_test.png");
reference = imread("reference_test.png");

orig_target = target; %ulo�en� p�vodn�ho obrazu do nov� prom�nn�, proto�e bude vyu�it na konci 

% Zobrazen� nahran�ch obraz�
% figure
% imshow(target)
% title("Target image")
% 
% figure
% imshow(reference)
% title("Reference image")

%%
% P�eveden� obraz� na grayscale

target = rgb2gray(target);
reference = rgb2gray(reference);

% proveden� detekce hran u obou obraz�
target = edge(target, "canny");
reference = edge(reference, "canny");

% vyhled�n� prost�edn�ho bodu v referen�n�m obrazu
refPointX = round(size(reference,1)/2);
refPointY = round(size(reference,2)/2);

%ulo�en� v�ech hodnot, kter� jsou 1 v referen�n�m obrazu do hodnot "x" a
%"y"

[x,y]=find(reference>0);

maxPoints = size(x,1); %d� ��slo, kolik je bod� s 1 v referen�n�m obrazu
maxAngles = 180;

% P�eveden� referen�n�ho obrazu na gradientn� obraz
dy = imfilter(double(reference),[1; -1],'same');
dx = imfilter(double(reference),[1 -1],'same');
reference_gradient = atan2(dy,dx)*180/pi(); %vytvo�� gradientn� obraz a p�evede radi�ny na stupn�

%vytvo�en� R-tabulky
rtable = zeros(maxAngles, maxPoints, 2);
binCount = zeros(maxAngles);

for i=1:1:maxPoints

    k = reference_gradient(x(i),y(i)) + 180;
    binCount(k) = binCount(k) + 1;
  

    Dx = x(i) - refPointX;
    Dy = y(i) - refPointY;

    rtable(k, binCount(k), 1) = Dx;
    rtable(k, binCount(k), 2) = Dy;

   
end

%%
% Akumul�tor

% ulo�en� v�ech 1 v target obrazu do "a" a "b"
[a,b] = find(target > 0);
maxPoints_target = size(a,1); %dostane po�et bod� v target obraze

% p�eveden� na gradientn� obraz
dy_targ = imfilter(double(target),[1; -1],'same'); 
dx_targ = imfilter(double(target),[1 -1],'same');
target_gradient = atan2(dy_targ,dx_targ)*180/pi();

% Vytvo�en� Houghova prostoru
[w,z] = size(target);
size_target = size(target);
angle = 360;
accumulator = zeros(w,z,angle);

for i=1:1:maxPoints_target 
h = target_gradient(a(i), b(i)) + 180;


for j = 1:1:binCount(h)
for q = 1:angle

tx = a(i) - rtable(h, j, 1);
ty = b(i) - rtable(h, j, 2);

if (tx>0) && (tx<size_target(1)) && (ty>0) && (ty<size_target(2))
accumulator(tx, ty, q) = accumulator(tx, ty, q)+1;

end
end
end
end

max_value1 = max(max(accumulator)); %find maximum in accumulator
[raw1,col1,theta] = find(accumulator == max_value1); %get row and column of the maximum in accumulator

% Display:




figure
imshow(target);


figure
imshow(orig_target);
hold on;
plot3(col1,raw1,theta,'r.');



% subplot(2,2,1),imshow(target),title('Target Image with Edges');
% %%
% % ----------------------------------
% % This part is just for Graph Title:
% % str = "Accumulator(x,y): ";
% % for i=1:size(raw1)
% % str1 = sprintf('(%d, %d, %d) ',raw1(i),col1(i),theta(i));
% % str = strcat(str,str1);
% % end
% 
% 
% subplot(2,2,[3,4]),imshow(orig_target),title('Target Image with Found Templates ( Red Dots )');
% hold on;
% plot3(col1,raw1,theta,'r.'); % Put red dot
% hold on;

