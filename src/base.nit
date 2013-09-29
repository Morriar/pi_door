module base

import opts
import json

class PiConfig
	super HashMap[String, nullable Jsonable]

	init do super

	init from_file(path: String) do
		init
		var json = path.json_load_from_file
		if json == null then return
		for k, v in json do
			self[k] = v
		end
	end
end

abstract class PiDoorApplication

	# options
	var opt_context = new OptionContext
	var opt_config = new OptionString("config file path", "-f")

	fun process_options do
		opt_context.add_option(opt_config)
		opt_context.parse(args)
	end

	fun load_config: PiConfig do
		var config: PiConfig
		var config_path = opt_config.value
		if config_path != null and config_path.file_exists then
			config = new PiConfig.from_file(config_path)
		else
			config = new PiConfig
		end
		return config
	end

end

class PiMessage
	super HashMap[String, nullable Jsonable]

	init do super

	init from_string(json: String) do
		init
		var object = json.json_to_object
		if object == null then return
		for k, v in object do
			self[k] = v
		end
	end
end

