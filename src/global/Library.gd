extends Node

signal installed()

enum Type { Nightly, Release }
enum Platform { LINUX32, LINUX64, MAC, WINDOWS32, WINDOWS64 }

@onready var downloader := $Downloader as HTTPRequest

var prefered_platform : Platform = Platform.WINDOWS64

var download_queue : Array[Dictionary] = []
var is_busy := false
var date := Time.get_date_string_from_system(true)

var _bin : Array = []


func has_pixelorama(tag: String, platform: Platform) -> bool:
	return DirAccess.dir_exists_absolute(
		"user://bin/release/" + tag + "/" + get_platform_as_string(prefered_platform) + "/"
	)


func add_to_download_queue(type: Type, platform: Platform, tag: String, url: String) -> void:
	download_queue.append(
		{
			"type": type,
			"platform": platform,
			"tag": tag,
			"url": url,
		}
	)
	if !is_busy:
		download_next()


func download_next() -> void:
	if download_queue.size() == 0 or is_busy:
		return

	is_busy = true

	var item := download_queue[0]


	downloader.download_file = "user://bin/file" + get_os_extension(item.type == Type.Nightly)
	DirAccess.make_dir_recursive_absolute(downloader.download_file.get_base_dir())

	print("Downloading from '", item.url, "' into '", downloader.download_file, "'")

	var request_err := downloader.request(item.url)
	if request_err != OK:
		printerr("There was an error requesting that! Try again!")
		return

	downloader.request_completed.connect(
		func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
			print(result, " ", response_code)
			_bin.append(body)
			, CONNECT_ONE_SHOT
	)
	await downloader.request_completed

	print("Completed downloading, please wait while we install your pixelorama!")

	var body : PackedByteArray = _bin[0]

	var save_path: String
	if item.type == Type.Nightly:
		save_path = "user://bin/nightly/" + date + "/" + get_platform_as_string(prefered_platform) + "/"
	elif item.type == Type.Release:
		save_path = "user://bin/release/" + item.tag + "/" + get_platform_as_string(prefered_platform) + "/"
	DirAccess.make_dir_recursive_absolute(save_path)

	print("Installing...")

	unizp(save_path, downloader.download_file)
	#
	#var file: FileAccess
	#for f: String in zip.get_files():
		#var path = save_path + f.get_base_dir() + "/"
		#if !f.get_base_dir().is_empty():
			#DirAccess.make_dir_recursive_absolute(path)
		#print(path + f)
		#file = FileAccess.open(save_path + f, FileAccess.WRITE)
		#file.store_buffer(zip.read_file(f))

	#file.close()
	#zip.close()

	DirAccess.remove_absolute(downloader.download_file)

	print_rich("[color=green]All done![/color]")

	download_queue.remove_at(0)
	is_busy = false
	installed.emit()
	_bin.clear()
	if download_queue.size() > 0:
		download_next()

func unizp(into: String, archive_path: String) -> void:
	var zip := ZIPReader.new()
	var err := zip.open(archive_path)
	if err != OK:
		printerr("Could not complete your install please try again!")
		printerr("Error: ", err)
		return

	var file: FileAccess
	for f: String in zip.get_files():
		var path = into + f.get_base_dir() + "/"
		if !f.get_base_dir().is_empty():
			DirAccess.make_dir_recursive_absolute(path)
		print(path + f)
		if f.ends_with("/"):
			continue
		file = FileAccess.open(into + f, FileAccess.WRITE)
		file.store_buffer(zip.read_file(f))
		if (into + f).ends_with(".gz"):
			await unizp(into, into + f)
			DirAccess.remove_absolute(into + f)

	file.close()
	zip.close()


func get_platform_extension(platform: Platform) -> String:
	if platform in [Platform.LINUX32, Platform.LINUX64]:
		return ""
	if platform == Platform.MAC:
		return ""
	return ".exe"



func get_os_extension(is_nightly:= false) -> String:
	# The nightly only has .zip files
	if is_nightly:
		return ".zip"

	var os := OS.get_name()
	match os:
		"Windows":
			return ".zip"
		"OSX":
			return ".dmg"
		"X11":
			return ".AppImage"
	return ""


func get_platform_as_string(platform: Platform) -> String:
	return Platform.keys()[platform]
