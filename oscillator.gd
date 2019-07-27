#tool
extends Node2D

# mouse drag params 
var selectionDistance := 10.0
var pressed           :bool= false
var selection:PointMass
var prev_mouse_position

var link_object  := load("res://spring.tscn") as PackedScene
var point_object := load("res://node.tscn") as PackedScene

var velocities: Array = []
var inverse_masses: Array = []
var positions: Array = []

var vertexes:    Array = []
var constraints: Array = []

func _ready():
#	if !Engine.is_editor_hint():
	generate_square_body( Vector2(275,75), 300 )
	get_child(4).position += Vector2(-10,0)

func _process(_delta):
	# mouse drag
	if pressed:
		if selection != null:
			selection.position          = get_global_mouse_position()
			selection.previous_position = get_global_mouse_position()

func _physics_process(delta):

#	(5) for all vertices - update velocity by doing vi = vi + deltat*wi*fext(xi)
	for node in get_children():
			var vertex = (node as PointMass)
			vertex.velocity += delta * vertex.w * vertex.gravity
#			vertex.velocity *= 0.4
#			vertex.velocity -= vertex.velocity * 0.1
#	
#   (6) dampVelocites(v1,...vN) - we ommitted this step

#
#	(7) for all verticies i find projected point assuming no collisions pi = xi + deltat vi
	for node in get_children():
			var vertex = (node as PointMass)
			vertex.projected_point = vertex.position + delta * vertex.velocity
#
#  (8 - 11) for all velocities generate collision constraints (xi -> pi)
	for i in range(1):
		for link in constraints:
			var d = link.from.projected_point - link.to.projected_point
#			print("d ", d, " c ", link.c_param)
			var grad = link.c_param - d
			
			link.from.deltaX1 += 0.5 * grad
			link.to.deltaX1 += -0.5 * grad 
			
	for link in constraints:
		link.from.projected_point += link.from.deltaX1
		link.to.projected_point += link.to.deltaX1

#	for node in get_children():
#		for i in range( node.neighbors.size() ):
#			var grad = node.neighbors[i].position - node.position
#			node.deltax1 = -0.5 * grad
#			node.deltax2 = 0.5 * grad

#	(12) i (15) for all velocities generate collision constraints (xi -> pi)
	for node in get_children():
		var vertex = (node as PointMass)
		vertex.velocity = (vertex.projected_point - vertex.position) 
		vertex.velocity -= vertex.velocity * 0.1
		vertex.previous_position = vertex.position
#		vertex.position = vertex.projected_point
		vertex.position += (vertex.projected_point - vertex.position) * delta
#		vertex.position += vertex.velocity * delta

func add_spring( node_1, node_2 ):
	var link = link_object.instance()
	link.initialize( node_1, node_2 )
	$"../springs".add_child( link )
	constraints.append(link)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			pressed   = true
			selection = null
			for node in get_children():
				if event.position.distance_to(node.position) < selectionDistance:
					selection = node
		else:
			pressed   = false
			selection = null

func generate_square_body( square_position:Vector2, size:float ):
	for i in range(10): 
		for j in range(10):
			var new_point_mass := point_object.instance() as PointMass
			new_point_mass.position = Vector2( j/4.0, i/4.0 ) * size + square_position
			if i == 0:
				new_point_mass.is_static = false
			add_child(new_point_mass)
			vertexes.append(new_point_mass)
	for i in range(10):
		for j in range(10):
			if j < 9:
				add_spring(get_child(get_child_count()-100 + i*10+j ), get_child(get_child_count()-100 + i*10+(j+1) ))
			if i < 9:
				add_spring(get_child(get_child_count()-100 + i*10+j ), get_child(get_child_count()-100 + (i+1)*10+j ))

#	for i in range(10): 
#		for j in range(10):
#			var new_point_mass := point_object.instance() as PointMass
#			new_point_mass.position = Vector2( j/4.0, i/4.0 ) * size + square_position
#			if i == 0:
#				new_point_mass.is_static = false
#			add_child(new_point_mass)
#			vertexes.append(new_point_mass)
#	for i in range(10):
#		for j in range(10):
#			if j < 9:
#				add_spring(get_child(get_child_count()-100 + i*10+j ), get_child(get_child_count()-100 + i*10+(j+1) ))
#			if i < 9:
#				add_spring(get_child(get_child_count()-100 + i*10+j ), get_child(get_child_count()-100 + (i+1)*10+j ))
