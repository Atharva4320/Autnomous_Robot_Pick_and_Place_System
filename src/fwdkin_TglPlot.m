%%
% RBE3001 - Laboratory 1 
% 
% Instructions
% ------------
% Welcome again! This MATLAB script is your starting point for Lab
% 1 of RBE3001. The sample code below demonstrates how to establish
% communication between this script and the Nucleo firmware, send
% setpoint commands and receive sensor data.
% 
% IMPORTANT - understanding the code below requires being familiar
% with the Nucleo firmware. Read that code first.

% Lines 15-37 perform necessary library initializations. You can skip reading
% to line 38.
clear
clear java
clear classes;

vid = hex2dec('16c0');
pid = hex2dec('0486');

disp (vid);
disp (pid);

javaaddpath ../lib/SimplePacketComsJavaFat-0.6.4.jar;
import edu.wpi.SimplePacketComs.*;
import edu.wpi.SimplePacketComs.device.*;
import edu.wpi.SimplePacketComs.phy.*;
import java.util.*;
import org.hid4java.*;
version -java
myHIDSimplePacketComs=HIDfactory.get();
myHIDSimplePacketComs.setPid(pid);
myHIDSimplePacketComs.setVid(vid);
myHIDSimplePacketComs.connect();

% Create a PacketProcessor object to send data to the nucleo firmware
pp = Robot(myHIDSimplePacketComs); 
plotter = Plot();
try
  SERV_ID = 1848;            % we will be talking to server ID 1848 on
                           % the Nucleo
  SERVER_ID_READ =1910;% ID of the read packet
  DEBUG   = true;          % enables/disables debug prints

%syms theta d a alpha

%disp(pp.dh2mat([theta,d,a,alpha]));

%disp(pp.dh2mat([0,0,0,0])); % With all the parameters as 0, the transformation
                            % matrix should return Identity matrix


%disp(pp.measured_cp());
% scatter3...cl

%plotter.plot_arm(pp);
%   Initializing variables:
    posList = [];
    goal = [-35 40 0; 0 30 -45; 35 40 0; -35 40 0];
    
    for i = 1:4
        pp.interpolate_jp(goal(i,:),2000);
        t0 = clock;
        while etime(clock, t0) < 2
            plotter.plot_arm_triangle(pp, goal);
            transMatrix = pp.measured_cp();
            posList = [posList; [transMatrix(1,4) transMatrix(2,4) transMatrix(3,4)]]; 
            pause(0.1);
        end
        pause(1);
    end
    
    writematrix(posList, "lab2_triangle_data.csv");

    
%     % Add plot
%     Array = csvread('lab2_position_data.csv');
%     col1 = Array(:, 1);
%     col2 = Array(:, 2);
%     col3 = Array(:, 3);
%     scatter3(col1,col2,col3);
                            
catch exception
    getReport(exception)
    disp('Exited on error, clean shutdown');
end

% Clear up memory upon termination
pp.shutdown()