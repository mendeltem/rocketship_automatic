DEBUG = 0;

setenv('PATH', [getenv('PATH') ':/usr/local/fsl/']);
main_path = "/home/villrink/AG-CSB_NeuroRad/villrink/rocketship_data/";


%main_path  = "/home/temuuleu/CSB_NeuroRad/temuuleu/Rocket_test/";
Ktrans_name = 'Ktrans.xlsm';

sub_paths = GetSubDirsFirstLevelOnly(main_path);

working_paths = main_path + sub_paths;

%disp(working_paths)
case_id_ = [];
SD_L_AIF_   = [];
mean_L_AIF_   = [];
p25_L_AIF_   = [];
p50_L_AIF_  = [];
p75_L_AIF_  = [];

SD_R_AIF_    = [];
mean_R_AIF_  = [];
p25_R_AIF_   = [];
p50_R_AIF_   = [];
p75_R_AIF_   = [];

SD_L_VIF_    = [];
mean_L_VIF_  = [];
p25_L_VIF_   = [];
p50_L_VIF_   = [];
p75_L_VIF_   = [];

SD_R_VIF_    = [];
mean_R_VIF_  = [];
p25_R_VIF_   = [];
p50_R_VIF_   = [];
p75_R_VIF_   = [];

for i=1:numel(working_paths)
    
    case_AIF_L = 0;
    case_AIF_R = 0;
    case_VIF_L = 0;
    case_VIF_R = 0;

   %files_in_current_working_dir = dir(working_paths{i});
