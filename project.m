%% Create Satellite Scenario

startTime = datetime(2024,4,22,9,30,0);   % 19 August 2020 8:55 PM UTC
%startTime = datetime(2020,8,19,20,55,0);
%startTime = datetime(2020,5,12,13,0,0);
stopTime = startTime + days(1);                       % 20 August 2020 8:55 PM UTC
sampleTime = 60;                                      % seconds
%% Launch Satellite Scenario Viewer
sc = satelliteScenario(startTime,stopTime,sampleTime);

%% Add the Satellites
satelliteScenarioViewer(sc);
semiMajorAxis = 10000000;                  % meters
eccentricity = 0;
inclination = 0;                           % degrees
rightAscensionOfAscendingNode = 0;         % degrees
argumentOfPeriapsis = 0;                   % degrees
trueAnomaly = 0;                           % degrees
sat1 = satellite(sc, ...
    semiMajorAxis, ...
    eccentricity, ...
    inclination, ...
    rightAscensionOfAscendingNode, ...
    argumentOfPeriapsis, ...
    trueAnomaly, ...
    "Name","Satellite 1", ...
    "OrbitPropagator","two-body-keplerian");
semiMajorAxis = 10000000;                  % meters
eccentricity = 0;
inclination = 30;                          % degrees
rightAscensionOfAscendingNode = 120;       % degrees
argumentOfPeriapsis = 0;                   % degrees
trueAnomaly = 300;                         % degrees
sat2 = satellite(sc, ...
    semiMajorAxis, ...
    eccentricity, ...
    inclination, ...
    rightAscensionOfAscendingNode, ...
    argumentOfPeriapsis, ...
    trueAnomaly, ...
    "Name","Satellite 2", ...
    "OrbitPropagator","two-body-keplerian");

%% Add Gimbals to the Satellites
gimbalSat1Tx = gimbal(sat1, ...
    "MountingLocation",[0;1;2]);  % meters
gimbalSat2Tx = gimbal(sat2, ...
    "MountingLocation",[0;1;2]);  % meters
gimbalSat1Rx = gimbal(sat1, ...
    "MountingLocation",[0;-1;2]); % meters
gimbalSat2Rx = gimbal(sat2, ...
    "MountingLocation",[0;-1;2]); % meters

%% Add Receivers and Transmitters to the Gimbals
sat1Rx = receiver(gimbalSat1Rx, ...
    "MountingLocation",[0;0;1], ...      % meters
    "GainToNoiseTemperatureRatio",3, ... % decibels/Kelvin
    "RequiredEbNo",4);                   % decibels
sat2Rx = receiver(gimbalSat2Rx, ...
    "MountingLocation",[0;0;1], ...      % meters
    "GainToNoiseTemperatureRatio",3, ... % decibels/Kelvin
    "RequiredEbNo",4); 


gaussianAntenna(sat1Rx, ...
    "DishDiameter",0.5);    % meters
gaussianAntenna(sat2Rx, ...
    "DishDiameter",0.5);    % meters


sat1Tx = transmitter(gimbalSat1Tx, ...
    "MountingLocation",[0;0;1], ...   % meters
    "Frequency",30e9, ...             % hertz
    "Power",15);                      % decibel watts
sat2Tx = transmitter(gimbalSat2Tx, ...
    "MountingLocation",[0;0;1], ...   % meters
    "Frequency",27e9, ...             % hertz
    "Power",15);       
gaussianAntenna(sat1Tx, ...
    "DishDiameter",0.5);    % meters
gaussianAntenna(sat2Tx, ...
    "DishDiameter",0.5);    % meters
halfBeamWidth = 62.7; % degrees

%% Add the Ground Stations
latitude = 12.9436963;          % degrees
longitude = 77.6906568;         % degrees
gs1 = groundStation(sc, ...
    latitude, ...
    longitude, ...
    "Name","Ground Station 1",...
    "MinElevationAngle",20);
latitude = -33.7974039;        % degrees
longitude = 151.1768208;       % degrees
gs2 = groundStation(sc, ...
    latitude, ...
    longitude, ...
    "Name","Ground Station 2",...
    "MinElevationAngle",10);

gimbalGs1 = gimbal(gs1, ...
    "MountingAngles",[0;180;0], ... % degrees
    "MountingLocation",[0;0;-5]);   % meters
gimbalGs2 = gimbal(gs2, ...
    "MountingAngles",[0;180;0], ... % degrees
    "MountingLocation",[0;0;-5]);   % meters

%% Add Transmitters and Receivers to Ground Station Gimbals
gs1Tx = transmitter(gimbalGs1, ...
    "Name","Ground Station 1 Transmitter", ...
    "MountingLocation",[0;0;1], ...           % meters
    "Frequency",30e9, ...                     % hertz
    "Power",30); 
gaussianAntenna(gs1Tx, ...
    "DishDiameter",2); % meters

gs2Rx = receiver(gimbalGs2, ...
    "Name","Ground Station 2 Receiver", ...
    "MountingLocation",[0;0;1], ...        % meters
    "GainToNoiseTemperatureRatio",3, ...   % decibels/Kelvin
    "RequiredEbNo",1);
gaussianAntenna(gs2Rx, ...
    "DishDiameter",2); % meters

%% Set Tracking Targets for Gimbals
pointAt(gimbalGs1,sat1);
pointAt(gimbalSat1Rx,gs1);
pointAt(gimbalSat1Tx,sat2);
pointAt(gimbalSat2Rx,sat1);
pointAt(gimbalSat2Tx,gs2);
pointAt(gimbalGs2,sat2);

