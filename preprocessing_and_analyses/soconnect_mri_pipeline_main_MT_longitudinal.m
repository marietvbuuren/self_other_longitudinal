function soconnect_mri_pipeline_main_MT_longitudinal(jobinputs)

%% script to preprocess & analyze longitudinal fMRI task data project SoConnect
%% calls the following functions:
% - copy data from RAW to experimental folder & converts PAR/REC to niftii (3D)
% - preprocess data; 1 batch for all steps & using samplespecific tissuepriors
%   created with CerebroMatic- M. Wilke
% - runs data quality check on normalized data
% - runs first level analyses


%% version 1.0 18/09/2020 - Mariët van Buuren 
% (dd/mm/yyyy)
% 18/09/2020 based on soconnect_mri_pipeline_main_task
% 18/09/2020 created longitudinal pipeline, using name of files of
% conversion to .nii and does not perform QA before normalization - uses
% one batch to perform preprocessing

global dirs subj info

subj = cell2mat(jobinputs(1));
todo.sort = cell2mat(jobinputs(2));
todo.preproc = cell2mat(jobinputs(3));
todo.wtsnr= cell2mat(jobinputs(4));
todo.normalize_mask= cell2mat(jobinputs(5));
todo.firstlevel= cell2mat(jobinputs(6));
todo.addcontrast= cell2mat(jobinputs(7));
todo.gppi=cell2mat(jobinputs(8));
todo.addcontrastgppi=cell2mat(jobinputs(9));

wave=num2str(info.wave);
%%relevant directories % subjectname
rawdirroot=fullfile(dirs.rootraw, 'RAW');
cd(rawdirroot);

if subj<10,
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['w',wave'],['SoConnect_',wave,'_0',num2str(subj)]);
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    t=dir(['SoConnect_',wave,'_0',num2str(subj), '*']);
    rawdirsubj= fullfile(dirs.rootraw, 'RAW',t.name);
    subjname = ['SoConnect_',wave,'_0',num2str(subj)];
else
    niidirsubj= fullfile(dirs.root,'Experimental', 'data_indiv',['w',wave'],['SoConnect_',wave,'_',num2str(subj)]);
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    t=dir(['SoConnect_',wave,'_',num2str(subj), '*']);
    rawdirsubj= fullfile(dirs.rootraw, 'RAW',t.name);
    subjname = ['SoConnect_',wave,'_',num2str(subj)];
end
clear t;

symlinkdir_stat_MT=fullfile(dirs.root,'Experimental','data_group','MT','MT_firstlevel');
symlinkdir_gppi_MT=fullfile(dirs.root,'Experimental','data_group','MT','gPPI_firstlevel');

whatscans=info.whatscans;
run=info.run;
cd(dirs.reports);
% settings
description=[];
hpf_qa=128;
isi_qa=2;

%% sort raw data
if todo.sort == true
    if ~exist(niidirsubj,'dir'); mkdir(niidirsubj); end
    soconnect_prepare_sort_main_name(rawdirsubj,niidirsubj,info)
end

%% preprocessing 
%(-)reallign functional data
%(-)coregister T1 to mean functional
%(-)segment T1 using priors created by CerebroMatic (based on 84 adolescents)
%(-)use deformation maps to normalize T1 & functional images
%(-)smoothing with 6 6 6 mm smoothing kernel

if todo.preproc == true
     for i = 2:numel(whatscans)
            whattodo= ['preprocess_complete', run{whatscans(i)}];
            nrun = 1; % enter the number of runs here
            clear jobfile jobs inputs matlabbatch mbatch;
            jobfile =cellstr(fullfile(dirs.scripts,'soconnect_preprocess_complete_batch_job.m'));
                       
            jobs = repmat(jobfile, 1, nrun);
            reallign_input= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['.*\.nii$']));
            coreg_inputsrc= cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['.*\.nii$']));
            inputs = cell(2, nrun);
            for crun = 1:nrun
                inputs{1, crun} = reallign_input; % Realign: Estimate & Reslice: Session - cfg_files
                inputs{2, crun} = coreg_inputsrc; % Coregister: Estimate: Source Image - cfg_files
            end
            spm('defaults', 'FMRI');
            
            jobfilename = [whattodo,subjname, '.mat'];
            
            mbatch=spm_jobman('serial', jobs, '', inputs{:});
            eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
            cd ([niidirsubj,'/',run{whatscans(i)}]);
      end
