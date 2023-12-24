extends PanelContainer

@onready var nightly_panel := %NightlyPanel as NightlyPanel
@onready var platform_selector: OptionButton = %PlatformSelector
@onready var releases_panel: PanelContainer = %ReleasesPanel

var releases_url := "https://api.github.com/repos/Orama-Interactive/Pixelorama/releases"



func _ready() -> void:
	platform_selector.select(Library.prefered_platform)
	Library.installed.connect(_on_libray_installed)
	update_ui()


func update_ui() -> void:
	nightly_panel.update_ui()
	releases_panel.update_ui()


func _on_libray_installed() -> void:
	print("Updating ui")
	update_ui()


func _on_platform_selector_item_selected(index: int) -> void:
	Library.prefered_platform = index
	update_ui()
