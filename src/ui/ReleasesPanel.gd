extends PanelContainer

const RELEASE_CARD = preload("res://src/ui/Cards/ReleaseCard.tscn")
const RELEASES_URL := "https://api.github.com/repos/Orama-Interactive/Pixelorama/releases"

var cache : Array = []

@onready var info_requester: HTTPRequest = $InfoRequester
@onready var cards: VBoxContainer = $Content/Cards


func _ready() -> void:
	# Request the releases
	print("downloading cache, please wait..")
	info_requester.request(RELEASES_URL)
	var storage := []
	info_requester.request_completed.connect(_on_info_requested.bind(storage), CONNECT_ONE_SHOT)
	await info_requester.request_completed
	cache = storage[0]
	print("Downloaded release cache on ", Library.date)

	var items = []

	for i in cache:
		var item = {
			"url": i.get("url", "url"),
			"html": i.get("html_url", "url"),
			"name": i.get("name", ""),
			"tag": i.get("tag_name", "v0.0") as String,
			"published_at": i.get("published_at", "01:01:01:01") as String,
			"assets": {
				"linux32": "",
				"linux64": "",
				"mac": "",
				"windows32": "",
				"windows64": ""
			}
		}

		for asset: Dictionary in i.get("assets", []) as Array:
			if !items.has(asset.name):
				items.append(asset.name)
				print(asset.name)

			var linux32files = [
				"Pixelorama.Linux-32bit.tar.gz",
				"linux-32bit.tar.gz",
				"pixelorama-linux-32.zip",
				"Pixelorama.v0.7.Linux.32-bit.zip",
				"Pixelorama.Linux.32-bit.zip"
			]
			var linux64files = [
				"Pixelorama.Linux-64bit.tar.gz",
				"linux-64bit.tar.gz",
				"Pixelorama.v0.7.Linux.64-bit.zip",
				"Pixelorama.Linux.64-bit.zip",
			]
			var macfiles = [
				"Pixelorama.Mac.dmg",
				"Pixelorama.v0.7.Mac.64-bit.zip",
				"Pixelorama.Mac.64-bit.zip"
			]
			var windows32files = [
				"Pixelorama.Windows-32bit.zip",
				"windows-32bit.zip",
				"Pixelorama.v0.7.Windows.32-bit.zip",
				"Pixelorama.Windows.32-bit.zip"
			]
			var windows64files = [
				"Pixelorama.Windows-64bit.zip",
				"windows-64bit.zip",
				"Pixelorama.v0.7.Windows.64-bit.zip",
				"Pixelorama.Windows.64-bit.zip",
				"Pixelorama.Windows.zip",
				"Pixelorama.zip",
			]

			if asset.name in linux32files:
				item.assets.linux32 = asset.get("browser_download_url")
			if asset.name in linux64files:
				item.assets.linux64 = asset.get("browser_download_url")
			if asset.name in macfiles:
				item.assets.mac = asset.get("browser_download_url")
			if asset.name in windows32files:
				item.assets.windows32 = asset.get("browser_download_url")
			if asset.name in windows64files:
				item.assets.windows64 = asset.get("browser_download_url")

			#match asset.get("name", "") as String:
#
				#"Pixelorama.Linux-64bit.tar.gz", "linux-64bit.tar.gz", "Pixelorama.v0.7.Linux.64-bit.zip":
					#item.assets.linux64 = asset.get("browser_download_url")
				## We dont support rasberryPI
				##"Pixelorama.Linux-RPI4.tar.gz":
					##pass
				#"Pixelorama.Mac.dmg", "Pixelorama.v0.7.Mac.64-bit.zip":
					#item.assets.mac = asset.get("browser_download_url")
				#"Pixelorama.Windows-32bit.zip", "windows-32bit.zip", "Pixelorama.v0.7.Windows.32-bit.zip":
					#item.assets.windows32 = asset.get("browser_download_url")
				#"Pixelorama.Windows-64bit.zip", "windows-64bit.zip":
					#item.assets.windows64 = asset.get("browser_download_url")

		var card := RELEASE_CARD.instantiate()
		card.item = item
		cards.add_child(card)


func update_ui() -> void:
	for child in cards.get_children():
		child.update_ui()


func _on_info_requested(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, storage: Array) -> void:
	var string := body.get_string_from_utf8()
	storage.append(str_to_var(string))

