extends Node

#Controls
var edge_pan: bool = false
var camera_pan_speed: float = 0.25
var camera_edge_pan_speed: float = 0.25

#Graphics
enum shadow_qualities {OFF, LOW, MEDIUM, HIGH}
var shadow_quality: shadow_qualities = shadow_qualities.MEDIUM
signal shadow_quality_changed
var shadow_distance: float = 100.0
signal shadow_distance_changed
