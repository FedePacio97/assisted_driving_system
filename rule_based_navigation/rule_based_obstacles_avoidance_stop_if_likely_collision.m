% Get input from Lidar
angles = out.angles.Data(:,:,300);
ranges = out.ranges.Data(:,:,300);
%Get input from current linear speed
v = 5; %(m/s)

scan = lidarScan(ranges,angles);

plot(scan)

% consider a tollerance
collision_cone = deg2rad(4);

%Get indexes of elements related to the collision cone
collision_cone_index = find(angles >= -collision_cone & angles <= collision_cone);
%Get matrix with all 0s except 1 for elements related to the collision cone
% collision_cone_matrix_index = angles >= -collision_cone & angles <= collision_cone;

collision_cone_distances = ranges(collision_cone_index)

collision_cone_distances(1) = 3
collision_cone_distances(2) = 3

%scan for points and calculate the time to collide
t_reaction_time_threshold = 3; %(seconds)


%Set the variable to 1 if there is at least one point that is probable to collide
collision = find(collision_cone_distances/v <= t_reaction_time_threshold,1);

%Get indexes of point that are probable to collide
collision_points_indexes = find(collision_cone_distances/v <= t_reaction_time_threshold);
% collision_cone_distances = collision_cone_distances(collision_cone_distances~=Inf)
% for elem in collision_cone_distances:
%     t = elem/v

if( ~isempty(collision_points_indexes) )
    fprintf('Collision!\n')
    %Stop the wheelchair sending in output a signal
end

