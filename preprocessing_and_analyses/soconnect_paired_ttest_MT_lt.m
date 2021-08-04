function soconnect_paired_ttest_MT_lt(workdir,cond_1, cond_2)
%%filler script paired t-test whole brain analyses averaged over waves

clear matlabbatch jobfilename 
addpath(genpath('/data/mariet/programmes/SPM/spm12/'))
dirs.home = fullfile('/data','mariet','SoConnect','DATA_lt');
dirs.scripts=  fullfile('/data','mariet','scripts', 'VU','soconnect','MRI');
dirs.root = fullfile(dirs.home,'MRI');
dirs.input = fullfile(dirs.root,'Experimental', 'data_group', 'MT','MT_firstlevel','allwaves','mean_waves'); %uses the contrast images averages over waves
dirs.outputroot = fullfile(dirs.home,'MRI','Experimental','data_group','MT','whole_brain', 'paired_ttests', 'meanwaves');
workdir=fullfile(dirs.outputroot,'mean_SimCT_DisCT');
if ~exist(char(workdir),'dir'); mkdir(char(workdir)); end

jobfile = fullfile(dirs.scripts,['soconnect_paired_ttest_batch_lt.mat']);
load (jobfile);

matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(workdir);
subjects =[1,15,20,23,24,25,27,30,35,38,39,42,43,45,46,47,48,54,57,58,62,63,64,67,70,71,72,73,74,77,78,79,84,85]; %included in all waves
for  i=1:numel(subjects)
    subj=subjects(i);
    if subj<10,
        subjname = ['0',num2str(subj)];
    else   subjname = num2str(subj);
    end
    clear scan_1 scan_2 scans    
        scan_1=spm_select('FPList',[dirs.input,'/'],['SoConnect_',subjname,'_mean_con_0006.nii']);
        scan_2=spm_select('FPList',[dirs.input,'/'],['SoConnect_',subjname,'_mean_con_0007.nii']);
        scans=[scan_1;scan_2];
        scans=cellstr(scans);
        matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(i).scans=scans;
end

        

jobfilename = ['paired_t_test.mat'];
eval(['save ',workdir,'/',jobfilename,' matlabbatch']);
spm_jobman('initcfg')
spm_jobman('run', matlabbatch);
