function varargout = antsSegment(varargin)
% segment T1 image using "Atropos" in ANTS
% The segmentation produces a binary labeled image with CSF=1, GM=2; WM=3 and three
% probability maps (CSF;GM;WM). Note that a lot op optins are not implemented trough this
% wrapper. Note that the command is run in the imageFolder
% 
% Usage:
% {command} = antsSegment(t1Image)
% {command} = antsSegment(t1Image,opts)
% 
% where opts is a struct with one or more of the follwoing fields
% opts.segName : name of binary segmentation file,"seg" is default
% opts.probName ='prob_' % name of output probability files
% opts.execute = [true | false]; default = true
% opts.convergence.numIterations (default 10)
% opts.convergence.treshold (default 0.001)
% opts.mask = mask file (brain mask), if no input is given, a rough mask is constructed
% using the following command, that is a mask of everyting > 0.01
% TresholdImage 3 T1file mask 0.01 Inf


opt.segName = 'seg'; % name of binary segmentation file
opt.probName ='prob_'; % name of output probability files
opt.execute = true;
opt.convergence.numIterations = 10;
opt.convergence.threshold = 0.001;
opt.mask = '';
opt.echoCommand = true;

basePath = pwd;

if nargin==1,
    imageFile = varargin{1};    
elseif nargin ==2,    
    imageFile  = varargin{1};
    iopt = varargin{2};              
    if isfield(iopt,'segName'),
        opt.segName = iopt.segName;
    end
    if isfield(iopt,'probName'),
        opt.probName = iopt.probName;
    end
    if isfield(iopt,'convergence'),
        opt.convergence = iopt.convergence;
    end
    if isfield(iopt,'mask'),
        opt.mask = iopt.mask;        
    end
    if isfield(iopt,'execute'),
          opt.execute = iopt.execute;
    end 
else
    error('Incorrect number of input argumants');        
end
% check that input file exist
chkFile(imageFile);
% determine where T1 image is located
[imageDir,fn] = fileparts(imageFile);

% create mask if not given
if isempty(opt.mask),
    maskFile = fullfile(imageDir,'mask.nii.gz');
    command = sprintf('ThresholdImage 3 %s %s 0.01 Inf',imageFile,maskFile);
    [err,output] = system(command);
    if err ~= 0,
        error('Error in antsSegment.m, when creating mask (ANTS MATLAB wrapper); output from command:\n %s\n',output);
    end    
    chkFile(maskFile);
else
    maskFile = opt.mask;
end

options = sprintf('-d 3 -a %s ',imageFile);
options = sprintf('%s -o [%s.nii.gz,%s%%02d.nii.gz] ',options,opt.segName,opt.probName);
options = sprintf('%s -c [%i,%f]',options,opt.convergence.numIterations,opt.convergence.threshold);
options = sprintf('%s -m [0.05,1]',options);
options = sprintf('%s -i kmeans[3]',options);
options = sprintf('%s -x %s',options,maskFile);


command = sprintf('Atropos %s',options);    
if opt.echoCommand,
    fprintf('%s\n',command);
end
if opt.execute,
    cd(imageDir);
    [err,output]  = system(command);
    cd(basePath);
    if err ~= 0,
        error('Error in antsSegment.m, when runninmg Atropos; output from command:\n %s\n',output);
    end
end
if nargout == 1,
    varargout{1} = command;
end



