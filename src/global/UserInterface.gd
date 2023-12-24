extends Node

func disable_button(button: BaseButton, disabled: bool) -> void:
	button.set_disabled(disabled)
	if disabled:
		button.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	else:
		button.mouse_default_cursor_shape = Control.CURSOR_ARROW
