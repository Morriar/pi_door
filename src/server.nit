module server

import base
import socket
import wiringPi


class PiDoorServer
	super PiDoorApplication

	var config: PiConfig

	# options
	var opt_port = new OptionString("server port", "-p")
	var opt_pin = new OptionString("GPIO door pin", "-o")

	init do
		wiringPi_setup_gpio
		process_options
		config = load_config
		if not config.has_key("port") or not config.has_key("pin") then
			usage
			exit(1)
		end
	end

	redef fun process_options do
		opt_context.add_option(opt_port)
		opt_context.add_option(opt_pin)
		super
	end

	redef fun load_config do
		var config = super
		var port = opt_port.value
		if port != null then config["port"] = port.to_i
		var pin = opt_pin.value
		if pin != null then config["pin"] = pin.to_i
		return config
	end

	fun usage do
		print "Usage: server [-pof]"
		for opt in opt_context.options do print opt.pretty(1)
	end

	fun start do
		var port = config["port"].as(Int)
		var socket = new Socket.stream_with_port(port)
		print "Opening connection on port {port}:"

		printn "Binding..."
		if not socket.bind then
			print "\t[KO]"
			print "Errot: Cannot bind on port {port} (maybe this port is already used?)"
			return
		end
		print "\t[OK]"

		printn "Listening..."
		if not socket.listen(3) then
			print "\t[KO]"
			print "Error: Cannot listen on port {port}"
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
				var message = new PiMessage.from_string(string)
				message["address"] = ns.address
				if not do_action(message) then
					var error = "Error: Unable to do action '{message["action"].as(String)}'"
					print error
					ns.write(error)
					ns.close
				end
				ns.write("success")
				ns.close
			end
		end
	end

	fun do_action(message: PiMessage): Bool do
		var action = message["action"].as(String)
		var user = message["user"].as(String)
		var address = message["address"].as(String)
		print "Action {action} required by {user} ({address})"

		if action == "open" then
			var pin = new RPiPin(config["pin"].as(Int))
			pin.mode(new RPiPinMode.output_mode)
			pin.write(true)
			sys.nanosleep(1, 0)
			pin.write(false)
		end
		return true
	end
end

var server = new PiDoorServer
server.start

