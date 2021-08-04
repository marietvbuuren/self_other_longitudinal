function soconnect_lt_twoflex_group_anova_gppi
%% filler script for mixed flexible factorial anova gPPI analyses

dirs.home= fullfile('/data','mariet','SoConnect','DATA_lt');  %home directory
dirs.scripts=  fullfile('/data','mariet','scripts','VU','soconnect','MRI'); % directory of scripts
dirs.outputroot = fullfile(dirs.home,'MRI','Experimental','data_group','MT','gPPI','dMPFC','wave3_students');
dirs.input = fullfile(dirs.home,'MRI','Experimental','data_group','MT','gPPI_firstlevel','dMPFC');
dirs.reports = fullfile(dirs.home, 'MRI','Experimental','jobreports');
cd(dirs.outputroot)
workdir=fullfile(dirs.outputroot,'twoway_flex_group');
if ~exist(char(workdir),'dir'); mkdir(char(workdir)); end

subjects_adolescents =[1,15,20,23,24,25,27,30,35,38,39,42,43,45,46,47,48,54,57,58,62,63,64,67,70,71,72,73,74,77,78,79,84,85];%included in all waves
subjects_adults=[1:7,9,10,12:36,38:45];

contrasts={'Self_vs_CT','Sim_vs_CT','Dis_vs_CT','Sim_vs_Self','Dis_vs_Self','Sim_vs_Dis','Dis_vs_Sim'};

jobfile = '/data/mariet/scripts/VU/soconnect/MRI/soconnect_lt_twoflex_anova_group.mat';
load(jobfile)
matlabbatch{1}.spm.stats.factorial_design.dir=cellstr(workdir);
for i=1:numel(subjects_adolescents)
    subj=subjects_adolescents(i);
    if subj<10,
        subjname = ['0',num2str(subj)];
    else   subjname = num2str(subj);
    end
    clear funcfiles;
    funcfiles={};
    for c=1:3,
        clear contrast; contrast=char(contrasts(c));
            funcfiles= [funcfiles;cellstr(spm_select('FPList',[dirs.input,'/allwaves'],['con_PPI_',contrast,'_SoConnect_3_',subjname,'.nii']))]; %to load in adolescent data wave 3
       
    end
    
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans=funcfiles;
end

add=numel(subjects_adolescents);
for j=1:numel(subjects_adults)
    subj=subjects_adults(j);
    if subj<10,
        subjname = ['0',num2str(subj)];
    else   subjname = num2str(subj);
    end
    clear funcfiles;
     funcfiles={};
    for c=1:3,
        clear contrast; contrast=char(contrasts(c));
            funcfiles= [funcfiles;cellstr(spm_select('FPList',[dirs.input,'/'],['con_PPI_',contrast,'_SoConnect_9_',subjname,'.nii']))]; %to load in data adult sample
    end
    k=j+add;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(k).scans=funcfiles;
   
end

jobfilename = ['twoway_flex_group_gppi.mat'];
eval(['save ',workdir,'/',jobfilename,' matlabbatch']);
spm_jobman('initcfg')
spm_jobman('run', matlabbatch);
clear matlabbatch