% COMMAND: 
%      Atropos
%           A finite mixture modeling (FMM) segmentation approach with possibilities for 
%           specifying prior constraints. These prior constraints include the specification 
%           of a prior label image, prior probability images (one for each class), and/or an 
%           MRF prior to enforce spatial smoothing of the labels. Similar algorithms include 
%           FAST and SPM. 
% 
% OPTIONS: 
%      -d, --image-dimensionality 2/3/4
%           This option forces the image to be treated as a specified-dimensional image. If 
%           not specified, Atropos tries to infer the dimensionality from the first input 
%           image. 
% 
%      -a, --intensity-image [intensityImage,<adaptiveSmoothingWeight>]
%           One or more scalar images is specified for segmentation using the 
%           -a/--intensity-image option. For segmentation scenarios with no prior 
%           information, the first scalar image encountered on the command line is used to 
%           order labelings such that the class with the smallest intensity signature is 
%           class '1' through class 'N' which represents the voxels with the largest 
%           intensity values. The optional adaptive smoothing weight parameter is applicable 
%           only when using prior label or probability images. This scalar parameter is to 
%           be specified between [0,1] which smooths each labeled region separately and 
%           modulates the intensity measurement at each voxel in each intensity image 
%           between the original intensity and its smoothed counterpart. The smoothness 
%           parameters are governed by the -b/--bspline option. 
% 
%      -b, --bspline [<numberOfLevels=6>,<initialMeshResolution=1x1x...>,<splineOrder=3>]
%           If the adaptive smoothing weights are > 0, the intensity images are smoothed in 
%           calculating the likelihood values. This is to account for subtle intensity 
%           differences across the same tissue regions. 
% 
%      -i, --initialization Random[numberOfClasses]
%                           Otsu[numberOfTissueClasses]
%                           KMeans[numberOfTissueClasses,<clusterCenters(in ascending order and for first intensity image only)>]
%                           PriorProbabilityImages[numberOfTissueClasses,fileSeriesFormat(index=1 to numberOfClasses) or vectorImage,priorWeighting,<priorProbabilityThreshold>]
%                           PriorLabelImage[numberOfTissueClasses,labelImage,priorWeighting]
%           To initialize the FMM parameters, one of the following options must be 
%           specified. If one does not have prior label or probability images we recommend 
%           using kmeans as it is typically faster than otsu and can be used with 
%           multivariate initialization. However, since a Euclidean distance on the inter 
%           cluster distances is used, one might have to appropriately scale the additional 
%           input images. Random initialization is meant purely for intellectual curiosity. 
%           The prior weighting (specified in the range [0,1]) is used to modulate the 
%           calculation of the posterior probabilities between the likelihood*mrfprior and 
%           the likelihood*mrfprior*prior. For specifying many prior probability images for 
%           a multi-label segmentation, we offer a minimize usage option (see -m). With that 
%           option one can specify a prior probability threshold in which only those pixels 
%           exceeding that threshold are stored in memory. 
% 
%      -s, --partial-volume-label-set label1xlabel2xlabel3
%           The partial volume estimation option allows one to modelmixtures of classes 
%           within single voxels. Atropos currently allows the user to model two class 
%           mixtures per partial volume class. The user specifies a set of class labels per 
%           partial volume class requested. For example, suppose the user was performing a 
%           classic 3-tissue segmentation (csf, gm, wm) using kmeans initialization. Suppose 
%           the user also wanted to model the partial voluming effects between csf/gm and 
%           gm/wm. The user would specify it using -i kmeans[3] and -t 1x2 -t 2x3. So, for 
%           this example, there would be 3 tissue classes and 2 partial volume classes. 
%           Optionally,the user can limit partial volume handling to mrf considerations only 
%           whereby the output would only be the three tissues. 
% 
%      --use-partial-volume-likelihoods 1/(0)
%                                       true/(false)
%           The user can specify whether or not to use the partial volume likelihoods, in 
%           which case the partial volume class is considered separate from the tissue 
%           classes. Alternatively, one can use the MRF only to handle partial volume in 
%           which case, partial volume voxels are not considered as separate classes. 
% 
%      -p, --posterior-formulation Socrates[<useMixtureModelProportions=1>,<initialAnnealingTemperature=1>,<annealingRate=1>,<minimumTemperature=0.1>]
%                                  Plato[<useMixtureModelProportions=1>,<initialAnnealingTemperature=1>,<annealingRate=1>,<minimumTemperature=0.1>]
%                                  Aristotle[<useMixtureModelProportions=1>,<initialAnnealingTemperature=1>,<annealingRate=1>,<minimumTemperature=0.1>]
%           Different posterior probability formulations are possible as are different 
%           update options. To guarantee theoretical convergence properties, a proper 
%           formulation of the well-known iterated conditional modes (ICM) uses an 
%           asynchronous update step modulated by a specified annealing temperature. If one 
%           sets the AnnealingTemperature > 1 in the posterior formulation a traditional 
%           code set for a proper ICM update will be created. Otherwise, a synchronous 
%           update step will take place at each iteration. The annealing temperature, T, 
%           converts the posteriorProbability to posteriorProbability^(1/T) over the course 
%           of optimization. 
% 
%      -x, --mask-image maskImageFilename
%           The image mask (which is required) defines the region which is to be labeled by 
%           the Atropos algorithm. 
% 
%      -c, --convergence [<numberOfIterations=5>,<convergenceThreshold=0.001>]
%           Convergence is determined by calculating the mean maximum posterior probability 
%           over the region of interest at each iteration. When this value decreases or 
%           increases less than the specified threshold from the previous iteration or the 
%           maximum number of iterations is exceeded the program terminates. 
% 
%      -k, --likelihood-model Gaussian
%                             HistogramParzenWindows[<sigma=1.0>,<numberOfBins=32>]
%                             ManifoldParzenWindows[<pointSetSigma=1.0>,<evaluationKNeighborhood=50>,<CovarianceKNeighborhood=0>,<kernelSigma=0>]
%                             JointShapeAndOrientationProbability[<sigma=1.0>,<numberOfBins=32>]
%                             LogEuclideanGaussian
%           Both parametric and non-parametric options exist in Atropos. The Gaussian 
%           parametric option is commonly used (e.g. SPM & FAST) where the mean and standard 
%           deviation for the Gaussian of each class is calculated at each iteration. Other 
%           groups use non-parametric approaches exemplified by option 2. We recommend using 
%           options 1 or 2 as they are fairly standard and the default parameters work 
%           adequately. 
% 
%      -m, --mrf [<smoothingFactor=0.3>,<radius=1x1x...>,<mrfProbabilityImage>='']
%           Markov random field (MRF) theory provides a general framework for enforcing 
%           spatially contextual constraints on the segmentation solution. The default 
%           smoothing factor of 0.3 provides a moderate amount of smoothing. Increasing this 
%           number causes more smoothing whereas decreasing the number lessens the 
%           smoothing. The radius parameter specifies the mrf neighborhood. Different update 
%           schemes are possible but only the asynchronous updating has theoretical 
%           convergence properties. 
% 
%      -g, --icm [<useAsynchronousUpdate=1>,<maximumNumberOfICMIterations=1>,<icmCodeImage=''>]
%           Asynchronous updating requires the construction of an ICM code image which is a 
%           label image (with labels in the range {1,..,MaximumICMCode}) constructed such 
%           that no MRF neighborhood has duplicate ICM code labels. Thus, to update the 
%           voxel class labels we iterate through the code labels and, for each code label, 
%           we iterate through the image and update the voxel class label that has the 
%           corresponding ICM code label. One can print out the ICM code image by specifying 
%           an ITK-compatible image filename. 
% 
%      -o, --output [classifiedImage,<posteriorProbabilityImageFileNameFormat>]
%           The output consists of a labeled image where each voxel in the masked region is 
%           assigned a label from 1, 2, ..., N. Optionally, one can also output the 
%           posterior probability images specified in the same format as the prior 
%           probability images, e.g. posterior%02d.nii.gz (C-style file name formatting). 
% 
%      -u, --minimize-memory-usage (0)/1
%           By default, memory usage is not minimized, however, if this is needed, the 
%           various probability and distance images are calculated on the fly instead of 
%           being stored in memory at each iteration. Also, if prior probability images are 
%           used, only the non-negligible pixel values are stored in memory. 
%           <VALUES>: 0
% 
%      -w, --winsorize-outliers BoxPlot[<lowerPercentile=0.25>,<upperPercentile=0.75>,<whiskerLength=1.5>]
%                               GrubbsRosner[<significanceLevel=0.05>,<winsorizingLevel=0.10>]
%           To remove the effects of outliers in calculating the weighted mean and weighted 
%           covariance, the user can opt to remove the outliers through the options 
%           specified below. 
% 
%      -e, --use-euclidean-distance (0)/1
%           Given prior label or probability images, the labels are propagated throughout 
%           the masked region so that every voxel in the mask is labeled. Propagation is 
%           done by using a signed distance transform of the label. Alternatively, 
%           propagation of the labels with the fast marching filter respects the distance 
%           along the shape of the mask (e.g. the sinuous sulci and gyri of the cortex. 
%           <VALUES>: 0
% 
%      -l, --label-propagation whichLabel[lambda=0.0,<boundaryProbability=1.0>]
%           The propagation of each prior label can be controlled by the lambda and boundary 
%           probability parameters. The latter parameter is the probability (in the range 
%           [0,1]) of the label on the boundary which increases linearly to a maximum value 
%           of 1.0 in the interior of the labeled region. The former parameter dictates the 
%           exponential decay of probability propagation outside the labeled region from the 
%           boundary probability, i.e. boundaryProbability*exp( -lambda * distance ). 
% 
%      -h 
%           Print the help menu (short version). 
%           <VALUES>: 0
% 
%      --help 
%           Print the help menu. 
%           <VALUES>: 0
% 

