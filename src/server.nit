module server

import opts
import socket

class Config
	var port: Int
end

class PiDoorServer
	var config: nullable Config

	# options
	var opt_context = new OptionContext
	var opt_port = new OptionInt("server port", 9898, "-p")

	init do
		opt_context.add_option(opt_port)
		opt_context.parse(args)
	end

	fun start do
		if not load_config then
			usage
			return
		end

		listen
	end

	fun load_config: Bool do
		var port = opt_port.value
		if port > 0 then
			config = new Config(port)
		end
		return config != null
	end

	fun usage do
		print "Usage: server [-p]"
		for opt in opt_context.options do print opt.pretty(1)
	end

	fun listen do
		var socket = new Socket.stream_with_port(config.port)
		print "Opening connection on port {config.port}:"

		printn "Binding..."
		if not socket.bind then
			print "\t[KO]"
			print "Errot: Cannot bind on port {config.port} (maybe this port is already used?)"
			return
		end
		print "\t[OK]"

		printn "Listening..."
		if not socket.listen(3) then
			print "\t[KO]"
			print "Error: Cannot listen on port {config.port}"
			return
		end
		print "\t[OK]"

		print "Waiting for clients...\n"

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
				var string = ns.read
				var message = parse_message(string, ns.address)
				if message == null then
					var error = "Error: Malformed message '{string}'"
					print error
					ns.write(error)
					ns.close
				else
					if not do_action(message) then
						var error = "Error: Unable to do action '{message.action}'"
						print error
						ns.write(error)
						ns.close
					end
					ns.write("success")
					ns.close
				end
			end
		end
	end

	fun parse_message(string: String, address: String): nullable Message do
		var parts = string.split(":")
		if parts.length < 2 then return null
		return new Message(parts[0], parts[1], address)
	end

	fun do_action(message: Message): Bool do
		print "Action {message.action} required by {message.user} ({message.address})"
		return true
	end
end

class Message
	var user: String
	var action: String
	var address: String
end

var server = new PiDoorServer
server.start

