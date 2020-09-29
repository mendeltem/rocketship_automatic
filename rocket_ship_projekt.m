%clear workspace
clear
clc

%every function is shutdown in DEBUG ==1 modus
DEBUG=0;

%choose which functions should rund btw  RUN_B cannot run without RUN_A
%etc.
RUNCALCULATE = 1;
RUN_A        = 1;
RUN_B        = 1;
RUN_D        = 1;
RUN_FULL     = 1;

%rocketship directory
mfilepath = "..ROCKETSHIP/";

addpath(fullfile(mfilepath,'dce'));
addpath(fullfile(mfilepath,'external_programs'));
addpath(fullfile(mfilepath,'external_programs/niftitools'));

%files path
data_path = "data/";


%path to the hematocrit table
xml_data_path = data_path + 'hematocrit_table.xlsx';

data_table = readtable(xml_data_path);

%log
log = data_path + "log.txt";
fid = fopen( log, 'wb' );

if fid==-1
  error('Cannot open file for writing: %s', log);
end



%parameter starts ############################################################
%static variables

%runparametrics
batch_data.fit_type          = 't1_fa_linear_fit';
batch_data.tr                = 60;
batch_data.parameters        = [2 10 20 35];
batch_data.data_order        = 'xyzn';
batch_data.output_basename   = 'T1_map';
batch_data.rsquared          = 0.6000;
batch_data.roi_list          = {};
batch_data.curslice          = 1;
batch_data.odd_echoes        = 0;
batch_data.xy_smooth_size    = 0;
batch_data.preview_image     = [];
batch_data.fit_voxels        = 1;
batch_data.to_do             = 1;

CUR_JOB(1).number_cpus      = 2;
CUR_JOB(1).neuroecon        = 0;
CUR_JOB(1).email            = '';
CUR_JOB(1).batch_data       = batch_data;
CUR_JOB(1).save_log         = 1;
CUR_JOB(1).email_log        = 0;
CUR_JOB(1).batch_log        = 0;
CUR_JOB(1).current_dir      = mfilepath;
CUR_JOB(1).log_name         = strrep(['ROCKETSHIP_MAPPING_'...
    strrep(datestr(now), ' ', '_') '.log'], ':', '-');
CUR_JOB(1).save_txt         = 1;
CUR_JOB(1).submit           = 1;
Name_4DFlip02_File = "4DFlip02.nii";

     
%run dce parameters
fileorder                          = 'xyzt';
aif_rr_type                        = 'aif_roi';
standard_hematocrit                = '0.4';              %standard hematocrit               
tr                                 = '55';             %TR (ms)
fa                                 = '25';             %FA (degree)
relaxivity                         = '5';
snr_filter                         = '5';
injection_time                     =  "-2";
injection_duration                 = 5.;


filevolume            = 1;
noise_pathpick        = 0;
noise_path            = '';
noise_pixelspick      = 1;
noise_pixsize         = "1";
quant                 = 1;
mask_roi              = 1;
mask_aif              = 1;

%parameter for run A
cur_handles.noisefiles             = [];
cur_handles.filevolume             = 1;

cur_handles.saved_results          = '';
filevolume                         = 1;
drift                              = 0;
blood_t1                           = 1000.;
quant                              = 1.;
% Choose default command line output for RUNA

cur_handles.filelist =   [];

%Parallel list for sorting comparison
cur_handles.sortlist =   [];
%Rootname
cur_handles.subjectID =  [];
cur_handles.rootname  = [];
%Hashtable % row is 3D volume, % column referes to 2D slice 
cur_handles.LUT= [];

cur_handles.t1aiffiles = [];
cur_handles.t1roifiles = [];
cur_handles.noisefiles = [];
cur_handles.t1mapfiles = [];
cur_handles.saved_results = '';

cur_handles.LUT         =  1;
cur_handles.noisefiles  =  [];

%parameter for run B

%Analysis interval(0 for all)
start_time                         = 0;      %Start (min)
end_time                           = 6;      %End   (min)
%Injection Duraction
copy_from_a                        = 0;      %check if copy from a button is clicked
standard_start_injection           = 0.5;    %injection Start(min)  manuell               
standard_end_injection             = 1.0;    %injection End(min)  manuell  
time_resolution                    = 6.33;   %time resolution (sec)
fit_aif                            = 0;
import_aif_path                    = '';
timevectpath                       = '';

