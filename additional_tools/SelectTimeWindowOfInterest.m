
function [Config, PathExt] = SelectTimeWindowOfInterest()

    Config.Pre          = [];                                           
    Config.Pre.toilim   = [-0.5 -0.3];
    Config.Post         = [];
    Config.Post.toilim  = [0.4 0.6]; 

    Config.TimeWindow_ms = [];
    Config.TimeWindow_ms = (Config.Post.toilim*1000);
    Config.TimeWindow_string =  strcat(num2str(Config.TimeWindow_ms(1)), '_', num2str(Config.TimeWindow_ms(2)), 'ms');

    % PathExt = strcat( '\', num2str( Config.TimeWindow_ms(1)), '_', num2str( Config.TimeWindow_ms(2)), 'ms'); 
    PathExt = Config.TimeWindow_string;

end