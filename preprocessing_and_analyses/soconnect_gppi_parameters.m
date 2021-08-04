function soconnect_gppi_parameters(subjname,workdir,VOI_name, gPPI_workdir)

global dirs subj info
%% Setting the gPPI Parameters
P.subject       = subjname; % A string with the subjects id
P.directory     = workdir; % path to the first level GLM directory
P.VOI           = fullfile(dirs.masks,[VOI_name, '.nii']); % path to the ROI image
P.Region        = VOI_name; % string, basename of output folder
P.Estimate      = 1; % Yes, estimate this gPPI model
P.Contrast      =  'Omnibus F-test for PPI Analyses';  % uses Omnibut F-test for PPI Analyses
P.extract       = 'eig'; % method for ROI extraction. Default is eigenvariate
P.Tasks         = ['0' {'self' 'sim' 'dis' 'control','cue'}]; % Specify the tasks for this analysis. Think of these as trial types. Zero means "does not have to occur in every session"
P.Weights       = []; % Weights for each task. If you want to weight one more than another. Default is not to weight when left blank
%P.maskdir       = fullfile(gPPI_workdir); % Where should we save the masks?
P.equalroi      = 0; % When 1, All ROI's must be of equal size. When 0, all ROIs do not have to be of equal size
P.FLmask        = 1; % restrict the ROI's by the first level mask. This is useful when ROI is close to the edge of the brain
P.analysis      = 'psy'; % for "psychophysiological interaction"
P.method        = 'cond'; % "cond" for gPPI and "trad" for traditional PPI
P.CompContrasts = 1; % 1 to estimate contrasts
P.Weighted      = 0; % Weight tasks by number of trials. Default is 0 for do not weight
P.outdir        = fullfile(gPPI_workdir); % Output directory
P.ConcatR       = 1; % Tells gPPI toolbox to concatenate runs



P.Contrasts(1).left      = {'self'}; % left side or positive side of contrast
P.Contrasts(1).right     = {'control'}; % right side or negative side of contrast
P.Contrasts(1).STAT      = 'T'; % T contrast
P.Contrasts(1).Weighted  = 0; % Weighting contrasts by trials. Default is 0 for do not weight
P.Contrasts(1).MinEvents = 1; % min number of event need to compute this contrast
P.Contrasts(1).name      = 'Self_vs_CT'; % Name of this contrast

P.Contrasts(2).left      = {'sim'}; 
P.Contrasts(2).right     = {'control'}; 
P.Contrasts(2).STAT      = 'T';
P.Contrasts(2).Weighted  = 0; 
P.Contrasts(2).MinEvents = 1; 
P.Contrasts(2).name      = 'Sim_vs_CT';

P.Contrasts(3).left      = {'dis'};
P.Contrasts(3).right     = {'control'};
P.Contrasts(3).STAT      = 'T'; 
P.Contrasts(3).Weighted  = 0; 
P.Contrasts(3).MinEvents = 1; 
P.Contrasts(3).name      = 'Dis_vs_CT';

P.Contrasts(4).left      = {'sim'}; 
P.Contrasts(4).right     = {'self'}; 
P.Contrasts(4).STAT      = 'T'; 
P.Contrasts(4).Weighted  = 0; 
P.Contrasts(4).MinEvents = 1; 
P.Contrasts(4).name      = 'Sim_vs_Self'; 

P.Contrasts(5).left      = {'dis'}; 
P.Contrasts(5).right     = {'self'}; 
P.Contrasts(5).STAT      = 'T'; 
P.Contrasts(5).Weighted  = 0; 
P.Contrasts(5).MinEvents = 1; 
P.Contrasts(5).name      = 'Dis_vs_Self'; 

P.Contrasts(6).left      = {'sim'}; % left side or positive side of contrast
P.Contrasts(6).right     = {'dis'}; % right side or negative side of contrast
P.Contrasts(6).STAT      = 'T'; % T contrast
P.Contrasts(6).Weighted  = 0; % Weighting contrasts by trials. Default is 0 for do not weight
P.Contrasts(6).MinEvents = 1; % min number of event need to compute this contrast
P.Contrasts(6).name      = 'Sim_vs_Dis'; % Name of this contrast

P.Contrasts(7).left      = {'self'}; 
P.Contrasts(7).right     = {'sim'}; 
P.Contrasts(7).STAT      = 'T'; 
P.Contrasts(7).Weighted  = 0; 
P.Contrasts(7).MinEvents = 1; 
P.Contrasts(7).name      = 'Self_vs_Sim'; 

P.Contrasts(8).left      = {'self'}; 
P.Contrasts(8).right     = {'dis'}; 
P.Contrasts(8).STAT      = 'T'; 
P.Contrasts(8).Weighted  = 0; 
P.Contrasts(8).MinEvents = 1; 
P.Contrasts(8).name      = 'Self_vs_Dis'; 

P.Contrasts(9).left      = {'dis'}; % left side or positive side of contrast
P.Contrasts(9).right     = {'sim'}; % right side or negative side of contrast
P.Contrasts(9).STAT      = 'T'; % T contrast
P.Contrasts(9).Weighted  = 0; % Weighting contrasts by trials. Default is 0 for do not weight
P.Contrasts(9).MinEvents = 1; % min number of event need to compute this contrast
P.Contrasts(9).name      = 'Dis_vs_Sim'; % Name of this contrast

%%% All set to zero for do not use. 
P.FSFAST           = 0;
P.peerservevarcorr = 0;
P.wb               = 0;
P.zipfiles         = 0;
P.rWLS             = 0;

%% Run PPI
PPPI(P)