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
	if !Engine.is_editor_hint():
		generate_square_body( Vector2(275,75), 100 )

func _process(_delta):
	# mouse drag
	if pressed:
		if selection != null:
			selection.position          = get_global_mouse_position()
			selection.previous_position = get_global_mouse_position()

func _physics_process(delta):

#	(5) for all vertices - update velocity by doing vi = vi + deltat*wi*fext(xi)
	for node in get_children():
		if !(node as PointMass).is_static:
			var vertex = (node as PointMass)
			vertex.velocity = vertex.velocity + delta * vertex.w * vertex.gravity
#	
#   (6) dampVelocites(v1,...vN) - we ommitted this step
#
#	(7) for all verticies i find projected point assuming no collisions pi = xi + deltat vi
	for node in get_children():
		if !(node as PointMass).is_static:
			var vertex = (node as PointMass)
			vertex.projected_point = vertex.position + delta * vertex.velocity
#
#  (8 - 11) for all velocities generate collision constraints (xi -> pi)
	for link in constraints:
		if !(link.from as PointMass).is_static and !(link.to as PointMass).is_static:
			
			var grad = (link.from.position - link.to.position) / (link.from.position - link.to.position).length()
			var deltaX1 = (-1)* (link.from.w /( link.from.w + link.to.w)) * link.c_param * grad
			var deltaX2 = ( link.to.w /( link.from.w + link.to.w )) * link.c_param * grad
			
			link.from.position = link.from.position + deltaX1
			link.to.position = link.to.position + deltaX1

#	(12) i (15) for all velocities generate collision constraints (xi -> pi)
	for node in get_children():
		if !(node as PointMass).is_static:
			var vertex = (node as PointMass)
			vertex.velocity = (vertex.projected_point - vertex.position) / delta
			vertex.position = vertex.projected_point
	pass

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
				new_point_mass.is_static = true
			add_child(new_point_mass)
			vertexes.append(new_point_mass)
	for i in range(10):
		for j in range(10):
			if j < 9:
				add_spring(get_child(get_child_count()-100 + i*10+j ), get_child(get_child_count()-100 + i*10+(j+1) ))
			if i < 9:
				add_spring(get_child(get_child_count()-100 + i*10+j ), get_child(get_child_count()-100 + (i+1)*10+j ))
