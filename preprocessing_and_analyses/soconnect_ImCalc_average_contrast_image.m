function soconnect_ImCalc_average_contrast_image
%%uses ImCalc toolbox to create average contrast images over waves

dirs.home = fullfile('/data','mariet','SoConnect','DATA_lt');
dirs.scripts=  fullfile('/data','mariet','SoConnect','scripts','MRI');
dirs.root = fullfile(dirs.home,'MRI','Experimental', 'data_group', 'MT');

cd(dirs.root)

dirs.input = fullfile(dirs.root,'MT_firstlevel', 'allwaves');
dirs.output=  fullfile(dirs.root, 'MT_firstlevel','allwaves','mean_waves');
dirs.reports = fullfile(dirs.home, 'MRI','Experimental','jobreports');
if ~exist(char(dirs.output),'dir'); mkdir(char(dirs.output)); end
subjects =[1,15,20,23,24,25,27,30,35,38,39,42,43,45,46,47,48,54,57,58,62,63,64,67,70,71,72,73,74,77,78,79,84,85]; %included  in all waves
jobfile = '/data/mariet/scripts/VU/soconnect/MRI/soconnect_imCalc_averagecontrast.mat';
contrasts={'_con_0005', '_con_0006', '_con_0007'}; %%self vs control; similiar vs control; dissimilar vs control
for c=1:3
     clear con; con=contrasts{c};
    for i=1:numel(subjects)
        load(jobfile)
        subj=subjects(i);
        if subj<10,
            subjname = ['0',num2str(subj)];
        else   subjname = num2str(subj);
        end
        clear funcfiles;
        funcfiles=[];
        for w=1:3
            funcfiles= [funcfiles;spm_select('FPList',[dirs.input,'/'],['SoConnect_',num2str(w),'_',subjname, con,'.nii'])];
         end
          
        matlabbatch{1}.spm.util.imcalc.input=cellstr(funcfiles);
        matlabbatch{1}.spm.util.imcalc.outdir=cellstr(dirs.output);  
        matlabbatch{1}.spm.util.imcalc.output=['SoConnect_',subjname,'_mean',con];
        
        jobfilename = [subjname,con,'_ImCalc_average.mat'];
        eval(['save ',dirs.reports,'/',jobfilename,' matlabbatch']);
        spm_jobman('initcfg')
        spm_jobman('run', matlabbatch);
        clear matlabbatch subj
    end
end
