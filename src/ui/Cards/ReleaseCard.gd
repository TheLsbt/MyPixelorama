extends PanelContainer

var item: Dictionary

@onready var title_label: Label = $Content/Title
@onready var assets_label: Label = $Content/DownloadLaunch/Assets
@onready var uninstall_btn: Button = $Content/DownloadLaunch/Uninstall
@onready var launch_btn: Button = $Content/DownloadLaunch/Launch


func _ready() -> void:
	update_ui()


func update_ui() -> void:
	UserInterface.disable_button(uninstall_btn, false)
	UserInterface.disable_button(launch_btn, false)
	if !item:
		title_label.text = "Error"
		UserInterface.disable_button(uninstall_btn, true)
		UserInterface.disable_button(launch_btn, true)
		return

	title_label.text = get_title()

	if !item.assets.get(item.assets.keys()[Library.prefered_platform]).is_empty():
		assets_label.text = "Asset(s) available for your platform."
	else:
		assets_label.text = "No assets available for your platform."
		UserInterface.disable_button(uninstall_btn, true)
		UserInterface.disable_button(launch_btn, true)

	if Library.has_pixelorama(item.tag, Library.prefered_platform):
		launch_btn.text = "Launch"
	else:
		UserInterface.disable_button(uninstall_btn, true)
		launch_btn.text = "Download"


func get_title() -> String:
	var t := ""
	if !item.name.is_empty():
		t += item.name + " • "
	t += item.tag + " • "
	var published_at: String = item.published_at
	t += published_at.split("T")[0]
	return t


func _on_launch_pressed() -> void:
	if Library.has_pixelorama(item.tag, Library.prefered_platform):
		print("Luanch!")
	else:
		launch_btn.text = "Downloading.."
		Library.add_to_download_queue(
			Library.Type.Release,
			Library.prefered_platform,
			item.tag,
			item.assets[item.assets.keys()[Library.prefered_platform]]
		)
