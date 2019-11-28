function varargout=hist2(A,B)
sA=imstat(A);
sB=imstat(B);
ax=sA.nx;
ay=sA.ny;
H=zeros(ax,ay); % allocate histogram
numStep=ax;  % number of pixels in  2d histogram
rngA=[sA.min:(sA.max-sA.min)/(numStep-1):sA.max];
rngB=[sB.min:(sB.max-sB.min)/(numStep-1):sB.max];
% we assume that A and B have the same dimensions 
for i=1:ax,
    for j=1:ay,
        vA=A(i,j);
        vB=B(i,j);
        % determine A-pos in histogram
        indA=find(rngA >= vA);
        indB=find(rngB >=vB);
        H(indA(1),indB(1))=H(indA(1),indB(1))+1;
    end
end
H=H/(ax*ay);
if nargout == 1,
    varargout{1}=H;
else 
    nargout = [];
    figure, imshow(H,[]);
end