%    if i == 11
%      break
%    end
%      
   m_path = working_paths{i};
   
   subsubfolders = GetSubDirsFirstLevelOnly(working_paths{i});
   
   case_number =  sub_paths(i);
   
   disp("Case ID: " + case_number)
   
   if (DEBUG)
    disp(working_paths{i});
    disp("casenumber " + case_number)
    disp("subfolders:" + subsubfolders)
   end
   
   for o=1:numel(subsubfolders)
       
       s_path = subsubfolders{o}; 
       ms_path = m_path + "/" + s_path;
       files = dir(ms_path);
       
       for j=1:numel(files)
            
           if (regexp(files(j).name, "Ktrans.nii$") )  
              
               %disp(files(j).folder)
               Ktrains_file_path = ms_path + "/" + files(j).name;
               
               case_type =  s_path;
               
               if (DEBUG)
               
               disp("casenumber " + case_number)
               disp("case type " + case_type) 
               
               end
               
               if (regexp( case_type,'AIF')  & regexp( case_type,'L') )
                    
                    command = "fslstats " + Ktrains_file_path + " -M";
                    [s, mean_L_AIF_VAR]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -S";
                    [s, SD_L_AIF] = system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 25";
                    [s, p25_L_AIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 50";
                    [s, p50_L_AIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 75";
                    [s, p75_L_AIF]= system(command);

                    case_AIF_L = 1;
                    
                end
                
                if (regexp( case_type,'AIF')  & regexp( case_type,'R') )
                    
                    command = "fslstats " + Ktrains_file_path + " -M";
                    [s, mean_R_AIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -S";
                    [s, SD_R_AIF] = system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 25";
                    [s, p25_R_AIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 50";
                    [s, p50_R_AIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 75";
                    [s, p75_R_AIF]= system(command);

                    case_AIF_R = 1;
                    
                end               
                                
                if (regexp( case_type,'VIF')  & regexp( case_type,'L') )
                    
                    command = "fslstats " + Ktrains_file_path + " -M";
                    [s, mean_L_VIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -S";
                    [s, SD_L_VIF] = system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 25";
                    [s, p25_L_VIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 50";
                    [s, p50_L_VIF]= system(command);

                    command = "fslstats " + Ktrains_file_path + " -P 75";
                    [s, p75_L_VIF]= system(command);

                    case_VIF_L = 1;
                    
                end
                
                if (regexp( case_type,'VIF')  & regexp( case_type,'R') )
                    
                    command = "fslstats " + Ktrains_file_path + " -M";
                    [s, mean_R_VIF]= system(command);
                    %disp(Ktrains_file_path)

                    command = "fslstats " + Ktrains_file_path + " -S";
                    [s, SD_R_VIF] = system(command);
                    %disp(Ktrains_file_path)

                    command = "fslstats " + Ktrains_file_path + " -P 25";
                    [s, p25_R_VIF]= system(command);
                    %disp(Ktrains_file_path)

                    command = "fslstats " + Ktrains_file_path + " -P 50";
                    [s, p50_R_VIF]= system(command);
                    %disp(Ktrains_file_path)

                    command = "fslstats " + Ktrains_file_path + " -P 75";
                    
                    %disp(Ktrains_file_path)
                    [s, p75_R_VIF]= system(command);
                    
                    case_VIF_R = 1;
                    
                 end   
           end
       end
   end
   
   case_id_ = [ [case_number]  ; case_id_];

   if (case_AIF_L == 1)

        mean_L_AIF_= [mean_L_AIF_VAR ; mean_L_AIF_];
        SD_L_AIF_  = [SD_L_AIF ; SD_L_AIF_];
        p25_L_AIF_ = [p25_L_AIF ; p25_L_AIF_];
        p50_L_AIF_ = [p50_L_AIF ; p50_L_AIF_];
        p75_L_AIF_ = [p75_L_AIF ; p75_L_AIF_];

   else
        mean_L_AIF_= ["-" ; mean_L_AIF_];
        SD_L_AIF_  = ["-" ; SD_L_AIF_];
        p25_L_AIF_ = ["-" ; p25_L_AIF_];
        p50_L_AIF_ = ["-" ; p50_L_AIF_];
        p75_L_AIF_ = ["-" ; p75_L_AIF_];

   end
   
   
   if (case_AIF_R == 1)

        mean_R_AIF_ = [mean_R_AIF ; mean_R_AIF_];
        SD_R_AIF_  = [SD_R_AIF ; SD_R_AIF_];
        p25_R_AIF_ = [p25_R_AIF ; p25_R_AIF_];
        p50_R_AIF_ = [p50_R_AIF ; p50_R_AIF_];
        p75_R_AIF_ = [p75_R_AIF ; p75_R_AIF_];
        
        

   else
        mean_R_AIF_= ["-" ; mean_R_AIF_];
        SD_R_AIF_  = ["-" ; SD_R_AIF_];
        p25_R_AIF_ = ["-" ; p25_R_AIF_];
        p50_R_AIF_ = ["-" ; p50_R_AIF_];
        p75_R_AIF_ = ["-" ; p75_R_AIF_];

   end
   
   if (case_VIF_R == 1)

        mean_R_VIF_ = [mean_R_VIF ; mean_R_VIF_];
        SD_R_VIF_   = [SD_R_VIF ; SD_R_VIF_ ];
        p25_R_VIF_  = [p25_R_VIF ; p25_R_VIF_ ];
        p50_R_VIF_  = [p50_R_VIF ; p50_R_VIF_ ];
        p75_R_VIF_  = [p75_R_VIF ; p75_R_VIF_ ];

   else
        mean_R_VIF_ = ["-" ; mean_R_VIF_ ];
        SD_R_VIF_   = ["-" ; SD_R_VIF_ ];
        p25_R_VIF_  = ["-" ; p25_R_VIF_ ];
        p50_R_VIF_  = ["-" ; p50_R_VIF_ ];
        p75_R_VIF_  = ["-" ; p75_R_VIF_ ];

   end
   
   if (case_VIF_L == 1)

        mean_L_VIF_ = [mean_L_VIF ; mean_L_VIF_ ];
        SD_L_VIF_   = [SD_L_VIF ; SD_L_VIF_ ];
        p25_L_VIF_  = [p25_L_VIF ; p25_L_VIF_ ];
        p50_L_VIF_  = [p50_L_VIF ; p50_L_VIF_ ];
        p75_L_VIF_  = [p75_L_VIF ; p75_L_VIF_ ];

   else
        mean_L_VIF_ = ["-" ; mean_L_VIF_ ];
        SD_L_VIF_   = ["-" ; SD_L_VIF_ ];
        p25_L_VIF_  = ["-" ; p25_L_VIF_ ];
        p50_L_VIF_  = ["-" ; p50_L_VIF_ ];
        p75_L_VIF_  = ["-" ; p75_L_VIF_ ];

   end
   
end

if (DEBUG)

    disp(length(case_id_))
    disp(length(SD_L_AIF_))
    disp(length(p25_L_AIF_))
    disp(length(p50_L_AIF_))
    disp(length(p75_L_AIF_))


    disp(length(mean_R_AIF_))
    disp(length(SD_R_AIF_))
    disp(length(p25_R_AIF_))
    disp(length(p50_R_AIF_))
    disp(length(p75_R_AIF_))


    disp(length(mean_R_VIF_))
    disp(length(SD_R_VIF_))
    disp(length(p25_R_VIF_))
    disp(length(p50_R_VIF_))
    disp(length(p75_R_VIF_))

    disp(length(mean_L_VIF_))
    disp(length(SD_L_VIF_))
    disp(length(p25_L_VIF_))
    disp(length(p50_L_VIF_))
    disp(length(p75_L_VIF_))

end


%Create a Table for XML with all the fslstats Values
Table = table( case_id_, mean_L_AIF_, SD_L_AIF_, p25_L_AIF_, p50_L_AIF_,p75_L_AIF_,...
    mean_R_AIF_, SD_R_AIF_, p25_R_AIF_, p50_R_AIF_,p75_R_AIF_,...
    mean_L_VIF_, SD_L_VIF_, p25_L_VIF_, p50_L_VIF_, p75_L_VIF_, ...
    mean_R_VIF_, SD_R_VIF_, p25_R_VIF_, p50_R_VIF_,p75_R_VIF_);

xml_table =  main_path + Ktrans_name;
disp("xml_table: "+xml_table)

%write a xml table with KTRANS Values
writetable(Table,xml_table,'WriteRowNames',true)  

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