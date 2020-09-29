setenv('PATH', [getenv('PATH') ':/usr/local/fsl/']);

% main_path = "/home/temuuleu/CSB_NeuroRad/temuuleu/test_data/120-601-397/";
main_path = uigetdir('/home/temuuleu/CSB_NeuroRad/temuuleu/');
main_path = convertCharsToStrings(main_path);
main_path = main_path + "/";
files = dir(main_path);

for i=1:numel(files)
    
    disp(files(i).name);

    if (regexp(files(i).name, "Ktrans.nii$") ) 
        
        ktransfile = main_path + files(i).name;
        
        disp(ktransfile);
        
        mean_command = "fslstats " + ktransfile + " -M";
        sd_command = "fslstats " + ktransfile + " -S";
        P25_command = "fslstats " + ktransfile + " -P 25";
        P50_command = "fslstats " + ktransfile + " -P 50";
        P75_command = "fslstats " + ktransfile + " -P 75";
        
        [s, mean]= system(mean_command);
        [s, sd]= system(sd_command);
        [s, p25]= system(P25_command);
        [s, p50]= system(P50_command);
        [s, p75]= system(P75_command);
        
        disp("Mean:  " + mean )
        disp("SD:    " + sd ) 
        disp("p25:   " + p25 )
        disp("p50:   " + p50 )   
        disp("p75:    " + p75 )

    end
end












 function [subDirsNames] = GetSubDirsFirstLevelOnly(path)
    %get all  subfolders and save it in a list
    files = dir(path);
    files(ismember( {files.name}, {'.', '..'})) = [];
    dirFlags = [files.isdir];
    subFolders = files(dirFlags);
    
    subDirsNames = cell(1, numel(subFolders) - 2);
    
    for k = 1 : length(subFolders)
        %fprintf('Sub folder #%d = %s\n', k, subFolders(k).name);
        
        subDirsNames{k} = subFolders(k).name;
    end  
    
 end