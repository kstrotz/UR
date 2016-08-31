#
# Class Definition for Constant Socket Comms to UR Platforms
#
# ENS Kevin Strotz
# 7 JUL 2016
#
# Referenced in MATLAB class, make sure directory is appropriate and command names match
# Do NOT need direct Python interface for functionality, everything is called in MATLAB
#
# Be careful of variable types when passing values Python <-> MATLAB
# - Some are not supported in the other, ie. tuples, MATLAB doubles
# - Manually convert to force compatibility 
#

# Initialize socket in correct family
def init():
    import socket
    global socketname
    socketname = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    return socketname

# Connect socket (AS SERVER) with desired host IP, port, and connection backlog
def cnct(socketname, host, port, backlog):
    global client
    global addr
    socketname.bind((host, port))
    socketname.listen(backlog)
    sockettuple = socketname.accept()
    client = sockettuple[0]
    return client

# Get current joint velocities
# ***NO NATIVE URX FUNCTION, CONSIDER IMPLEMENTING THIS IN URX MODULE VICE HERE***
def getvels(robot):
    global jVels
    jData = robot.secmon._dict["JointData"]
    jVels = [jData["qd_actual0"],jData["qd_actual1"],jData["qd_actual2"],jData["qd_actual3"],jData["qd_actual4"],jData["qd_actual5"]]
    return jVels

# Send message from server to client (UR robot)        
def sendmsg(client,msg):
    client.send(msg.encode())

# Close socket connection
def close(socketname):
    socketname.close()
        
    
