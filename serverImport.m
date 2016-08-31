
function [host, port, backlog, server] = serverImport(prevServer)
    
    host = prevServer.HOST;
    port = prevServer.PORT;
    backlog = prevServer.BACKLOG;
    server = prevServer.SERVER;
    
end