% Convert to min
transformed_time_resolution = time_resolution / 60;

%parameter for run RUN D
%SELECT DCE MODEL
dce_model.fxr                      = 0;
dce_model.fractal                  = 0;
dce_model.auc                      = 0;
dce_model.nested                   = 0;
dce_model.patlak                   = 1;
dce_model.tissue_uptake            = 0;
dce_model.two_cxm                  = 0;
dce_model.ex_tofts                 = 0;
dce_model.tofts                    = 0;
%smoothing
time_smoothing                     = '';
time_smoothing_window              = 5;
xy_smooth_size                     = 0;
%number of cpus
number_cpus                        = 2;
neuroecon                          = 0;
roi_list                           = '';
%fit voxels
fit_voxels                         = 1;
outputft                           = 1;

%parameter ends############################################################

%get all the cases
string_path =  convertStringsToChars(data_path);
sub_paths = GetSubDirsFirstLevelOnly(data_path);

for i=1:numel(sub_paths)
    
    fprintf(fid, '\n%s\r\n', "time : "+datestr(datetime('now'))); 
    
    close all;
%     
    hematocrit_log_text = '';
    start_injection_log_text = '';
    end_injection_log_text  = '';
       
    disp("i: " + i);
    
	if(RUN_FULL == 0)

        if i == 2
           break
        end
    end
    
    cur_handles.filevolume = uicontrol('style','edit',...
                  'Visible','off',...
                  'unit','pix',...
                  'position',[20 50 260 30],...
                  'fontsize',12,...
                  'Value', 0);

    cur_handles.noisefile = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'Value', 0);

    cur_handles.noisepixels = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'Value',1);

    cur_handles.noisepixsize = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String','');

    cur_handles.quant = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'Value',1);

    cur_handles.noise_path  = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String','');

    cur_handles.roimaskroi    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'Value',1);

    cur_handles.aifmaskroi    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'Value',1);

    cur_handles.fileorder = uibuttongroup('Visible','off',...
                            'Pos',[0 0 .2 1]);

    u0 = uicontrol(cur_handles.fileorder,'Visible','off',...
              'Style','Radio','String','Option 1',...
                   'pos',[10 350 100 30],...
                   'Tag', fileorder);   


    cur_handles.tr    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String', tr);          

    cur_handles.fa    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String',fa);           

    cur_handles.snr_filter    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String', snr_filter);                

    cur_handles.relaxivity    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String', relaxivity);   

    cur_handles.injection_time    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String', injection_time);               

    cur_handles.t1mappath    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String', "");   

    cur_handles.status    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String', "");   
              
    set(cur_handles.filevolume , 'Value' , filevolume);
    set(cur_handles.noisefile  , 'Value' , noise_pathpick);
    set(cur_handles.noise_path,'String', noise_path );
    set(cur_handles.noisepixels, 'Value', noise_pixelspick);
    set(cur_handles.noisepixsize, 'String',  noise_pixsize);      
    set(cur_handles.quant, 'Value',  quant);                    
    set(cur_handles.fileorder,'SelectedObject',u0); 
    set(cur_handles.roimaskroi, 'Value',  mask_roi); 
    set(cur_handles.aifmaskroi, 'Value',  mask_aif); 
    %check if the files are found
    found_4DFlip                      = 0;
    found_T1_map                      = 0;
    found_T1_map_real                 = 0;
    found_moco_file                   = 0;
    Found_Hippocampus                 = 0;
    found_VIF                         = 0;
    found_AIF                         = 0;    
    %current working directory
    current_working_dir = data_path+ sub_paths{i};
    disp("working file: "+current_working_dir);  
    %get the files in the current directory
    files_in_current_working_dir = dir(current_working_dir);
    %current case name
    case_name = sub_paths{i};
    %print("case name: " + case_name);
    %check if the current case name is in the xml hematocrit table
    %and if it exists get the value for hematocrit else take the
    %standard value
    
    %log
    fprintf(fid, '%s\r\n', " "); 
    fprintf(fid, '%s\r\n', "case: "+case_name); 
    
    idx = contains(data_table.ID,{case_name} ) ; 
    summ_of_table = sum(idx);
    
    if (summ_of_table)
        %hematocrit is in table
        
        if (DEBUG==0)
        disp("found in hematocrit in table.");
        end
        Variable = data_table(idx,2);
        hematocrit = Variable{1,1};
        if (DEBUG==0)
        disp("custom hematocrit value is "+ hematocrit);
        end
    else
        if (DEBUG==0)
        disp("hematocrit is not in table");
        end
        hematocrit = standard_hematocrit;
        if (DEBUG==0)
        disp("standard hematocrit value is "+ hematocrit);
        end
    end
    
    %log
    hematocrit_log_text =case_name +  " hematocrit                   "  + " == " + hematocrit;
    
    cur_handles.hematocrit    = uicontrol('style','edit',...
                      'Visible','off',...
                      'unit','pix',...
                      'position',[20 50 260 30],...
                      'fontsize',12,...
                      'String', hematocrit);  
    
    %loop through every files in the current case directory
    for k=1:numel(files_in_current_working_dir)
        %find the 4D Flip file
        if (regexp(files_in_current_working_dir(k).name,"^"+ ...
                Name_4DFlip02_File))  
            %print("Found4DFlip");
            current_file = current_working_dir +'/' + ...
                files_in_current_working_dir(k).name;
            
            CUR_JOB(1).batch_data.file_list = {convertStringsToChars(current_file)};
 
            % disp("RUN Parametrik")
            if (DEBUG==0 & RUNCALCULATE == 1)
                disp("calculateMap ");   
            
            try
                [single_IMG, errormsg] = calculateMap_conf(CUR_JOB);
                
                %check if if error
                if ~isempty(errormsg) 
                    disp_error(errormsg);
                end 
                
                calculate_log = case_name+ " calculsate                       success   ";
            catch ME 
                calculate_log = case_name+ " calculsate                       not successfull";
                
                
                
            end
            
            else
                calculate_log = case_name+ " calculsate didnt try";
            end
            
            fprintf(fid, '%s\r\n', calculate_log); 
            
            flip_log = case_name+ " 4D Flip file                  == "+current_file;
            fprintf(fid, '%s\r\n', flip_log); 

            %check if 4DFlip is found
            found_4DFlip = 1; 
        end
     
    end
    
    if (found_4DFlip == 1)    
        for k=1:numel(files_in_current_working_dir)
             %search for T1 map with with .nii ending
             if (regexp(files_in_current_working_dir(k).name,'^T1_map.*.nii$')...
                 & regexp(files_in_current_working_dir(k).name, '^((?!real).)*$'))
                 
                %convert Strings to Char
                fileName = convertStringsToChars(...
                    files_in_current_working_dir(k).name);
                curdir = convertStringsToChars(current_working_dir);
                %convert .nii to reall
                niiFile=load_untouch_nii(fullfile(curdir,fileName));

                niiFile.img(imag(niiFile.img)~=0)=-1;
                niiFile.img=real(niiFile.img);
                [pathstr,name,ext]=fileparts(fullfile(curdir,fileName));
                niiFile=make_nii(niiFile.img);
                save_nii(niiFile,fullfile(pathstr,[name '_real' ext]));
                %check if T1_map is found
                found_T1_map = 1;   
                
                %log
                FileName = convertStringsToChars(files_in_current_working_dir(k).name);
                T1_map__log_text = case_name+ " T1_map                        == "+curdir + "/" + FileName;
                fprintf(fid, '%s\r\n', T1_map__log_text); 
                

                t1mapfiles = pathstr + "/" + name +  '_real' + ext;
                
                T1_map_real_log_text = case_name+ " T1_map_real                  " + " == " + t1mapfiles;
                cur_handles.t1mapfiles = {convertStringsToChars(t1mapfiles)};
                set(cur_handles.t1mappath, 'String',  t1mapfiles); 
                fprintf(fid, '%s\r\n', T1_map_real_log_text); 
                
                for s=1:numel(files_in_current_working_dir)

                    %Searching for moco file 
                    if (regexp(files_in_current_working_dir(s).name, "moco_") &  regexp(files_in_current_working_dir(s).name, ".gz$"))    

                        %printf(files_in_current_working_dir(k).name);

                        disp("found moco file");

                        [folder, baseFileNameNoExt, extension] = fileparts(files_in_current_working_dir(s).name);
                        filelist = current_working_dir +'/' +files_in_current_working_dir(s).name;
                        rootname    = files_in_current_working_dir(k).name(1:length(files_in_current_working_dir(s).name)-3);

                        cur_handles.sortlist = {baseFileNameNoExt};  
                        cur_handles.subjectID = {baseFileNameNoExt};
                        cur_handles.filelist = {convertStringsToChars(filelist)};
                        cur_handles.rootname = convertStringsToChars(rootname);

                        found_moco_file = 1;

                        %log
                        Moco_log_text = case_name+ " moco_Dyn                     " + " == " + filelist;
                        fprintf(fid, '%s\r\n', Moco_log_text); 
                    end   
                end
                
             end
        end
    end

    if (found_moco_file == 1)    
      for k=1:numel(files_in_current_working_dir)
           %searching for himpocampus
           if (regexp(files_in_current_working_dir(k).name,"^"+ "Hippo") &  ...
                    regexp(files_in_current_working_dir(k).name, ".nii$"))  
                
               disp("found moco hippocampus");

               hippocampusname = files_in_current_working_dir(k).name(1:strlength(files_in_current_working_dir(k).name) - 4 );
               hippocampusname_path = current_working_dir +'/' +files_in_current_working_dir(k).name;
               disp(hippocampusname_path);
               
               t1roifiles = convertStringsToChars (hippocampusname_path);
               
               cur_handles.t1roifiles  =  {t1roifiles};
               
               tr = str2num(get(cur_handles.tr, 'String')); 
               fa = str2num(get(cur_handles.fa, 'String')); 
               hematocrit = str2num(get(cur_handles.hematocrit, 'String')); 
               snr_filter = str2num(get(cur_handles.snr_filter, 'String')); 
               relaxivity = str2num(get(cur_handles.relaxivity, 'String')); 
               injection_time = str2num(get(cur_handles.injection_time, 'String')); 
               
               Found_Hippocampus = 1;
               
               %log
               Hippocampus_log_text = case_name+ " Hippocampus                  " + " == " + t1roifiles;
               fprintf(fid, '%s\r\n', Hippocampus_log_text); 
                       
           for l=1:numel(files_in_current_working_dir)
               if (regexp(files_in_current_working_dir(l).name,"^"+ "VIF|vif") &  ...
                       regexp(files_in_current_working_dir(l).name, ".nii$")) 
                   
                   disp("found moco VIF in " + hippocampusname );
                                      
                   VIF_path = current_working_dir +'/' +files_in_current_working_dir(l).name;
                   disp(VIF_path);
                   found_VIF = 1;

                   hip_vif_name = hippocampusname +"_" +files_in_current_working_dir(l).name;
                   len = strlength(hip_vif_name);
                   hip_vif_name = convertStringsToChars(hip_vif_name);
                   vif_dir_name = hip_vif_name(1:len-4);
                   
                   %create new dir for VIF 
                   new_vif_dir = current_working_dir +'/' +vif_dir_name;
                   if ~exist(new_vif_dir, 'dir')
                     mkdir(new_vif_dir);
                   end   
                   new_vif_dir = convertStringsToChars(new_vif_dir);
                   
                   %check if parameters are right for loadIMGVOL
                   [notemsg, errormsg] = consistencyCHECKRUNA(cur_handles);

                    if ~isempty(errormsg)

                        disp(errormsg)
                        disp_error(errormsg, cur_handles);
                        return;
                    else
                        disp(errormsg)
                        disp_error(notemsg, cur_handles);
                    end
                    
                    % disp("RUN A")
                    
                    if (DEBUG==0 & RUN_A == 1)

                        disp("RUN loadIMGVOL "+ hippocampusname + " VIF ");     
                        try
                            [TUMOR, LV, NOISE, DYNAMIC, dynampath, dynamname, rootname, hdr, res,sliceloc, errormsg] = loadIMGVOL_conf(cur_handles);
                            %check if if error
                            if ~isempty(errormsg) 
                                 disp_error(errormsg);
                            end
                            loadIMGVOL_log = case_name+ " loadIMGVOL    VIF " + hippocampusname + ": success";
                        catch ME 
                            loadIMGVOL_log = case_name+ " loadIMGVOL    VIF " + hippocampusname + ": not successfull " +  ME.message;
                        end
                    else

                        loadIMGVOL_log = case_name    + " loadIMGVOL    VIF "+ hippocampusname  + ": didnt try ";
                    end

                    fprintf(fid, '%s\r\n', loadIMGVOL_log); 
                                        
                    [filepath,XIF_name,ext] = fileparts(VIF_path);
                    
                    XIF_name = "_"+XIF_name+"_";
                    XIF_name = convertStringsToChars(XIF_name);
                    
                    hippocampusname_p = "_"+hippocampusname+"_";
                    hippocampusname_p = convertStringsToChars(hippocampusname_p);

                    if (DEBUG==0 & RUN_A == 1)
                        
                        %run A
                        disp("RUN A_make_R1maps "+ hippocampusname + " VIF ");     

                        try
                            disp("RUN A "+ hippocampusname + " VIF ");     
                            results_a_path = A_make_R1maps_func_conf(DYNAMIC, LV,TUMOR,...
                                NOISE, hdr, res,quant, rootname, new_vif_dir, ...
                                dynamname, aif_rr_type, tr,fa,hematocrit,snr_filter,...
                                relaxivity,injection_time,drift,sliceloc,blood_t1, injection_duration, XIF_name, hippocampusname_p);

                            A_make_R1maps_log = case_name+ " A_make_R1maps VIF "+ hippocampusname +": success   ";
                        catch ME
                            A_make_R1maps_log = case_name+ " A_make_R1maps VIF "+ hippocampusname + ". not  successfull "+ ME.message;
                        end
                    else
                        A_make_R1maps_log = case_name+ " A_make_R1maps VIF "+ hippocampusname + ": didnt try ";
                    end
                    %log
                    fprintf(fid, '%s\r\n', A_make_R1maps_log); 
                    
                    %if copy from a is on
                    if (copy_from_a)
                        a_import = load(results_a_path);
                        a_start_index = a_import.Adata.steady_state_time(2);

                        if isfield(a_import.Adata,'injection_duration')
                            a_end_index = a_import.Adata.injection_duration+a_start_index;
                        else
                            a_end_index = a_start_index+1;
                        end
                        a_start_min = a_start_index * transformed_time_resolution;
                        a_end_min = a_end_index * transformed_time_resolution;
                        %set the injection duration
                        start_injection = a_start_min;
                        end_injection = a_end_min;
                    else
                        start_injection = standard_start_injection;
                        end_injection   = standard_end_injection;
                    end
                    
                    if (DEBUG==0 & RUN_B == 1)
                        
                        %run B
                        disp("RUN B "+ hippocampusname + " VIF ");     
                        
                        try
                            disp("RUN B "+ hippocampusname + " VIF ");

                            results_b_path = B_AIF_fitting_func_conf(results_a_path,start_time,end_time,...
                                start_injection,end_injection,fit_aif,import_aif_path,...
                                transformed_time_resolution, timevectpath, XIF_name,hippocampusname_p);

                            Run_B_log = case_name+ " B_AIF_fitting VIF " +hippocampusname + ": success   ";
                        catch ME
                            Run_B_log = case_name+ " B_AIF_fitting VIF "+ hippocampusname + ": not successfull "+ ME.message;
                        end
                    else

                        Run_B_log = case_name+ " B_AIF_fitting VIF " +hippocampusname     + ": didnt try";
                    end

                    fprintf(fid, '%s\r\n', Run_B_log); 
                       
                    start_injection_log_text = case_name + " start_injection time         " + " == " + start_injection;
                    end_injection_log_text  = case_name +" end_injection time           "  + " == " + end_injection;
                    
                    if (DEBUG==0 & RUN_D == 1)
                        
                        %run A
                        disp("RUN D "+ hippocampusname + " VIF ");    

                        try
                            saved_results = D_fit_voxels_func_conf(results_b_path,dce_model,time_smoothing,...
                                time_smoothing_window,xy_smooth_size,number_cpus,roi_list,...
                                fit_voxels,neuroecon, outputft);

                            Run_D_log = case_name+ " D_fit_voxels  VIF " +hippocampusname+ ": success   ";
                        catch ME 
                            Run_D_log = case_name+ " D_fit_voxels  VIF "+ hippocampusname+ ": not successfull " +  ME.message;
                        end
                    else
                        Run_D_log = case_name+ " D_fit_voxels  VIF " +hippocampusname + ": didnt try " ;
                    end

                    fprintf(fid, '%s\r\n', Run_D_log); 

               end
               if (regexp(files_in_current_working_dir(l).name,"^"+ "AIF|aif") &  ...
                       regexp(files_in_current_working_dir(l).name, ".nii$")) 
                   
                   disp("found moco AIF in " + hippocampusname );
                   
                   AIF_path = current_working_dir +'/' +files_in_current_working_dir(l).name;
                   
                   disp(AIF_path);
                   found_AIF = 1;
                   
                   hip_aif_name = hippocampusname +"_" +files_in_current_working_dir(l).name;
                   len = strlength(hip_aif_name);
                   hip_aif_name = convertStringsToChars(hip_aif_name);
                   aif_dir_name = hip_aif_name(1:len-4);
                   
                   %create new dir for VIF 
                   new_aif_dir = current_working_dir +'/' +aif_dir_name;
                   if ~exist(new_aif_dir, 'dir')
                     mkdir(new_aif_dir);
                   end
                   new_aif_dir = convertStringsToChars(new_aif_dir);

                   t1aiffiles  = current_working_dir +'/' +files_in_current_working_dir(l).name;
                   cur_handles.t1aiffiles = {convertStringsToChars(t1aiffiles)};
                   
                   %check if parameters are right for loadIMGVOL
                   [notemsg, errormsg] = consistencyCHECKRUNA(cur_handles);

                    if ~isempty(errormsg)
                        disp(errormsg)
                        disp_error(errormsg, cur_handles);
                        return;
                    else
                        disp(errormsg)
                        disp_error(notemsg, cur_handles);
                    end
                    
                    % disp("RUN A")
                    if (DEBUG==0 & RUN_A == 1)
                        disp("RUN loadIMGVOL "+ hippocampusname + " AIF ");     
                        try
                            [TUMOR, LV, NOISE, DYNAMIC, dynampath, dynamname, rootname, hdr, res,sliceloc, errormsg] = loadIMGVOL_conf(cur_handles);
                            
                            %check if if error
                            if ~isempty(errormsg) 
                                 disp_error(errormsg);
                            end
                            loadIMGVOL_log = case_name+ " loadIMGVOL    AIF " + hippocampusname+ ": success   ";
                        catch ME 
                            loadIMGVOL_log = case_name+ " loadIMGVOL    AIF " + hippocampusname+ ": not successfull " +  ME.message  ;
                        end
                    else
                        loadIMGVOL_log = case_name+ " loadIMGVOL    AIF "+ hippocampusname+ ": didnt try ";
                    end
                    
                                        
                   [filepath,XIF_name,ext] = fileparts(AIF_path); 
                    XIF_name = "_"+XIF_name+"_";
                    XIF_name = convertStringsToChars(XIF_name);
                    
                   hippocampusname_p = "_"+hippocampusname+"_";
                   hippocampusname_p = convertStringsToChars(hippocampusname_p);
                   

                    fprintf(fid, '%s\r\n', loadIMGVOL_log); 
                    if (DEBUG==0 & RUN_A == 1)
                        %run A
                        disp("RUN A_make_R1maps "+ hippocampusname + " AIF ");     

                        try
                            disp("RUN A "+ hippocampusname + " AIF ");     
                            results_a_path = A_make_R1maps_func_conf(DYNAMIC, LV,TUMOR,...
                                NOISE, hdr, res,quant, rootname, new_aif_dir, ...
                                dynamname, aif_rr_type, tr,fa,hematocrit,snr_filter,...
                                relaxivity,injection_time,drift,sliceloc,blood_t1, injection_duration, XIF_name, hippocampusname_p);

                            A_make_R1maps_log = case_name+ " A_make_R1maps AIF "+ hippocampusname+ ": success   ";
                        catch ME 
                            A_make_R1maps_log = case_name+ " A_make_R1maps AIF "+ hippocampusname+ ": not successfull " +  ME.message;
                        end
                    else
                        A_make_R1maps_log = case_name+ " A_make_R1maps AIF "+ hippocampusname + ": didnt try ";
                    end

                    fprintf(fid, '%s\r\n', A_make_R1maps_log); 
                    
                    %if copy from a is on
                    if (copy_from_a)
                        a_import = load(results_a_path);
                        a_start_index = a_import.Adata.steady_state_time(2);

                        if isfield(a_import.Adata,'injection_duration')
                            a_end_index = a_import.Adata.injection_duration+a_start_index;
                        else
                            a_end_index = a_start_index+1;
                        end
                        a_start_min = a_start_index * transformed_time_resolution;
                        a_end_min = a_end_index * transformed_time_resolution;
                        %set the injection duration
                        start_injection = a_start_min;
                        end_injection = a_end_min;
                    else
                        start_injection = standard_start_injection;
                        end_injection   = standard_end_injection;
                    end
                
                    if (DEBUG==0  & RUN_B == 1)
                        
                        %run B
                        disp("RUN B "+ hippocampusname + " AIF ");     
                           
                        try
                            disp("RUN B "+ hippocampusname + " AIF ");

                            results_b_path = B_AIF_fitting_func_conf(results_a_path,start_time,end_time,...
                                start_injection,end_injection,fit_aif,import_aif_path,...
                                transformed_time_resolution, timevectpath, XIF_name,hippocampusname_p);
                            


                            Run_B_log = case_name+ " B_AIF_fitting AIF " +hippocampusname+ ": success   ";
                        catch ME 
                            Run_B_log = case_name+ " B_AIF_fitting AIF "+ hippocampusname+ ": not successfull " +  ME.message;
                        end
                    else
                        Run_B_log = case_name+ " B_AIF_fitting AIF " +hippocampusname + ": didnt try ";
                    end

                    fprintf(fid, '%s\r\n', Run_B_log); 
                    
                    start_injection_log_text = case_name + " start_injection time         " + " == " + start_injection;
                    end_injection_log_text  = case_name +" end_injection time           "  + " == " + end_injection; 

                    if (DEBUG==0 & RUN_D == 1)
                        
                        %run D
                        disp("RUN D "+ hippocampusname + " AIF ");    

                        try     
                            saved_results = D_fit_voxels_func_conf(results_b_path,dce_model,time_smoothing,...
                                time_smoothing_window,xy_smooth_size,number_cpus,roi_list,...
                                fit_voxels,neuroecon, outputft);

                            Run_D_log = case_name+ " D_fit_voxels  AIF " +hippocampusname + ": success   ";
                        catch ME 
                            Run_D_log = case_name+ " D_fit_voxels  AIF "+ hippocampusname + ": not successfull " +  ME.message ;
                        end

                    else
                        Run_D_log = case_name+ " D_fit_voxels  AIF " +hippocampusname + ": didnt try ";
                    end

                    fprintf(fid, '%s\r\n', Run_D_log); 
               end
           end
           end
       end
    end
    if (found_VIF == 1)
        VIF_path_log_text = case_name+ " VIF                          " + " == " + VIF_path;
        fprintf(fid, '%s\r\n', VIF_path_log_text); 
    end
    if (found_AIF == 1)
        AIF_path_log_text = case_name+ " AIF                          " + " == " + AIF_path;
        fprintf(fid, '%s\r\n', AIF_path_log_text); 
    end  
    %logs
    fprintf(fid, '%s\r\n', hematocrit_log_text);
    fprintf(fid, '%s\r\n', start_injection_log_text);
    fprintf(fid, '%s\r\n', end_injection_log_text);  
                 
    if (found_4DFlip == 0)
       disp('No found_4DFlip File found in' + current_working_dir)  
       log_text = "No found_4DFlip File found in" + current_working_dir;
       fprintf(fid, '%s\r\n', log_text);
    end   
    
    if (found_T1_map == 0 & found_4DFlip == 1)
       disp('No found_T1_map File found in' + current_working_dir)
       log_text = "No found_T1_map File found in" + current_working_dir;
       fprintf(fid, '%s\r\n', log_text);
    end
    
    if (found_moco_file == 0 & found_T1_map == 1)
       disp('No found_moco_file File found in' + current_working_dir)
       log_text = "No found_moco_file File found in" + current_working_dir;
       fprintf(fid, '%s\r\n', log_text);
    end
    
    if (Found_Hippocampus == 0 & found_moco_file == 1)
       disp('No Hippocampus File found in' + current_working_dir)
       log_text = "No Hippocampus File found in" + current_working_dir;
       fprintf(fid, '%s\r\n', log_text);
    end
    
    if (found_VIF == 0  & Found_Hippocampus == 1)
       disp('No found_VIF File found in' + current_working_dir)
       log_text = "No found_VIF File found in" + current_working_dir;
       fprintf(fid, '%s\r\n', log_text);
    end
    
    if (found_AIF == 0 & Found_Hippocampus == 1)
       disp('No found_AIF File found in' + current_working_dir)
       log_text = "No found_AIF File found in" + current_working_dir;
       fprintf(fid, '%s\r\n', log_text);
    end
    close all;
end
close all;
%close log
fclose(fid);


 function printf(var)
    disp("Value: "+ var);
    disp("class: "+ class(var));
    
 end
 

function out = getVarName(var)
    out = inputname(1);
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