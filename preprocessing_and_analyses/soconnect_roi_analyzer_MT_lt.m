   
function soconnect_roi_analyzer_MT_lt
%Mariet van Buuren 2020
warning('off','all')

info.wave=9;
dirs.home = fullfile('/data','mariet','SoConnect','DATA_lt');

if info.wave==1,
    % subjects=[1,15,20,23,24,25,27,30,35,38,39,42,43,45,46,47,48,54,57,58,62,63,64,67,70,71,72,73,74,77,78,79,84,85];%all waves, no motion, behavior ok
    subjects = [1,3,4,6:10,12,14:20,22:27,29,30,33:39,41:51,53,54,55,57:64,66:75,77:79,82,84:86];  %%%All participants after exclusion based on criteria (motion >3mm, data failure, neurological abnorm., coverage ROIs)
elseif info.wave==2,
    %subjects=[1,15,20,23,24,25,27,30,35,38,39,42,43,45,46,47,48,54,57,58,62,63,64,67,70,71,72,73,74,77,78,79,84,85];%all waves, no motion, behavior ok
    subjects = [1,2,6,9,13,14,15,18,20,22,23,24,25,26,27,28,29,30,32,33,34,35,38,39,41,42,43,45,46,47,48,50,52,54,55,57,58,62,63,64,65,66,67,70,71,72,73,74,75,76,77,78,79,81,84,85];%%%All participants after exclusion based on criteria (motion >3mm, data failure, neurological abnorm., coverage ROIs)
elseif info.wave==3,
    % subjects=[1,15,20,23,24,25,27,30,35,38,39,42,43,45,46,47,48,54,57,58,62,63,64,67,70,71,72,73,74,77,78,79,84,85];%all waves, no motion, behavior ok
    subjects= [1,2,10,12,15,20,23,24,25,27,28,30,32,35,38,39,42,43,45,46,47,48,52,54,57,58,60,62,63,64,65,67,68,70,71,72,73,74,77,78,79,81,84,85,86];%%%All participants after exclusion based on criteria (motion >3mm, data failure, neurological abnorm., coverage ROIs)
elseif info.wave==9,
    subjects= [1:7,9,10,12:36,38:45];%%All participants after exclusion based on criteria (motion >3mm, data failure, neurological abnorm., coverage ROIs
end

wave=num2str(info.wave);

dirs.scripts=  fullfile('/data','mariet','scripts', 'VU','soconnect','MRI');
dirs.root = fullfile(dirs.home,'MRI');

dirs.mtroot = fullfile(dirs.root,'Experimental', 'data_group', 'MT');
dirs.masks=fullfile(dirs.mtroot,'masks'); %directory where rois (.mat) are located

maskname='Denny_conj';  %%used for outputdirectory
description='Denny_5rois_';  %%used for outputfile
dirs.outputroot = fullfile(dirs.mtroot, 'roi_analyses');
dirs.output=fullfile(dirs.outputroot, maskname);  %% outputdirectory
dirs.statsroot=fullfile(dirs.root,'Experimental', 'data_indiv');
if  ~exist([dirs.output,'dir']); mkdir(dirs.output); end

addpath(genpath('/data/mariet/programmes/SPM/spm12/'))
addpath(genpath('/data/mariet/programmes/marsbar-0.44/'))

roi_mat = cellstr(spm_select('FPList',dirs.masks,'.mat'));
for j=1 : length(roi_mat),
    roiname_tmp=char(roi_mat(j));
    [p n e v] = spm_fileparts(roiname_tmp);
    roiname=n;
    
    for isubject = 1: numel(subjects)
        subj = subjects(isubject);   %subj
        if subj<10,
            subjname = ['SoConnect_',wave,'_0',num2str(subj)];
        else
            subjname = ['SoConnect_',wave,'_',num2str(subj)];
        end
        name{isubject}=subjname;
        dirs.stats= fullfile(dirs.statsroot,['w', wave],subjname,'MT_workdir/');
                
        marsbar('on');                                      % Initialise MarsBar
        
        spm_mat = fullfile(dirs.stats,'SPM.mat');
        
        D = mardo(spm_mat);                             % Make MarsBar design object
        R = maroi('load_cell',cellstr(roi_mat{j}));               % Make MarsBar ROI object
        Y = get_marsy(R{:},D,'mean');
        xCon = get_contrasts(D);
        E = estimate(D,Y);
        E = set_contrasts(E,xCon);
        b = betas(E);
        [rep_strs, marsS, marsD, changef] = stat_table(E, [1:length(xCon)]);
        
        for c=1:length(xCon),
            con_values(isubject,c)=marsS.con(c);
        end
        clear  spm_mat D R Y  E b rep_strs marsS marsD changef dirs_stats
    end
    
    fid = fopen(fullfile(dirs.output,['Group_mean_',roiname,'_',description, wave,'_.txt']),'w+');
    fprintf(fid,['Data from ',roiname,'\n','subjectname']);
    for v=1:length(xCon),
        fprintf(fid,['\t', xCon(v).name]);
    end
    fprintf(fid,'\n');
    
    for cv=1: size(con_values,1)
        fprintf(fid,[name{cv},'\t',num2str(con_values(cv,:))]);
        fprintf(fid,'\n');
    end
    clear outputfile con_values t_values p stats mean_values fid cv roiname_tmp p n e v  roiname xCon D R Y file spm_mat
end