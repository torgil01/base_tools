function [noiseLevel,tempSmoothness] = estnoise(fwhm,highPassCutoff,epiFile)
% function estnoise(fwhm,highPassCutoff,epiFile)
% estimate noise in timeseries using estnoise from FSL
% Use estnoise script
%  estnoise <4d_input_data> spatial_sigma temp_hp_sigma temp_lp_sigma
% 
% Need to know FWHM and HP filter cutoff
% Example:
% FWHM = 5, HP = 114s
% 
% spatial_sigma = fwhm/(2*sqrt(2*ln(2))) = fwhm/2.35482004503
% temp_hp_sigma = HP/(2*TR)
% temp_lp_sigma = -1
% 
% estnoise fMRIsmerteSSENSE.nii.gz  2.12330450072 19 -1
spatial_sigma = fwhm/2.355;
temp_hp_sigma = highPassCutoff/2;
temp_lp_sigma = -1;
command = sprintf('estnoise %s %16.10f %f %i',epiFile,spatial_sigma,temp_hp_sigma,temp_lp_sigma);
fprintf('%s\n',command);
[err, output] = system(command);
%output
tmp = str2num(output);
noiseLevel = tmp(1);
tempSmoothness = tmp(2);
