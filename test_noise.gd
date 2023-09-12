tool
extends Node2D

var GRID_SIZE = 512
var REAL_SIZE = 6400

onready var noise_1 = OpenSimplexNoise.new()
onready var noise_2 = OpenSimplexNoise.new()

var minimap = Image.new()
var grad_img = TextureRect.new()
var grad_data
var grad_size

export (StreamTexture) var ImgTexture = preload("res://grad_map_tex.png") setget set_img_tex
export (int,0,1024,1) var noise1_seed = 0 setget set_noise1_seed
export (int,0,9,1) var noise1_octaves = 4 setget set_noise1_octaves
export (int,0,64,1) var noise1_period = 16 setget set_noise1_period
export (float,0,10,.05) var noise1_lacunarity = 1.5 setget set_noise1_lacunarity
export (float,0,1,.05) var noise1_persistence = 0.75 setget set_noise1_persistence

export (int,0,1024,1) var noise2_seed = 12 setget set_noise2_seed
export (int,0,9,1) var noise2_octaves = 4 setget set_noise2_octaves
export (int,0,64,1) var noise2_period = 64 setget set_noise2_period
export (float,0,2,.05) var noise2_lacunarity = 0.75 setget set_noise2_lacunarity
export (float,0,1,.05) var noise2_persistence = 0.25 setget set_noise2_persistence

enum BIOME {SAND, DIRT_1, DIRT_2, GREEN_1, GREEN_2, GREEN_3, ROCK_1, ROCK_2, ROCK_3, WATER}
const COLOR = [
	"#fee254", 
	"#fdc742", 
	"#fb9a26", 
	"#a2d730", 
	"#74bd25", 
	"#228f12", 
	"#796e5e", 
	"#a4998b",
	"#c9bfb2",
	"#1f4677"]

var ready = false

func _ready():
	ready = true

	grad_img.texture = ImgTexture
	grad_data = grad_img.texture.get_data()
	grad_size = grad_img.texture.get_size()
	minimap.create(GRID_SIZE, GRID_SIZE, false, Image.FORMAT_RGBA8)
	
	noise_1.seed = noise1_seed
	noise_1.octaves = noise1_octaves
	noise_1.period = noise1_period
	noise_1.lacunarity = noise1_lacunarity
	noise_1.persistence = noise1_persistence

	noise_2.seed = noise2_seed
	noise_2.octaves = noise2_octaves
	noise_2.period = noise2_period
	noise_2.lacunarity = noise2_lacunarity
	noise_2.persistence = noise2_persistence
	
	_generateMap()

func _generateMap():
	var noise
	var biome
	var color
	
	grad_data.lock()
	minimap.lock()
	
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			noise = get_noise(x, y)
			biome = get_biome(noise)
			minimap.set_pixel(x, y, Color(COLOR[biome]))

	var tex = ImageTexture.new()
	tex.create_from_image(minimap)
	$Minimap.set_texture(tex)
	minimap.unlock()
	grad_data.unlock()

func get_noise(x, y):
	var n_1 = (1 + noise_1.get_noise_2d(float(x), float(y))) / 2.0
	var n_2 = (1 + noise_2.get_noise_2d(float(x), float(y))) / 2.0
	var r = grad_data.get_pixel(x * grad_size.x / GRID_SIZE, y * grad_size.y / GRID_SIZE).r
	return (n_1 + n_2*.25 - r)
#	return (n_1 + n_2*.48 - r)

func set_img_tex(val):
	ImgTexture = val
	if ready:
		grad_img.texture = ImgTexture
		grad_data = grad_img.texture.get_data()
		grad_size = grad_img.texture.get_size()
		_generateMap()

func set_noise1_seed(val):
	noise1_seed = val
	if ready:
		noise_1.seed = val
		_generateMap()

func set_noise1_octaves(val):
	noise1_octaves = val
	if ready:
		noise_1.octaves = val
		_generateMap()

func set_noise1_period(val):
	noise1_period = val
	if ready:
		noise_1.period = val
		_generateMap()

func set_noise1_lacunarity(val):
	noise1_lacunarity = val
	if ready:
		noise_1.lacunarity = val
		_generateMap()

func set_noise1_persistence(val):
	noise1_persistence = val
	if ready:
		noise_1.persistence = val
		_generateMap()

func set_noise2_seed(val):
	noise2_seed = val
	if ready:
		noise_2.seed = val
		_generateMap()

func set_noise2_octaves(val):
	noise2_octaves = val
	if ready:
		noise_2.octaves = val
		_generateMap()

func set_noise2_period(val):
	noise2_period = val
	if ready:
		noise_2.period = val
		_generateMap()

func set_noise2_lacunarity(val):
	noise2_lacunarity = val
	if ready:
		noise_2.lacunarity = val
		_generateMap()

func set_noise2_persistence(val):
	noise2_persistence = val
	if ready:
		noise_2.persistence = val
		_generateMap()

func get_biome(noise):
		if noise < 0.085:
			return BIOME.WATER
		elif noise < 0.105:
			return BIOME.SAND
		elif noise < 0.12:
			return BIOME.DIRT_1
		elif noise < 0.20:
			return BIOME.DIRT_2
		elif noise < 0.35:
			return BIOME.GREEN_1
		elif noise < 0.55:
			return BIOME.GREEN_2
		elif noise < 0.65:
			return BIOME.GREEN_3
		elif noise < 0.91:
			return BIOME.ROCK_1
		elif noise < 0.92:
			return BIOME.ROCK_2
		else:
			return BIOME.ROCK_3
