module client

import opts
import socket

class Config
	var host: String
	var port: Int
	var user: String
end

class PiDoorClient
	var config: nullable Config

	# options
	var opt_context = new OptionContext
	var opt_host = new OptionString("server address", "-h")
	var opt_port = new OptionInt("server port", 9898, "-p")
	var opt_user = new OptionString("user", "-u")

	init do
		opt_context.add_option(opt_host)
		opt_context.add_option(opt_port)
		opt_context.add_option(opt_user)
		opt_context.parse(args)

		if not load_config then
			usage
			exit(1)
		end
	end

	fun load_config: Bool do
		var host = opt_host.value
		if host == null then return false
		var port = opt_port.value
		if port < 0 then return false
		var user = opt_user.value
		if user == null then return false

		config = new Config(host, port, user)
		return true
	end

	fun usage do
		print "Usage: client -h host -u user [-p port]"
		for opt in opt_context.options do print opt.pretty(1)
	end

	fun request_action(action: String) do
		var s = new Socket.stream_with_host(config.host, config.port)
		printn "Connecting to {s.address}:{s.port}..."
		if not s.connect then
			print "\t[KO]"
			print "Error: Cannot connect to host"
			return
		end
		print "\t[OK]"

		var message = "{config.user}:{action}"
		printn "Sending message..."
		if not s.write(message) then
			print "\t[KO]"
			print "Error: Cannot send message to host"
			return
		end
		print "\t[OK]"

		print "Waiting for response..."
		print "Response: {s.read.to_s}"

		printn "Closing connection..."
		if not s.close then
			print "\t[KO]"
			print "Error: Cannot close connection"
			return
		end
		print "\t[OK]"
	end
end

var client = new PiDoorClient
client.request_action("open")


