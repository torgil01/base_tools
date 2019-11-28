function fslDTI(studyDir)
% run the FSL DTI processing pipline

% data dir
dtFiles = findFiles(studyDir,'^dti.nii.gz');

for i=1:length(dtFiles),
   % 00 
   [dtiDir, ~] = fileparts(dtFiles{i});
   % 1. eddy 
   
   correctedDt = addInFront(dtFiles{i},'corr');
   eddy_correct(dtFiles{i},correctedDt,0);
   bvec = fullfile(dtiDir,'dti.bvec');
   bvecRot = fullfile(dtiDir,'rot.bvec');
   corrEcclog=fullfile(dtiDir,'corrdti.ecclog');
   rotateBvecs(bvec,bvecRot,corrEcclog)
   
   % 2. bet
   b0 = fullfile(dtiDir,'b0'); 
   fslroi(correctedDt,b0,0,1)
   brain = fullfile(dtiDir,'brain');
   brainMask = fullfile(dtiDir,'mask.nii.gz');
   runBet(b0,brain,brainMask);
   
   % 3. dtifit
   id = getID(dtiDir,1);
   outFile  = fullfile(dtiDir,id);
   bval = fullfile(dtiDir,'dti.bval');
   fslDtifit(correctedDt,outFile,brainMask,bvecRot,bval);
end
