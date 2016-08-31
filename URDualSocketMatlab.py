#
# Class Definition for Constant Socket Comms to UR Platforms
#
# ENS Kevin Strotz
# 19 AUG 2016
#
# Referenced in MATLAB class, make sure directory is appropriate and command names match
# Do NOT need direct Python interface for functionality, everything is called in MATLAB
#
# Be careful of variable types when passing values Python <-> MATLAB
# - Some are not supported in the other, ie. tuples, MATLAB doubles
# - Manually convert to force compatibility 
#

# Initialize socket in correct family, bind as a server, and begin listening for clients
# Return socket structure to the MATLAB workspace for future use
# Three input parameters:
#  host = server IP address
#  port = port to listen for connections on
#  backlog = number of connections to listen for
def init(host,port,backlog):    
    import socket           # import socket module to Python environment
    global socketname       # create global handle to for server socket to be returned to MATLAB
    socketname = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # initialize socket type
    socketname.bind((host, port))   # Bind socket to specified host address and port
    socketname.listen(backlog)      # Begin listening for client connections from manipulators
    return socketname       # return established server socket to MATLAB workspace

# Accept client connections on a previously established server
# One input parameter:
#  socketname = established server socket handle
def cnct(socketname):
    global client           # create global handle for client to be returned to MATLAB 
    sockettuple = socketname.accept()   # Accept a connection and store [client, address] in handle
    client = sockettuple[0] # Separate actual socket object out of tuple
    return client           # return established client socket to MATLAB workspace

# Get current joint velocities from a manipulator
# ***NO NATIVE URX FUNCTION, CONSIDER IMPLEMENTING THIS IN URX MODULE VICE HERE***
# One input parameter:
#  robot = established URX connection
def getvels(robot):
    global jVels            # create global handle for joint velocities to be returned to MATLAB
    jData = robot.secmon._dict["JointData"] # Extract all joint info from URX dictionary using key "JointData"
    # Extract joint velocities from all joint data using variable names
    jVels = [jData["qd_actual0"],jData["qd_actual1"],jData["qd_actual2"],jData["qd_actual3"],jData["qd_actual4"],jData["qd_actual5"]]
    return jVels            # return joint velocity list to MATLAB workspace

# Send message from server to client (UR robot)
# Message is simply a string, Python does not format it at all
# Ensure correct formatting in MATLAB that will be understood by onboard controllers
# Needs .encode() to convert to binary before sending
# Two input parameters:
#  client = established client socket destination
#  msg = string to be sent to client
def sendmsg(client,msg):
    client.send(msg.encode())   # Encode string as binary and send to designated client

# Close socket connection
# Does not eliminate handle or object, simply closes connection
# One dual manipulator setup has five sockets to close: 2x clients, 2x URX, 1x server
# One input parameter:
#  socketname = handle of socket to be closed
def close(socketname):
    socketname.close()      # Close designated socket
        
    
