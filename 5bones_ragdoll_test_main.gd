extends Control

var base_character = preload("res://OpenBotv2-MannyQuin.blend")

# Called when the node enters the scene tree for the first time.
var ragdoll
var character_visible = true
var no_rotate_bones = ["DEF-spine"]

var current_joint_type = 1
func _ready():
	_create_ragdoll()
	#PhysicalBone3ddUtils.save(ragdoll)

func _create_ragdoll():
	if ragdoll:
		ragdoll.queue_free()
		ragdoll = null
	# why create new one?,sometime broke if change joint_type after start_simulation
	ragdoll = base_character.instantiate()
	find_child("Node3D").add_child(ragdoll)
	update_character_visible()
	_add_bones()
	
func _add_bones():
	var skeleton = _get_ragdoll().find_child("Skeleton3D")
	
	var body_physical_bone = PhysicalBone3ddUtils.add_bone(skeleton,"DEF-spine","DEF-spine.005",0.75,0.2,false)
	var right_leg_physical_bone = PhysicalBone3ddUtils.add_bone(skeleton,"DEF-thigh.R","DEF-toe.R",0.9,0.1)
	var left_leg_physical_bone = PhysicalBone3ddUtils.add_bone(skeleton,"DEF-thigh.L","DEF-toe.L",0.9,0.1)
	var right_arm_physical_bone = PhysicalBone3ddUtils.add_bone(skeleton,"DEF-upper_arm.R","DEF-f_middle.01.R",0.9,0.2)
	var left_arm_phhysical_bone = PhysicalBone3ddUtils.add_bone(skeleton,"DEF-upper_arm.L","DEF-f_middle.01.L",0.9,0.2)
	var head_physical_bone = PhysicalBone3ddUtils.add_bone(skeleton,"DEF-spine.005","DEF-spine.006",4,0.8,true ,Vector3.ZERO,2) 
	var joints =[body_physical_bone,right_leg_physical_bone,left_leg_physical_bone,right_arm_physical_bone,left_arm_phhysical_bone,head_physical_bone]
	for joint in joints:
		joint.joint_type = current_joint_type
		if current_joint_type == PhysicalBone3D.JOINT_TYPE_6DOF:
			var enable_x = find_child("Dof6x").button_pressed
			var enable_y = find_child("Dof6y").button_pressed
			var enable_z = find_child("Dof6z").button_pressed
			PhysicalBone3ddUtils.set_dof6_limit_enabled(joint,enable_x,enable_y,enable_z)
	
	
	
func _get_ragdoll():
	return ragdoll
	
func _process(delta):
	pass




func start_simulation(joint_type:int) -> void:
	find_child("StandButton").disabled = false
	var old_ragdoll = _get_ragdoll()
	var old_skeleton = find_skeleton3d(old_ragdoll)
	old_skeleton.physical_bones_stop_simulation()
	current_joint_type = joint_type
	_create_ragdoll()
	
	var ragdoll_node3d = _get_ragdoll()
	var skeleton = find_skeleton3d(ragdoll_node3d)
	skeleton.physical_bones_start_simulation()

func _on_stand_pressed():
	var old_ragdoll = _get_ragdoll()
	if not old_ragdoll:
		var old_skeleton = find_skeleton3d(old_ragdoll)
		old_skeleton.physical_bones_stop_simulation()
	
	_create_ragdoll()
	find_child("StandButton").disabled = true

static func find_skeleton3d(node:Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
		
	for child in node.get_children():
		var s = find_skeleton3d(child)
		if s is Skeleton3D:
			return s
	return null


	
func update_character_visible():
	var doll = _get_ragdoll()
	var meshes = find_nodes_by_type(doll,"MeshInstance3D")
	for mesh in meshes:
		mesh.visible = character_visible
		
static func find_nodes_by_type(node:Node,type:String,list:Array = [],ignore_self:bool = false):
	if ignore_self == false and node.is_class(type):
		list.append(node)
		
	for child in node.get_children():
		find_nodes_by_type(child,type,list)
			
	return list


func _on_pin_pressed():
	start_simulation(1)

func _on_hingi_pressed():
	start_simulation(3)


func _on_dof_6_pressed():
	start_simulation(5)



func _on_visible_button_toggled(toggled_on):
	character_visible = toggled_on
	update_character_visible()
