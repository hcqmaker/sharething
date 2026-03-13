extends Control

#--------------------------------------------------
# 设置和读取配置部分的代码
# 注意！！！！！ 选择【运行当前场景F6】
# 路径是 C:\Users\[用户名字]\AppData\Roaming\Godot\app_userdata\Input Helper\setting.cfg
const config_path = "user://setting.cfg"
"""
文件内容大概是这样
[control]
key_maps="key:G;joypad:13;joypad:0|-1.000000;key:H"
my_jump0="G"
my_jump1="H"
"""

var config:ConfigFile = ConfigFile.new()

func _get_key_value(key:String, def:Variant = "") -> Variant: 
	return config.get_value("control", key, def)
	
func _set_key_value(key:String, val:Variant) -> void: 
	config.set_value("control", key, val);
	config.save(config_path)
	
#--------------------------------------------------
## 这里对应的是 【项目】【项目设置】【输入映射】
const action_name:String = "my_jump"	# 对应 输入映射 中的名字
const key_input_map:String = "key_maps"

func _ready() -> void:
	$Label.text = action_name
	config.load(config_path)
	
	var des = _get_key_value(key_input_map)
	if (des != ""): InputHelper.deserialize_inputs_for_action(action_name,des)
	
	# !!!!! 警告这里要注意设置的处理【如果开始没有给设定，容易出现，空设定，直接就。。。。】
	#var array = InputHelper.get_keyboard_inputs_for_action(action_name) # 限定在鼠标键盘的话
	#var array = InputHelper.get_joypad_inputs_for_action(action_name) # 限定在手柄的话
	var array = InputMap.action_get_events(action_name)
	var input0 = InputHelper.get_label_for_input(array[0]);
	var input1 = InputHelper.get_label_for_input(array[1]);
	var device0 = InputHelper.get_device_from_event(array[0])
	var device1 = InputHelper.get_device_from_event(array[1])
	
	$Button0.text = input0; $Button1.text = input1; $device0.text = device0; $device1.text = device1;
	$Button0.toggle_mode = true;$Button1.toggle_mode = true;
	$tip0.visible = false;$tip1.visible = false;
	
func _remap_key(event) -> void:
	if not $Button0.button_pressed and not $Button1.button_pressed: return
	
	var did_update: bool = false
	var input_index:int = 0; # 限定第1个键位
	var label:Label = null;
	var btn:Button = null;

	if event.is_pressed():

		if ($Button0.button_pressed and (event is InputEventKey or event is InputEventMouseButton)):
			InputHelper.replace_keyboard_input_at_index(action_name, input_index, event, true)
			label = $device0; btn = $Button0; $tip0.visible = false;
			did_update = true;
		
		if ($Button1.button_pressed and (event is InputEventJoypadButton or event is InputEventJoypadMotion)):
			InputHelper.replace_joypad_input_at_index(action_name, input_index, event, true)
			label = $device1; btn = $Button1; $tip1.visible = false;
			did_update = true;
			
	if did_update:
		accept_event()
		label.text = InputHelper.get_device_from_event(event)
		btn.text = InputHelper.get_label_for_input(event); 
		btn.set_pressed_no_signal(false);btn.visible = true;
		_set_key_value(key_input_map, InputHelper.serialize_inputs_for_action(action_name))
			
func _check_key(event) -> void:
	if (Input.is_action_just_pressed(action_name)):
		var tmp_input = InputHelper.get_label_for_input(event)
		$label_log.text = " Pressed %s: key: %s"%[action_name, tmp_input]

func _input(event: InputEvent) -> void:
	_remap_key(event)
	
func _unhandled_input(event) -> void:
	_check_key(event)

func _on_button_0_pressed() -> void:
	$Button0.visible = false;
	$tip0.visible = true;

func _on_button_1_pressed() -> void:
	$Button1.visible = false;
	$tip1.visible = true;
