function [overlaped_points] = get_overlaped_points(points1,points2)
        
    % points best pairing is found with some minimal distance limit

    z_scale_factor = 2; % z dimension have larger impact to distance
    distance_limit = 20; % distance limit for overlap
    

    points1(:,3) = points1(:,3) * z_scale_factor;
    points2(:,3) = points2(:,3) * z_scale_factor;


    
    
    D = pdist2(points1,points2);
    D(D>distance_limit)=Inf;
    
    
    [assignment,cost]=munkres(D);
    
    overlaped_points = [];
    for ass_ind = 1:length(assignment)
        ass = assignment(ass_ind);
        if ass ==0
            continue; 
        end
        
        new_point = int32((points1(ass_ind,:) + points2(ass,:))/2);
        
        new_point(3) = int32(round(new_point(3)/z_scale_factor));
        
        
        overlaped_points = [overlaped_points;new_point];
    
    end
    
    overlaped_points = double(overlaped_points);

end