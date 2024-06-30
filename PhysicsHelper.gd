extends Node
class_name PhysicsHelper

static func calculateArcVelocity(point_a: Vector3, point_b: Vector3, arc_height: float, gravity) -> Vector3:
	
	var velocity: Vector3 = Vector3(0,0,0)
	
	if arc_height > 0:
		print_debug("Sir you put in the wrong arc_height. It's positive. Shit dont work.")
	
	var displacement: Vector3 = point_b - point_a
	
	var time_up = sqrt(-2 * arc_height / float(gravity))
	var time_down = sqrt(2 * (displacement.y - arc_height) / float(gravity))
	
	if is_nan(time_down):
		time_down = 0
	
	velocity.y = -sqrt(-2 * gravity * arc_height)
	velocity.y = -velocity.y
	velocity.x = displacement.x / float(time_up + time_down) 
	velocity.z = displacement.z / float(time_up + time_down)
	
	return velocity