%% Add Link Analysis and Visualize Scenario
lnk = link(gs1Tx,sat1Rx,sat1Tx,sat2Rx,sat2Tx,gs2Rx);

%% Determine Times When Link is Closed and Visualize Link Closures
linkIntervals(lnk)
[e, time] = ebno(lnk);
margin = e - gs2Rx.RequiredEbNo;

%% Calculate latency between Satellite 1 and Ground Station 1
[delay_gs1, time_gs1] = latency(sat1, gs1);

% Calculate latency between Satellite 1 and Satellite 2
[delay_sat2, time_sat2] = latency(sat1, sat2);

% Calculate latency between Satellite 1 and Ground Station 2
[delay_gs2, time_gs2] = latency(sat2, gs2);

% Plot latency graph
figure;
subplot(3,1,1);
plot(time_gs1, delay_gs1);
title('Latency between Satellite 1 and Ground Station 1');
xlabel('Time');
ylabel('Latency (s)');

subplot(3,1,2);
plot(time_sat2, delay_sat2);
title('Latency between Satellite 1 and Satellite 2');
xlabel('Time');
ylabel('Latency (s)');

subplot(3,1,3);
plot(time_gs2, delay_gs2);
title('Latency between Satellite 1 and Ground Station 2');
xlabel('Time');
ylabel('Latency (s)');

%% Modify Required Eb/No and Observe Effect on Link Intervals

gs2Rx.RequiredEbNo = 10; % decibels
linkIntervals(lnk)
[e, newTime] = ebno(lnk);
newMargin = e - gs2Rx.RequiredEbNo;
figure;
plot(newTime,newMargin,"r",time,margin,"b","LineWidth",2);
xlabel("Time");
ylabel("Link Margin (dB)");
legend("New link margin","Old link margin","Location","north");
grid on;

%% Radiation Beam
%pat1 = pattern(sat1Rx,"Size",3000000);
sat1_pat = pattern(sat1Tx,"Size",3000000);
sat2_pat = pattern(sat2Tx,"Size",3000000);
%pat4 = pattern(sat2Rx,"Size",3000000);
pointAt(sat1,sat2);
pointAt(sat2,gs2);

% Calculate radiation patterns for ground stations
gs1Tx_pat = pattern(gs1Tx, 'Size', 1000000);

gs2Rx_pat = pattern(gs2Rx, 27e9, 'Size', 1000000);


%% Access analysis

name1 = sat1.Name + " Camera";
cam = conicalSensor(sat1,"Name",name1,"MaxViewAngle",90);
ac1 = access(cam,gs1);
fov = fieldOfView(cam([cam.Name] == "Satellite 1 Camera"));
accessIntervals(ac1);

name2 = sat2.Name + " Camera";
cam2 = conicalSensor(sat2,"Name",name2,"MaxViewAngle",90);
ac2 = access(cam2,gs2);
fov2 = fieldOfView(cam2([cam2.Name] == "Satellite 2 Camera"));
accessIntervals(ac2);

%% Eb/No ratio varying with time
time_serial = datetime(time);

e_indices = isinf(e);
e_cleaned = e;
e_cleaned(e_indices) = 0;
figure;
plot(time_serial,e_cleaned, 'LineWidth', 1.5);
title('Eb/N0 vs Time for Multi-Hop link');
xlabel('Discrete Time');
ylabel('Eb/N0 (dB)');
grid on;

%% Each link Eb/No
% Create links separately for gs1Tx and sat1Rx
link_gs1Tx_sat1Rx = link(gs1Tx, sat1Rx);
link_sat2Tx_gs2Rx = link(sat2Tx, gs2Rx);
%link_sat1Tx_sat2Rx = link(sat1Tx, sat2Rx);


% Calculate Eb/N0 for each link
[e_gs1_sat1, time_gs1_sat1] = ebno(link_gs1Tx_sat1Rx);
[e_sat2_gs2, time_sat2_gs2] = ebno(link_sat2Tx_gs2Rx);

% Overwrite -Inf values with 0 baseline
e_1 = e_gs1_sat1; e_2 = e_sat2_gs2;
e_1(isinf(e_gs1_sat1))= 0; e_2(isinf(e_sat2_gs2)) = 0;


% Plot Eb/N0 vs. time for each link
figure;
subplot(2,1,1);
plot(time_gs1_sat1,e_1, 'LineWidth', 1.5,'Color','g');
title('Eb/N0 vs Time for Uplink');
xlabel('Time');
ylabel('Eb/N0 (dB)');
grid on; 

subplot(2,1,2);
plot(time_sat2_gs2, e_2, 'LineWidth', 1.5,'Color','r');
title('Eb/N0 vs Time for Downlink');
xlabel('Time');
ylabel('Eb/N0 (dB)');
%legend('gs1Tx - sat1Rx', 'sat1Tx - gs2Rx');
grid on;

%% Plot link establishment 
figure;
bar(time, lnk.linkStatus, 'FaceColor', [0.1 0.9 0.1]);
hold on;
bar(time, ~lnk.linkStatus, 'FaceColor', [0.9 0.1 0.1]);
xlabel('Time');
ylabel('Link Availability');
title('Link Availability Over Time');
legend('Available', 'Unavailable');

% Format x-axis as datetime
xtickformat('yyyy-MM-dd HH:mm:ss');

% % Format y-axis as integer
% ytickformat('%d');



%% Simulate scenario
play(sc);

%% Coverage map
%cov_fn(sc,sat2Tx,startTime,27e9);



