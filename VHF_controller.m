%Create a publisher and subscriber to share information with the VFH class. The subscriber receives the laser scan data from the robot. The publisher sends velocity commands to the robot.

%The topics used are for the simulated TurtleBot.

controller = ros2node("/vhf_controller_node_slider");
laserSub = ros2subscriber(controller, '/scan');
%[velPub,velMsg] = ros2publisher(controller,'/cmd_vel');
velPub = ros2publisher(controller,'/cmd_vel');

% Set up VFH object for obstacle avoidance. Set the UseLidarScan property to true. Specify algorithm properties for robot specifications. Set target direction to 0 in order to drive straight.
vfh = controllerVFH;
vfh.UseLidarScan = true;
vfh.DistanceLimits = [0.05 1];
vfh.RobotRadius = 0.1;
vfh.MinTurningRadius = 0.2;
vfh.SafetyDistance = 0.1;

%targetDir = 0;
% Control target direction
fig = uifigure;
k = uiknob(fig);
k.Limits=[-180 180];
%Control forward speed
fig = uifigure;
sld = uislider(fig,"Orientation","vertical");
sld.Limits = [0 1];
%Set up a Rate object using rateControl, which can track the timing of your loop. This object can be used to control the rate the loop operates as well.

rate = rateControl(10);

%
while rate.TotalElapsedTime < 500

    targetDir = deg2rad(k.Value);

	% Get laser scan data
	laserScan = receive(laserSub);
	ranges = double(laserScan.ranges);
	angles = double(rosReadScanAngles(laserScan));
 
	% Create a lidarScan object from the ranges and angles
    scan = lidarScan(ranges,angles);
        
	% Call VFH object to computer steering direction
	steerDir = vfh(scan, targetDir);  
    
	% Calculate velocities
	if ~isnan(steerDir) % If steering direction is valid
		% desiredV = 0.5;
        desiredV = sld.Value;
		w = exampleHelperComputeAngularVelocity(steerDir, 1);
        % w = 0.5;
	else % Stop and search for valid direction
		desiredV = 0.0;
		%w = 0.5;
        % Stop the robot
        w=0.0;
	end

	% Assign and send velocity commands
    velMsg = ros2message(velPub);

	velMsg.linear.x = desiredV;
	velMsg.angular.z = w;
	velPub.send(velMsg);
end

% Assign and send velocity commands
velMsg = ros2message(velPub);
velMsg.linear.x = 0.4;
velMsg.angular.z = 0.5;
velPub.send(velMsg);

