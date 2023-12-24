extends PanelContainer

const RELEASES_URL := "https://api.github.com/repos/Orama-Interactive/Pixelorama/releases"

var cache : Array = []

@onready var info_requester: HTTPRequest = $InfoRequester

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
			match asset.get("name", "") as String:
				"Pixelorama.Linux-32bit.tar.gz":
					item.assets.linux32 = asset.get("browser_download_url")
				"Pixelorama.Linux-64bit.tar.gz":
					item.assets.linux64 = asset.get("browser_download_url")
				# We dont support rasberryPI
				#"Pixelorama.Linux-RPI4.tar.gz":
					#pass
				"Pixelorama.Mac.dmg":
					item.assets.mac = asset.get("browser_download_url")
				"Pixelorama.Windows-32bit.zip":
					item.assets.windows32 = asset.get("browser_download_url")
				"Pixelorama.Windows-64bit.zip":
					item.assets.windows64 = asset.get("browser_download_url")
		items.append(item)
	print(items[0])



func _on_info_requested(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, storage: Array) -> void:
	var string := body.get_string_from_utf8()
	storage.append(str_to_var(string))

