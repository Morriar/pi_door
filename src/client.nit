module client

import base
import socket

class PiDoorClient
	super PiDoorApplication

	var config: PiConfig

	# options
	var opt_host = new OptionString("server address", "-h")
	var opt_port = new OptionString("server port", "-p")
	var opt_user = new OptionString("user", "-u")

	init do
		process_options
		config = load_config
		if not config.has_key("port") or not config.has_key("host") or not config.has_key("user") then
			usage
			exit(1)
		end
	end

	redef fun process_options do
		opt_context.add_option(opt_host)
		opt_context.add_option(opt_port)
		opt_context.add_option(opt_user)
		super
	end

	redef fun load_config do
		var config = super
		var port = opt_port.value
		if port != null then config["port"] = port.to_i
		var host = opt_host.value
		if host != null then config["host"] = host
		var user = opt_user.value
		if user != null then config["user"] = user
		return config
	end

	fun usage do
		print "Usage: client -h host -u user [-p port]"
		for opt in opt_context.options do print opt.pretty(1)
	end

	fun request_action(action: String) do
		var user = config["user"].as(String)
		var host = config["host"].as(String)
		var port = config["port"].as(Int)
		var s = new Socket.stream_with_host(host, port)
		printn "Connecting to {s.address}:{s.port}..."
		if not s.connect then
			print "\t[KO]"
			print "Error: Cannot connect to host"
			return
		end
		print "\t[OK]"

		var message = "{user}:{action}"
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


