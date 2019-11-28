function mask = binarize(im,thr)
% fast binarization with bsxfun
% binarize image on thr
%im(im < thr) =0;
%im(im >= thr) = 1;
% faster:
mask = bsxfun(@gt,im,thr); 
