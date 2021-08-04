
function [onset_self, onset_sim, onset_dis, onset_cont, onset_cues]=soconnect_onsets_MT(logfile)

    fid1=fopen(logfile);
    data_mentalizing=textscan(fid1,'%n%s%n%n%n%n%n%n%[^\n]','Headerlines',2);
    clear fid1
  
    code=data_mentalizing{2};
    conditie=data_mentalizing{3};
    valence=data_mentalizing{4};
    onset=data_mentalizing{5};
    resp=data_mentalizing{7};
    rt=data_mentalizing{8};
        
    c= strmatch('cue', code, 'exact');
    se=find(conditie==1);
    si=find(conditie==2);
    di=find(conditie==3);
    ct=find(conditie==4);
    
    index=[1,6,11,16,21,26,31,36];
    for i=1:size(index,2)
    se_1(i,1)=se(index(i));
    si_1(i,1)=si(index(i));
    di_1(i,1)=di(index(i));
    ct_1(i,1)=ct(index(i));
    end;
    
    
    onset_cues=onset(c)/1000;
    onset_self=onset(se_1)/1000;
    onset_sim=onset(si_1)/1000;
    onset_dis=onset(di_1)/1000;
    onset_cont=onset(ct_1)/1000;
        
    clear c se si di ct se_1 si_1 di_1 i ct_1 data_mentalizing code conditie onset resp rt logfile  