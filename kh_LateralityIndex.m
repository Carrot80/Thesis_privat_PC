%
function [LI_allROIs] = kh_LateralityIndex (ResultStats_left, ResultStats_right, PathLI)

  % signifikante t-Werte links :
        SignStat_left = ResultStats_left;
        sign_vert_left = find( squeeze( ResultStats_left.stat) <= ResultStats_left.critval(1));
        sign_values_left =  squeeze(ResultStats_left.stat(sign_vert_left));
        sign_values_left_abs = abs(sign_values_left)
        
        
  %  signifikante t-Werte rechts :
        SignStat_right = ResultStats_right;
        sign_vert_right = find( squeeze( ResultStats_right.stat) <= ResultStats_right.critval(1));
        sign_values_right =  squeeze(ResultStats_right.stat(sign_vert_right));
        sign_values_right_abs = abs(sign_values_right)
        
        LI_allROIs = (sum(sign_values_left_abs) - sum(sign_values_right_abs)) ./ (sum(sign_values_left_abs) + sum(sign_values_right_abs));
        File_LI_allROIs = strcat(PathLI, '\', 'LI_allROIs');
        save (File_LI_allROIs, 'LI_allROIs');
        
end