extends Panel



@onready var file_menu : PopupMenu = %File
@onready var help_menu : PopupMenu = %Help
@onready var create_new_project_dialog : ConfirmationDialog = $dialogs/CreateNewProject
@onready var export_as_dialog : FileDialog = $dialogs/ExportDialog
@onready var open_project_dialog : FileDialog = $dialogs/OpenProjectDialog
@onready var save_project_dialog : FileDialog = $dialogs/SaveProject
@onready var export_format_dialog : ConfirmationDialog = $dialogs/ExportFormatDialog
func _ready() -> void:
	setup_file_menu()
	setup_help_menu()
	
func setup_file_menu():
	var file_menu_items := {
		"New...": "new_file",
		"Open...": "open_file",
		"Save as...": "save_file_as",
		"Export as...": "export_file_as",
		"Quit": "quit",
	}
	var i  := 0
	for item in file_menu_items:
		if item == "Recent projects":
			pass
		else:
			_set_menu_shortcut(file_menu_items[item], file_menu, i, item)
			#print(item)
		i += 1
	file_menu.id_pressed.connect(file_menu_id_pressed)
		
func setup_help_menu():
	var help_menu_items := {
		'Report a bug':'report_a_bug'
	}
	var i := 0
	for item in help_menu_items:
		_set_menu_shortcut(help_menu_items[item],help_menu, i, item)
		i+=1
	help_menu.id_pressed.connect(help_menu_id_pressed)
func file_menu_id_pressed(id: int):
	print(id)
	GlobalAnimationTimeline.update_current_cadr(GlobalCanvas.current_layer, GlobalAnimationTimeline.current_cadr)
	match id:
		0:
			create_new_project()
		3:
			export_as()
		2:
			save_as_project()
		1:
			open_project()
		4:
			get_tree().quit()
			

			
func help_menu_id_pressed(id:int):
	print_debug('ID',id)
	match id:
		0:
			OS.shell_open('https://t.me/c/3210495796/2')
		#1:
		#2:
			
func _set_menu_shortcut(
	action: StringName,
	menu: PopupMenu,
	index: int,
	text: String,
	is_check = false,
	echo = false,
	icon: Texture2D = null
):
	if not action.is_empty():
		if is_check:
			menu.add_check_item(text,index)
		else:
			menu.add_item(text,index)
			
	else:
		var shortcut = Shortcut.new()
		var event = InputEventAction.new()
		event.action = action
		shortcut.events.append(event)
		if is_check:
			menu.add_check_shortcut(shortcut,index)
		else:
			menu.add_shortcut(shortcut, index, false, echo)
	if is_instance_valid(icon):
		menu.set_item_icon(index, icon)
		
		
func create_new_project():
	create_new_project_dialog.show()
func export_as():
	export_format_dialog.show()
func open_project():
	open_project_dialog.show()

func _on_export_dialog_dir_selected(dir: String) -> void:
	Global.folder_save = dir
	GlobalAnimationTimeline.save_button_pressed.emit()
	

func save_as_project():
	save_project_dialog.show()


func _on_open_project_dialog_dir_selected(dir: String) -> void:
	print(dir)
	#Global.open_project.emit(dir)



func _on_save_project_dir_selected(dir: String) -> void:
	Global.save_project(dir)


func _on_export_format_dialog_confirmed() -> void:
	export_as_dialog.show()


func _on_open_project_dialog_file_selected(path: String) -> void:
	if Global.unzip_file(path, 'user://dd'):
		Global.open_project.emit('user://dd')
