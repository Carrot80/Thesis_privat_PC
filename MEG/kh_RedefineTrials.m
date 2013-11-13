%% Redefine trials:

function kh_RedefineTrials( ConfigFile, Path)

    % Check, if data is already avaliable
    
     FileName = strcat(Path.DataTimeOfInterest, '\', 'Data', '.mat');
         
        if exist( FileName, 'file' )
            return;
        end


    load (strcat(Path.Preprocessing, '\', 'CleanData', '.mat'));


    % select time window of interest                    
    DataPre         = ft_redefinetrial(ConfigFile.Pre, CleanData);
    DataPst         = ft_redefinetrial(ConfigFile.Post, CleanData);


    % trials sind unterschiedlich lang, deshalb alle kürzer als gewählte ...
    % samples herauswerfen

    maxlength_DataPst = zeros(1,length(DataPst.time));
    
    for i=1:length(DataPst.time)
        maxlength_DataPst(1,i)=length(DataPst.time{1,i});
    end

    for i=1:length(DataPst.time)
        int(1,i)=length(DataPst.time{1,i})<max(maxlength_DataPst);
    end

    find_int                        = find(int==1);

    DataPst.time(:,find_int)        = [];
    DataPst.trial(:,find_int)       = [];
    DataPst.sampleinfo(find_int,:)  = [];

    % the same for DataPre:

    maxlength_DataPre=zeros(1,length(DataPre.time));
    
    for i=1:length(DataPre.time)
        maxlength_DataPre(1,i)=length(DataPre.time{1,i});
    end

    for i=1:length(DataPre.time)
        int_DataPre(1,i)=length(DataPre.time{1,i})<max(maxlength_DataPre);
    end

    find_int_DataPre=find(int_DataPre==1)

    DataPre.time(:,find_int_DataPre)        = [];
    DataPre.trial(:,find_int_DataPre)       = [];
    DataPre.sampleinfo(find_int_DataPre,:)  = [];


    % compute a single data structure with both conditions, and compute the frequency domain 

    DataAll = ft_appenddata([], DataPre, DataPst);
    
    Data = struct('DataPre', DataPre, 'DataPst', DataPst, 'DataAll', DataAll, 'TimeWindow', ConfigFile.TimeWindow_string);

    File_Data    = strcat (Path.DataTimeOfInterest, '\', 'Data', '.mat');
    save (File_Data, 'Data')
    

end
