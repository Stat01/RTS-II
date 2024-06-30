extends Node2D

const source_folder_path = "res://ImageExports/"
const destination_folder_path = "res://ImageExports/out/"
const suffix = ".tres"

const filenames = [
	"ground"
]

var tres_array = []
var saved = false

func _ready():
	for filename in filenames:
		var tres = load(source_folder_path + filename + suffix)
		print("Loading ", tres)
		tres_array.append(tres)

func _process(_delta):
	if tres_array == null:
		return
	if tres_array[filenames.size() - 1] == null:
		return
	if saved == false:
		for tres in tres_array:
			var resource_name = tres.resource_path.trim_prefix(source_folder_path).trim_suffix(suffix)
			var filename = resource_name + ".png"
			print("Saving %s..." % filename)
			var img = tres.get_image()
			img.clear_mipmaps()
			var _x = img.save_png(destination_folder_path + filename)
			print("Saved.")
		saved = true
		print("Done.")
