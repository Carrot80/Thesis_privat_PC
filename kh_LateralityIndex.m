%
function [LI] = kh_LateralityIndex (ConfigFile, Stats_left, Stats_right, Path)

% make frequency directory if not exists yet:
    DirFreqName = strcat (Path.LI, '\', ConfigFile.name);
    [state] = mkdirIfNecessary( DirFreqName );
    

    StatsFileLeft = load ( strcat (Path.Statistics, '\', ConfigFile.name, '\', Stats_left) );
    StatsFileRight = load ( strcat (Path.Statistics, '\', ConfigFile.name, '\', Stats_right) );

    StatsFileLeft = StatsFileLeft.(Stats_left) ;
    StatsFileRight = StatsFileRight.(Stats_right) ;
    
  % significant t-values left :
        SignStat_left        = StatsFileLeft;
        sign_vert_left       = find( squeeze( StatsFileLeft.stat) <= StatsFileLeft.critval(1)) ;
        sign_values_left     = squeeze(StatsFileLeft.stat(sign_vert_left)) ;
        sign_values_left_abs = abs(sign_values_left) ;
        
        
  %  significant t-values right :
        SignStat_right          = StatsFileRight ;
        sign_vert_right         = find( squeeze( StatsFileRight.stat) <= StatsFileRight.critval(1)) ;
        sign_values_right       = squeeze(StatsFileRight.stat(sign_vert_right)) ;
        sign_values_right_abs   = abs(sign_values_right) ;
        
        
        LI_Value      = (sum(sign_values_left_abs) - sum(sign_values_right_abs)) ./ (sum(sign_values_left_abs) + sum(sign_values_right_abs));
        NameROI       = StatsFileLeft.name(1:length(StatsFileLeft.name)-5); 
        
        LI.(NameROI) = struct ('Frequency', ConfigFile.name, 'ROI', NameROI, 'LI_Value', LI_Value, 'SignVoxelsLeft', length(sign_values_left_abs), 'SignVoxelsRight', length(sign_values_right_abs) ); 
        
        
        if LI_Value == NaN
            
            LI.(NameROI).warning = 'no Voxel survived theshold';
            
        end
        
        fn_LI = strcat(Path.LI, '\', ConfigFile.name, '\', 'LI', '_', NameROI );
        
        if ~exist ( fn_LI, 'file')
            save (fn_LI, 'LI');
            
%         else
%             
%             save (fn_LI, 'LI', '-append');
%         
        end
        
end