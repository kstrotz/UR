%{
 
MATLAB Class for Python Socket to UR5
written by ENS Kevin Strotz, USN
26JUL16

Use independent Python class for MATLAB to enable native
communications in MATLAB without needing Python proficiency

Consider renaming

%}

% Define class as 'handle' type --> allows properties to update properly
classdef URMatlabClass < handle
    % Define properties that will be set as part of the object
    properties
        HOST        % Server IP address (on computer) --> generally set to 10.1.1.5
        PORT        % Server port to listen on --> should be 30002
        BACKLOG     % Number of connections to listen to --> should be 1
        CLIENT      % Client (UR robot) IP address --> generally set to 10.1.1.2/3/4
        SERVER      % Server socket object --> created during initialization
        MSG         % Message to be sent to UR robot --> input by user
        STATE       % Socket state --> can be OPEN or CLOSE
        URX         % URX socket object --> OPTIONAL
        URXADDR     % URX socket address --> OPTIONAL
        JOINTS      % Joint position --> does not automatically refresh
        VELS        % Joint velocities --> does not automatically refresh
    end
    % Define methods to update properties and 
    methods
        function obj = URMatlabClass(host,port,backlog)
            if nargin == 3
                inputVal{1,1} = host;
                port = int32(port);
                backlog = int32(backlog);
                if iscellstr(inputVal)
                    obj.HOST = host;
                else
                    error('Host must be a string.');
                end
                if isnumeric(port)
                    obj.PORT = port;
                else
                    error('Port must be an integer.');
                end
                if isnumeric(backlog)
                    obj.BACKLOG = backlog;
                else
                    error('Backlog must be an integer.');
                end
            else
                error('UR class requires three parameters: host, port, and backlog.');
            end
            addpath('C:\Users\Research\Documents')
            global URMod;
            global URX;
            URMod = py.importlib.import_module('URSocketMatlab');
            URX = py.importlib.import_module('urx');
            fprintf('Module imported.\n');
            obj.SERVER = URMod.init();
            fprintf('Server created.\n')
            fprintf('Begin onboard controller, then press ENTER.')
            obj.CLIENT = URMod.cnct(obj.SERVER,obj.HOST,obj.PORT,obj.BACKLOG);
            obj.STATE = 'OPEN';
            input('');
            fprintf('Connection established.\n');
            urxFlag = input('Would you like to create a URX connection as well? ','s');
            if strcmp(urxFlag,'YES')
                obj.URXADDR = input('Enter URX address: ','s');
                obj.URX = URX.Robot(obj.URXADDR);
                fprintf('URX established.\n');
            else
            end
        end  
        
        function obj = set.STATE(obj,state)
            obj.STATE = state;
        end
        
        function state = get.STATE(obj)
            state = obj.STATE;
        end
        
        function obj = set.MSG(obj,msg)
            obj.MSG = msg;
        end
        
        function msg = get.MSG(obj)
            msg = obj.MSG;
        end
        
        function obj = set.JOINTS(obj,joints)
            obj.JOINTS = joints;
        end
        
        function joints = get.JOINTS(obj)
            joints = obj.JOINTS;
        end
        
        function obj = set.VELS(obj,velocities)
            obj.VELS = velocities;
        end
        
        function vels = get.VELS(obj)
            vels = obj.VELS;
        end
        
        function obj = msg(obj,message)
            global URMod
            global URX
            obj.MSG = message;
            URMod.sendmsg(obj.CLIENT,obj.MSG);
        end
        
        function obj = getjoints(obj)
            global URMod
            global URX
            obj.JOINTS = obj.URX.getj();
        end
        
        function obj = getvels(obj)
            global URMod
            global URX
            vels = URMod.getvels(obj.URX);
            obj.VELS = vels;
        end
        
        function obj = clse(obj)
            obj.STATE = 'CLOSED';
            global URMod
            global URX
            URMod.close(obj.CLIENT);
            URMod.close(obj.SERVER);
        end
    end
end