end
    
%% perform signal to noise (QA) analysis on normalized data
% perform quality check on realigned data (creates mask of resliced normalized T1) including signal change per scan, motion and tsnr
% maps, uses scripts following bzbtx, see https://github.com/bramzandbelt/fmri_preprocessing_and_qa_code

if todo.wtsnr == true
    whatscans=info.whatscans;
    run=info.run;
    for i = 2:numel(whatscans)
        clear qadir srcimgs rpfile t1img
        qadir=fullfile(niidirsubj,[run{whatscans(i)},'_w_qadir']);
        if ~exist(qadir,'dir'); mkdir(qadir); end
        srcimgs= spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^wS','.*\.nii$']);
        rpfile=spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^rp_','.*\.txt$']);
        jobfile =cellstr(fullfile(dirs.scripts,'soconnect_reslic_anat_job.m'));
        nrun=1;
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(2, nrun);
        for crun = 1:nrun
            inputs{1, crun} = cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^wS','.*\.nii$']));  % Coregister: Reslice: Image Defining Space - cfg_files
            inputs{2, crun} =   cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^wSo','.*\.nii$'])); % Coregister: Reslice: Images to Reslice - cfg_files
        end
        spm('defaults', 'FMRI');
        
        jobfilename = ['reslanat_', subjname, '.mat'];
        
        mbatch=spm_jobman('serial', jobs, '', inputs{:});
        eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
        
        t1img=spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['^rwSo','.*.nii$']);
        hpf = hpf_qa;
        isi = isi_qa;
        cd (qadir)
        mvb_qa_fast('preproc',srcimgs,t1img,rpfile,isi,hpf,qadir)
        cd ([niidirsubj,'/',run{whatscans(i)}]);
        %else
        %end
    end
end
%% creates normalized mask - not used in current analyses

if todo.normalize_mask== true
    whatscans=info.whatscans;
    run=info.run;
    for i = 2:numel(whatscans)
         rest=strcmp(run{whatscans(i)},'RS');
         if scan(whatscans(i))>0 && rest==0,
            nrun = 1; % enter the number of runs here
            clear jobfile jobs inputs matlabbatch mbatch;
            jobfile =cellstr(fullfile(dirs.scripts,'soconnect_normalize_reslic_masks_job.m'));
            jobs = repmat(jobfile, 1, nrun);
            inputs = cell(2, nrun);
            deformation_field=cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['y.*\.nii$']));
            for seg=1:3,
            segmasks(seg,1)= cellstr(spm_select('FPList',[niidirsubj,'/','T1_',run{whatscans(i)}],['c',num2str(seg),'.*\.nii$']));
            end
            normfunc= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^wS','.*\.nii$']));
            for crun = 1:nrun
                inputs{1, crun} =deformation_field; % Normalise: Write: Deformation Field - cfg_files
                inputs{2, crun} = segmasks;
                inputs{3, crun} = normfunc; 
            end
            spm('defaults', 'FMRI');
            
            jobfilename = ['normalizereslmasks_', subjname, '.mat'];          
            mbatch=spm_jobman('serial', jobs, '', inputs{:});
            eval(['save ',dirs.reports,'/',jobfilename,' mbatch']);
            
            clear T1dir; T1dir=fullfile(niidirsubj,['T1_',run{whatscans(i)}]);
            cd(T1dir);
            clear filename_mask;filename_mask= dir('rwc1*');
            clear source; source = fullfile(T1dir,filename_mask(1).name);
            clear newdir; newdir = fullfile(T1groupdir,[filename_mask(1).name]);
            unix(['cp ' source ' ' newdir]);
         end
    end
end

