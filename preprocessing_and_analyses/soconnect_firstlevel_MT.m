function soconnect_firstlevel_MT(whattodo, workdir,logfile,funcfiles,rpfile,symlinkdir_stat,subjname)
global dirs subj info
clear matlabbatch jobfilename 
% calculate onsets of the relevant conditions
[onset_self, onset_sim, onset_dis, onset_cont, onset_cues]=soconnect_onsets_MT(logfile);


jobfile = fullfile(dirs.scripts,['soconnect_firstlevel_batch_MT.mat']);
load (jobfile)

matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(workdir);
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = funcfiles;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = onset_self;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = onset_sim;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = onset_dis;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = onset_cont;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = onset_cues;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = rpfile;


jobfilename = [whattodo,'_',subjname,'.mat'];
eval(['save ',dirs.reports,'/',jobfilename,' matlabbatch']);
%job = [dirs.reports,'/',jobfilename];
spm_jobman('initcfg')
spm_jobman('run', matlabbatch);

soconnect_copydata(workdir,symlinkdir_stat,subjname);