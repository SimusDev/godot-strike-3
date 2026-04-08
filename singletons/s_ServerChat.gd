extends Node

signal message_received(msg_text:String)

var total_text:String = ""

const MAX_MESSAGES = 256

func _ready() -> void:
	SimusNetRPC.register(
		[
			_receive_message
		],
		SimusNetRPCConfig.new().flag_mode_any_peer()
	)
	
	
	SimusNetVars.replicate(self, total_text)
	
	var commands_exec: Array[SD_ConsoleCommand] = [
		SD_ConsoleCommand.get_or_create("say", ""),
	]
	
	for i in commands_exec:
		i.executed.connect(_on_cmd_executed.bind(i))

func _on_cmd_executed(cmd: SD_ConsoleCommand) -> void:
	var code = cmd.get_code()
	var args_size:int = cmd.get_arguments().size()
	
	match code:
		"say":
			if not args_size == 1:
				return
			send_message(cmd.get_value_as_string())

##Local
func delete_first_message() -> void:
	var splitted = total_text.split("\n")
	splitted.remove_at(0)
	total_text = splitted

##Local
func get_message_count() -> int:
	var count:int = 0
	for line in total_text.split("\n"):
		count += 1
	
	return count

func send_message(msg_text:String) -> void:
	SimusNetRPC.invoke_all(_receive_message, msg_text)

func _receive_message(msg_text:String) -> void:
	var nickname:String = s_Networking.find_user_by_id(SimusNetRemote.sender_id).name
	var result_msg_text = "%s: %s" % [nickname, msg_text]
	total_text += result_msg_text + "\n"
	
	SimusDev.console.write("[ServerChat] %s" % result_msg_text)
	message_received.emit(result_msg_text)
	
	if get_message_count() >= MAX_MESSAGES:
		delete_first_message()
