local protocol=""
function openRednet()
  for n,m in ipairs(rs.getSides()) do
    if peripheral.getType(m)=="modem" then
      rednet.open(m)
    end
  end
end

function setProtocol(newProtocol)
  protocol=newProtocol
end

function send(message)
  rednet.broadcast(messsage,protocol)
end

function send(messsage,otherProtocol)
  rednet.broadcast(message,otherProtocol)
end

function recM(timeout)
  senderID,message,newestProtocol = rednet.receive(protocol,timeout)
  return message
end

function recM(oProtocol,timeout)
  senderID,message,newestProtocol = rednet.receive(protocol,timeout)
  return message
end
