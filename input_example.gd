extends Control

#--------------------------------------------------
# 设置和读取配置部分的代码
# 注意！！！！！ 选择【运行当前场景F6】
# 路径是 C:\Users\[用户名字]\AppData\Roaming\Godot\app_userdata\Input Helper\setting.cfg
const config_path = "user://setting.cfg"
"""
文件内容大概是这样
[control]
ui_left0="A"
ui_left1="W"
key_maps="key:A;joypad:13;joypad:0|-1.000000;key:W"
"""

var config:ConfigFile = ConfigFile.new()

const SETTING = "control"
func _get_key_value(key:String, def:Variant = "") -> Variant: return config.get_value(SETTING, key, def)
func _set_key_value(key:String, val:Variant) -> void: config.set_value(SETTING, key, val);config.save(config_path)

#--------------------------------------------------
## 这里对应的是 【项目】【项目设置】【输入映射】
const action_name:String = "ui_left"

const input_key0:String = "ui_left0"
const input_key1:String = "ui_left1"

const input_map_action:String = "key_maps"

var input0:String = "a"
var input1:String = "left"

# 这个索引的做法可以是一个操作绑定多个键位
var changing_input_index:int = -1;

func _ready() -> void:
	load_inputs();
	
func load_inputs() -> void:
	$Label.text = action_name
	
	config.load(config_path)
	input0 =_get_key_value(input_key0)
	input1 =_get_key_value(input_key1)
	
	if (input0 != ""): $Button0.text = input0
	if (input1 != ""): $Button1.text = input1
	
	# 加载使用 方式1
	if (input0 != ""): InputHelper.deserialize_inputs_for_action(action_name, input0)
	if (input1 != ""): InputHelper.deserialize_inputs_for_action(action_name, input1)
	
	# 加载使用 方式2
	var des = _get_key_value(input_map_action)
	if (des != ""): InputHelper.deserialize_inputs_for_action(action_name,des)

# 设置按键
func _remap_key(event) -> void:
	if changing_input_index == -1: return

	var did_update: bool = false
	var tmp_input:String = ""
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		InputHelper.replace_keyboard_input_at_index(action_name, changing_input_index, event, true)
		tmp_input = InputHelper.get_label_for_input(event)
		did_update = true

	elif (event is InputEventJoypadButton or event is InputEventJoypadMotion) and event.is_pressed():
		InputHelper.replace_joypad_input_at_index(action_name, changing_input_index, event, true)
		tmp_input = InputHelper.get_label_for_input(event)
		did_update = true

	if did_update:
		accept_event()
		update_labels(self.changing_input_index, tmp_input)
		# 保存方式1
		if (self.changing_input_index == 0):
			_set_key_value(input_key0, tmp_input)
		elif (self.changing_input_index == 1):
			_set_key_value(input_key1, tmp_input)
		# 保存方式2
		var des = InputHelper.serialize_inputs_for_action(action_name)
		_set_key_value(input_map_action, des)
		print(des)
		
		self.changing_input_index = -1
func _check_key(event) -> void:
	if (Input.is_action_just_pressed(action_name)):
		var tmp_input = InputHelper.get_label_for_input(event)
		$Label2.text = " you pressed %s: key: %s"%[action_name, tmp_input]
		pass
		
func _unhandled_input(event) -> void:
	_remap_key(event)
	_check_key(event)

func update_labels(idx:int,tmp_input:String):
	var arr = self.get_children()
	if (idx > -1 and idx < arr.size()):
		(arr[idx] as Button).text = tmp_input;
		(arr[idx] as Button).set_pressed_no_signal(false);

func _on_button_0_pressed() -> void:
	self.changing_input_index = 0
	
func _on_button_1_pressed() -> void:
	self.changing_input_index = 1
