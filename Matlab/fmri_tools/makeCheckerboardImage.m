function makeCheckerboardImage(A,B)
%
A(A<3000)=0;
B(B<3000)=0;

% for 128 images
ck=checkerboard(8,8,8);
% remove gray
ck(ck == 0.7) =1;
% make inverse
ick=imcomplement(ck);
%scale images
A=A/max(A(:));
B=B/max(B(:));
B=B+1.1;
% chekerboard
cA=ck.*A;
cB=ick.*B;
% remove bg
tresh=1.1;
fused=cA+cB;
fused(fused == tresh) =0;
%max(fused(:))
%min(fused(:))
load('grayBlueMap.mat');
imshow(fused,[0 2.1])
colormap(grayBlueMap)
