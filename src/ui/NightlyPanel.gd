extends PanelContainer
class_name NightlyPanel

enum Platform { LINUX32, LINUX64, MAC, WINDOWS32, WINDOWS64 }

@onready var uninstall_button: Button = $Content/PreviousContainer/Uninstall
@onready var launch_button: Button = $Content/PreviousContainer/Launch
@onready var today_label: Label = $Content/PreviousContainer/TodayLabel


func update_ui() -> void:
	today_label.text = Time.get_date_string_from_system(true)

	if is_up_to_date():
		launch_button.text = "Launch"
		launch_button.tooltip_text = "Launch 'user://bin/nightly/" + today_label.text + "/" + Library.get_platform_as_string(Library.prefered_platform) + "/Pixelorama" + Library.get_platform_extension(Library.prefered_platform)
		UserInterface.disable_button(uninstall_button, false)
	else:
		launch_button.text = "Install"
		UserInterface.disable_button(uninstall_button, true)

	if Library.prefered_platform in [
		Library.Platform.LINUX64, Library.Platform.MAC, Library.Platform.WINDOWS64
	]:
		UserInterface.disable_button(launch_button, false)
	else:
		UserInterface.disable_button(launch_button, true)

func is_up_to_date() -> bool:
	var today := Time.get_date_string_from_system(true)
	if DirAccess.dir_exists_absolute("user://bin/nightly/" + today + "/" + Library.get_platform_as_string(Library.prefered_platform)):
		return true
	return false


func get_nightly_url(platform: Platform) -> String:
	match platform:
		Library.Platform.WINDOWS64:
			return "https://nightly.link/Orama-Interactive/Pixelorama/workflows/dev-desktop-builds/master/Windows-64bit.zip"
		Library.Platform.LINUX64:
			return "https://nightly.link/Orama-Interactive/Pixelorama/workflows/dev-desktop-builds/master/Linux-64bit.zip"
		Library.Platform.MAC:
			return "https://nightly.link/Orama-Interactive/Pixelorama/workflows/dev-desktop-builds/master/Mac.zip"
	return ""


func _on_launch_pressed() -> void:
	if is_up_to_date():
		pass
		#Library.launch_pixelorama()
	else:
		var url := get_nightly_url(Library.get("prefered_platform") as int)
		if url.is_empty():
			printerr("Theres no nightly for this Platform and arc")
			return
		Library.add_to_download_queue(Library.Type.Nightly, Library.prefered_platform, "nightly", url)
		launch_button.text = "Installing.."
		UserInterface.disable_button(launch_button, true)


func _exit_tree() -> void:
	if DirAccess.get_files_at("user://bin/nightly/" + today_label.text).is_empty():
		DirAccess.remove_absolute("user://bin/nightly/" + today_label.text)
