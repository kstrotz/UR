%{
 
MATLAB Class for Python Socket to UR5
written by ENS Kevin Strotz, USN
26JUL16

Use independent Python class for MATLAB to enable native
communications in MATLAB without needing Python proficiency

Consider renaming

%}

% Define class as 'handle' type --> allows properties to update properly
classdef URObj < handle
    % Define properties that will be set as part of the object
    properties
        HOST        % Server IP address (on computer) --> generally set to 10.1.1.5
        PORT        % Server port to listen on --> should be 30002
        BACKLOG     % Number of connections to listen to --> should be 2
        CLIENT1     % Client 1 (UR robot) socket object --> generally set to 10.1.1.2 [UR10]
        CLIENT2     % Client 2 (UR robot) socket object --> generally set to 10.1.1.4 [UR5]
        SERVER      % Server socket object --> created during initialization
        MSG         % Message to be sent to UR robot --> input by user
        STATE       % Socket state --> can be OPEN or CLOSE
        URX1        % URX socket object --> OPTIONAL
        URX2        % URX socket object --> OPTIONAL
        URXADDR1    % URX socket address --> OPTIONAL
        URXADDR2    % URX socket address --> OPTIONAL
        JOINTS1     % Joint position --> does not automatically refresh
        JOINTS2     % Joiny position --> does not automatically refresh
        VELS1       % Joint velocities --> does not automatically refresh
        VELS2       % Joint velocities --> does not automatically refresh
    end
    % End properties section
    
    % Define methods to update properties and communicate across the LAN
    methods
        % Initialization function creating class object
        % host = server IP address on computer [10.1.1.5]
        % port = IP port on UR manipulators [30002]
        % backlog = number of connections [2]
        function obj = URObj(host,port,backlog)
            % Check for correct input arguments
            if nargin == 3                  % Make sure three arguments are present
                inputVal{1,1} = host;       % Put host in cell for comparison
                port = int32(port);         % Convert double to integer for Python
                backlog = int32(backlog);   % Convert double to integer for Python
                if iscellstr(inputVal)      % If host is a string
                    obj.HOST = host;        % Set HOST property
                else
                    error('Host must be a string.');    % Raise error if host is not string
                end
                if isnumeric(port)      % If port is a number
                    obj.PORT = port;    % Set PORT property
                else
                    error('Port must be an integer.');  % Raise error if port is not number
                end
                if isnumeric(backlog)   % If backlog is a number
                    obj.BACKLOG = backlog;  % Set BACKLOG property
                else
                    error('Backlog must be an integer.');   % Raise error if backlog is not a number
                end
            else                            % If there are not three parameters
                % Raise error if there are not three arguments
                error('UR class requires three parameters: host, port, and backlog.');
            end
          
            addpath('C:\Users\Research\Documents')  % Add path with modules
            global URMod;                           % Global variable for custom Python module
            global URX;                             % Global variable for URX Python module
            % IMPORT PYTHON MODULES: DO NOT INCLUDE .py
            URMod = py.importlib.import_module('URDualSocketMatlab');
            URX = py.importlib.import_module('urx');
            fprintf('Module imported.\n');          % Indicate modules imported
            obj.SERVER = URMod.init(obj.HOST,obj.PORT,obj.BACKLOG); % Create server socket on computer
            fprintf('Server created.\n')            % Indicate server started
            fprintf('Begin onboard controllers, then press ENTER.') % Press start on manipulators.
            obj.CLIENT1 = URMod.cnct(obj.SERVER);   % Wait for first onboard controller to connect as client
            obj.CLIENT2 = URMod.cnct(obj.SERVER);   % Wait for second onboard controller to connect as client
            obj.STATE = 'OPEN';             % Set STATE property to indicate connections
            input('');                      % Wait for key press to indicate controllers started
            fprintf('Connections established.\n');  % Indicate clients connected
            urxFlag = input('Would you like to create URX connections as well? ','s');  % Ask if user wants URX connections too
            % Check if user indicates yes
            if (strcmp(urxFlag,'YES') || strcmp(urxFlag,'yes') || strcmp(urxFlag,'Y') || strcmp(urxFlag,'y'))
                obj.URXADDR1 = input('Enter first URX address: ','s');  % Set first URX address property
                obj.URX1 = URX.Robot(obj.URXADDR1);                     % Create first URX connection
                fprintf('First URX connection established.\n');         % Indicate URX connection
                obj.URXADDR2 = input('Enter second URX address: ','s'); % Set second URX address property
                obj.URX2 = URX.Robot(obj.URXADDR2);                     % Create second URX connection
                fprintf('Second URX connection established.\n');        % Indicate URX connection 
            else                            % If user does not want URX connections
                fprintf('No URX connections created.');     % Indicate no URX connections
            end
        end  
        
        % Set STATE property
        function obj = set.STATE(obj,state)
            obj.STATE = state;
        end
        % Get STATE property
        function state = get.STATE(obj)
            state = obj.STATE;
        end
        % Set MSG property
        function obj = set.MSG(obj,msg)
            obj.MSG = msg;
        end
        % Get MSG property
        function msg = get.MSG(obj)
            msg = obj.MSG;
        end
        % Set JOINTS1 property
        function obj = set.JOINTS1(obj,joints1)
            obj.JOINTS1 = joints1;
        end
        % Get JOINTS1 property
        function joints1 = get.JOINTS1(obj)
            joints1 = obj.JOINTS1;
        end
        % Set JOINTS2 property
        function obj = set.JOINTS2(obj,joints2)
            obj.JOINTS2 = joints2;
        end
        % Get JOINTS2 property
        function joints2 = get.JOINTS2(obj)
            joints2 = obj.JOINTS2;
        end
        % Set VELS1 property
        function obj = set.VELS1(obj,velocities1)
            obj.VELS1 = velocities1;
        end
        % Get VELS1 property
        function vels1 = get.VELS1(obj)
            vels1 = obj.VELS1;
        end
        % Set VELS2 property
        function obj = set.VELS2(obj,velocities2)
            obj.VELS2 = velocities2;
        end
        % Get VELS2 property
        function vels2 = get.VELS2(obj)
            vels2 = obj.VELS2;
        end
        
        % Function to send message to the manipulator
        % Two user specified arguments:
        %  message = data string to transmit
        %  client  = which manipulator (1 or 2)
        function obj = msg(obj,message,client)
            global URMod        % Bring URMod to function workspace
            global URX          % Bring URX to function workspace
            obj.MSG = message;  % Set MSG property to latest message
            if client == 1      % If going to first manipulator
                URMod.sendmsg(obj.CLIENT1,obj.MSG); % Send message to CLIENT1
            elseif client == 2  % If going to second manipulator
                URMod.sendmsg(obj.CLIENT2,obj.MSG); % Send message to CLIENT2
            else                % If client is not CLIENT1 or CLIENT2
                error('Invalid client.');   % Raise error for invalid client
            end
        end
        
        % Function to get current joint positions of a manipulator
        % One user specified argument:
        %  urx = which manipulator (1 or 2)
        function obj = getjoints(obj,urx)
            global URMod        % Bring URMod to function workspace
            global URX          % Bring URX to function workspace
            if urx == 1         % If checking first manipulator
                obj.JOINTS1 = obj.URX1.getj();  % Get joint positions and set result to JOINTS1
            elseif urx == 2     % If checking second manipulator
                obj.JOINTS2 = obj.URX2.getj();  % Get joint positions and set result to JOINTS2
            else                % If URX is not URX1 or URX2
                error('Invalid URX connection.');   % Raise error for invalid URX
            end
        end
        
        % Function to get current joint velocities of a manipulator
        % One user specified argument:
        %  urx = which manipulator (1 or 2)
        function obj = getvels(obj,urx)
            global URMod        % Bring URMod to function workspace
            global URX          % Bring URX to function workspace
            if urx == 1         % If checking first manipulator
                vels = URMod.getvels(obj.URX1); % Get velocities from URX1 and set to variable
                obj.VELS1 = vels;               % Update VELS1 property
            elseif urx == 2     % If checking second manipulator
                vels = URMod.getvels(obj.URX2); % Get velocities from URX2 and set to variable
                obj.VELS2 = vels;               % Update VELS2 property
            else                % If URX is not URX1 or URX2
                error('Invalid URX connection.');   % Raise error for invalid URX
            end
        end
        
        % Function to close ports at conclusion of operation
        % No user specified arguments
        function obj = clse(obj)
            % Make sure the user intends to close the connections
            check = input('Are you sure you want to close connections? ','s');
            % If they are sure they want to close
            if (strcmp(check,'YES') || strcmp(check,'yes') || strcmp(check,'Y') || strcmp(check,'y'))
                obj.STATE = 'CLOSED';   % Set STATE property to closed
                global URMod            % Bring URMod to function workspace
                global URX              % Bring URX to function workspace
                URMod.close(obj.CLIENT1);   % Close first client connection
                URMod.close(obj.CLIENT2);   % Close second client connection
                obj.URX1.close();       % Close first URX connection
                obj.URX2.close();       % Close second URX connection
                URMod.close(obj.SERVER);    % Close server on computer
            else                        % If the user wants to keep connections
                fprintf('Maintaining connections.'); % Keep connections open
            end
        end
        
    end
    % End methods section
    
% End class definition
end