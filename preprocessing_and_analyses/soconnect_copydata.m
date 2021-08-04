function soconnect_copydata(src,tgt,tag)
% _________________________________________________________________________
% Copies data to other folder with prefix
%

cd(src)
prefix = [tag,'_'];

clear filenames; filenames = dir(['*.nii']);
%copy all volumes from ii ech to newdir
for f = 1:numel(filenames)
    clear source; source = fullfile(src,filenames(f).name);
    clear newdir; newdir = fullfile(tgt,[prefix,filenames(f).name]);
    unix(['cp ' source ' ' newdir]);
end
clear filenames; filenames = dir(['*.img']);
%copy all volumes from ii ech to newdir
for f = 1:numel(filenames)
    clear source; source = fullfile(src,filenames(f).name);
    clear newdir; newdir = fullfile(tgt,[prefix,filenames(f).name]);
    unix(['cp ' source ' ' newdir]);
end
clear filenames; filenames = dir(['*.hdr']);
%copy all volumes from ii ech to newdir
for f = 1:numel(filenames)
    clear source; source = fullfile(src,filenames(f).name);
    clear newdir; newdir = fullfile(tgt,[prefix,filenames(f).name]);
    unix(['cp ' source ' ' newdir]);
end

