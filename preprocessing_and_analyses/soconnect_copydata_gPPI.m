function soconnect_copydata_gPPI(src,tgt,tag)
% _________________________________________________________________________
% Copies data to other folder with prefix
%

cd(src)
prefix = [tag,'_'];

clear filenames; filenames = dir(['*',tag,'*.nii']);
%copy all volumes from ii ech to newdir
for f = 1:numel(filenames)
    clear source; source = fullfile(src,filenames(f).name);
    clear newdir; newdir = fullfile(tgt,[filenames(f).name]);
    unix(['cp ' source ' ' newdir]);
end
