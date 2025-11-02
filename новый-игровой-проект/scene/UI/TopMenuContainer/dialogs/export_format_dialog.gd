extends ConfirmationDialog


func _ready() -> void:
	$OptionButton.selected = Global.state_export_to

func _on_option_button_item_selected(index: int) -> void:
	Global.state_export_to = index
