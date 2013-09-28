module client

import socket

if args.length < 2 then
	print "Usage : socket_client <host> <port>"
	return
end

var s = new Socket.stream_with_host(args[0], args[1].to_i)
print "[HOST ADDRESS] : {s.address}"
print "[HOST] : {s.host.as(not null)}"
print "[PORT] : {s.port.to_s}"
print "Connecting ... {s.connect.to_s}"
print "Writing ... {s.write("Hello server !").to_s}"
print "[Response from server] : {s.read.to_s}"
print "Closing ... {s.close.to_s}"

