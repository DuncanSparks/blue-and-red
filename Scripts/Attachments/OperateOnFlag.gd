extends Node

export(String) var flag: String
export(int, "EQ,NE,LT,GT,LE,GE") var operand: int
export(int) var value: int

export(int, "Destroy,Show,Hide,Set Talk Number,Activate Switch") var operation: int
export(int) var parameter: int


func _ready():
	match operand:
		0:
			if Controller.flag(flag) == value:
				execute_operation()
		1:
			if Controller.flag(flag) != value:
				execute_operation()
		2:
			if Controller.flag(flag) < value:
				execute_operation()
		3:
			if Controller.flag(flag) > value:
				execute_operation()
		4:
			if Controller.flag(flag) <= value:
				execute_operation()
		5:
			if Controller.flag(flag) >= value:
				execute_operation()


func execute_operation():
	match operation:
		0:
			get_parent().queue_free()
		1:
			get_parent().show()
		2:
			get_parent().hide()
		3:
			get_parent().talk_number = parameter
		4:
			get_parent().activate(false)
