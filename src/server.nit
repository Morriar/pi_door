module server

import socket

if args.is_empty then
	print "Usage : socket_server <port>"
	return
end

var socket = new Socket.stream_with_port(args[0].to_i)
print "[PORT] : {socket.port.to_s}"
print "Binding ... {socket.bind.to_s}"
print "Listening ... {socket.listen(3).to_s}"

var clients = new Array[Socket]
var max = socket
loop
	var fs = new SocketObserver(true, true, true)
	fs.readset.set(socket)

	for c in clients do fs.readset.set(c)

	if fs.select(max, 4, 0) == 0 then
		print "Error occured in select {socket.errno.to_s}"
		break
	end

	if fs.readset.is_set(socket) then
		var ns = socket.accept
		print "Accepting {ns.address} ... "
		print "[Message from {ns.address}] : {ns.read}"
		ns.write("Goodbye client.")
		print "Closing {ns.address} ... {ns.close.to_s}"
	end
end

