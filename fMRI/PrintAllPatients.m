function PrintAllPatients 
    
    VolunteerFolder = 'C:\Kirsten\DatenDoktorarbeit\Kontrollen\';
    VolunteerList = dir( VolunteerFolder );
    
    for i = 1 : size (VolunteerList)
        if ( 0 == strcmp( VolunteerList(i,1).name, '.') && 0 == strcmp( VolunteerList(i,1).name, '..'))
            PatientPath = strcat(VolunteerFolder, VolunteerList(i,1).name) ;
            PatientName = VolunteerList(i,1).name  ;
            kh_display_and_print( PatientPath, PatientName  );
        end
    end
end
