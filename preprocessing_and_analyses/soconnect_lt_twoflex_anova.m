function soconnect_lt_twoflex_anova
%% filler script for two way flexible factorial anova whole-brain analyses

dirs.home= fullfile('/data','mariet','SoConnect','DATA_lt');  %home directory
dirs.scripts=  fullfile('/data','mariet','scripts','VU','soconnect','MRI'); % directory of scripts
dirs.outputroot = fullfile(dirs.home,'MRI','Experimental','data_group','MT','whole_brain');
dirs.input = fullfile(dirs.home,'MRI','Experimental','data_group','MT','MT_firstlevel');
dirs.reports = fullfile(dirs.home, 'MRI','Experimental','jobreports');
cd(dirs.outputroot)
workdir=fullfile(dirs.outputroot,'twoway_flex_subjint');
if ~exist(char(workdir),'dir'); mkdir(char(workdir)); end

subjects =[1,15,20,23,24,25,27,30,35,38,39,42,43,45,46,47,48,54,57,58,62,63,64,67,70,71,72,73,74,77,78,79,84,85]; %included in all waves

jobfile = '/data/mariet/scripts/VU/soconnect/MRI/soconnect_lt_twoflex_anova_subinter.mat';
load(jobfile)
matlabbatch{1}.spm.stats.factorial_design.dir=cellstr(workdir);
for i=1:numel(subjects)
    subj=subjects(i);
    if subj<10,
        subjname = ['0',num2str(subj)];
    else   subjname = num2str(subj);
    end
    clear funcfiles;
    funcfiles=[];
    for w=1:3
        for c=5:7,
            funcfiles= [funcfiles;spm_select('FPList',[dirs.input,'/'],['SoConnect_',num2str(w),'_',subjname,'_con_000',num2str(c),'.nii'])];
        end
    end  
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans=cellstr(funcfiles);
end

jobfilename = ['twoway_flexanova.mat'];
eval(['save ',dirs.reports,'/',jobfilename,' matlabbatch']);
spm_jobman('initcfg')
spm_jobman('run', matlabbatch);
clear matlabbatch