%% First-level analysis task
if todo.firstlevel == true
    for i = 2:numel(whatscans)
            clear symlinkdir_stat workdir whattodo rpfile funcfiles
            whattodo= ['firstlevel_', run{whatscans(i)}];
            
            %set directories & scans & logfile
            workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']); 
            if ~exist(workdir,'dir'); mkdir(workdir); end
          
            datadirbeh=fullfile(dirs.behav,['w',wave],run{whatscans(i)},'outputfiles');
            funcfiles= cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^swS','.*\.nii$']));
            rpfile=cellstr(spm_select('FPList',[niidirsubj,'/',run{whatscans(i)}],['^rp_','.*\.txt$']));
            
            symlinkdir_stat=symlinkdir_stat_MT;
            if subj<10,
                logfile=[datadirbeh, '/mentalizing_SC',wave,'_0',num2str(subj),'.txt'];
            else  logfile=[datadirbeh, '/mentalizing_SC',wave,'_',num2str(subj),'.txt'];
            end
            
            if ~exist(symlinkdir_stat,'dir'); mkdir(symlinkdir_stat); end
            
            %create onsetfiles & run firstlevel analyses
            soconnect_firstlevel_MT(whattodo,workdir,logfile,funcfiles,rpfile,symlinkdir_stat,subjname);
    end
end
%% Add contrast for overall task effects per wave
if todo.addcontrast == true
    clear matlabbatch workdir
    for i = 2:numel(whatscans)
             symlinkdir_stat=symlinkdir_stat_MT;
             workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']);
             cd(workdir)
             jobfile = fullfile(dirs.scripts,['soconnect_add_taskcontrast.mat']);
             load(jobfile);
             matlabbatch{1}.spm.stats.con.spmmat=cellstr(spm_select('FPList',workdir,'^SPM.*\.mat$'));
             spm_jobman('initcfg')
             spm_jobman('run', matlabbatch);
             prefix = [subjname,'_'];
             cd(workdir)
             clear filenames; filenames = dir(['*_0014.nii']);%%change when other con is added
             %copy all volumes to newdir
             for f = 1:numel(filenames)
             clear source; source = fullfile(workdir,filenames(f).name);
             clear newdir; newdir = fullfile(symlinkdir_stat,[prefix,filenames(f).name]);
             unix(['cp ' source ' ' newdir]);
             end
    end
end

%%run gppi analysis
if todo.gppi == true
    clear matlabbatch workdir PPI
    for i = 2:numel(whatscans)
        workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']);
        
        VOI{1}.name = 'vMPFC';
        VOI{2}.name = 'dMPFC';
   
        for ivoi = 1%:size(VOI,2)
            voi = VOI{ivoi};
            VOI_name=voi.name;
            gPPI_workdir=fullfile(workdir,VOI_name);
            
            symlinkdir_gppi_MT=fullfile(symlinkdir_gppi_MT,VOI_name); 
            if ~exist(gPPI_workdir,'dir'); mkdir(gPPI_workdir); end
            if ~exist(symlinkdir_gppi_MT,'dir'); mkdir(symlinkdir_gppi_MT); end
        
            soconnect_gppi_parameters(subjname,workdir,VOI_name,gPPI_workdir);
            soconnect_copydata_gPPI([gPPI_workdir,'/PPI_',VOI_name],symlinkdir_gppi_MT,subjname);
            clear P gPPI_workdir VOI_name 
        end
    end
    
end
%% Add contrast for overall task effects per wave gppi
if todo.addcontrastgppi == true
    clear matlabbatch workdir
    for i = 2:numel(whatscans)
        
        workdir= fullfile(niidirsubj,[run{whatscans(i)},'_workdir']);
        VOI_name='vMPFC';
        symlinkdir_gppi_MT=fullfile(symlinkdir_gppi_MT,VOI_name); %% pas aan!
        gPPI_workdir=fullfile(workdir,VOI_name,'PPI_vMPFC');
        cd(gPPI_workdir)
        jobfile = fullfile(dirs.scripts,['soconnect_add_taskcontrastgppi.mat']);
        load(jobfile);
        matlabbatch{1}.spm.stats.con.spmmat=cellstr(spm_select('FPList',gPPI_workdir,'^SPM.*\.mat$'));
        spm_jobman('initcfg')
        spm_jobman('run', matlabbatch);
        postfix = ['_',subjname,'.nii'];
        cd(gPPI_workdir)
        clear filenames; filenames = dir(['con_0010.nii']);%%change when other con is added
        newname='con_PPI_All_vs_CT';
        %copy all volumes to newdir
        for f = 1:numel(filenames)
            clear source; source = fullfile(gPPI_workdir,filenames(f).name);
            clear newdir; newdir = fullfile(symlinkdir_gppi_MT,[newname, postfix]);
            unix(['cp ' source ' ' newdir]);
        end
    end
end