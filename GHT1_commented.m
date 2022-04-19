%Part of this script are retrieved from...
clc;
close all;
clearvars;

%%--
%Nahrání referenèního a target obrazu
target = imread("target_test.png");
reference = imread("reference_test.png");

orig_target = target; %uložení pùvodního obrazu do nové promìnné, protože bude využit na konci 

% Zobrazení nahraných obrazù
% figure
% imshow(target)
% title("Target image")
% 
% figure
% imshow(reference)
% title("Reference image")

%%
% Pøevedení obrazù na grayscale

target = rgb2gray(target);
reference = rgb2gray(reference);

% provedení detekce hran u obou obrazù
target = edge(target, "canny");
reference = edge(reference, "canny");

% vyhledání prostøedního bodu v referenèním obrazu
refPointX = round(size(reference,1)/2);
refPointY = round(size(reference,2)/2);

%uložení všech hodnot, které jsou 1 v referenèním obrazu do hodnot "x" a
%"y"

[x,y]=find(reference>0);

maxPoints = size(x,1); %dá èíslo, kolik je bodù s 1 v referenšním obrazu
maxAngles = 180;

% Pøevedení referenèního obrazu na gradientní obraz
dy = imfilter(double(reference),[1; -1],'same');
dx = imfilter(double(reference),[1 -1],'same');
reference_gradient = atan2(dy,dx)*180/pi(); %vytvoøí gradientní obraz a pøevede radiány na stupnì

%vytvoøení R-tabulky
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
% Akumulátor

% uložení všech 1 v target obrazu do "a" a "b"
[a,b] = find(target > 0);
maxPoints_target = size(a,1); %dostane poèet bodù v target obraze

% pøevedení na gradientní obraz
dy_targ = imfilter(double(target),[1; -1],'same'); 
dx_targ = imfilter(double(target),[1 -1],'same');
target_gradient = atan2(dy_targ,dx_targ)*180/pi();

% Vytvoøení Houghova prostoru
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

