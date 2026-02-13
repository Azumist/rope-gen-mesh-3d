@tool
class_name RopeData extends Resource

enum MeshType {
    EXTRUDED_CYLINDER = 0, ## Generates a cylindrical mesh extruded along the rope path. Best for cables, wires, and traditional rope appearance.
    MESH_SEGMENT_ARRAY = 1, ## Repeats a custom mesh along the rope path. Best for chains, decorative elements, or specialized rope designs.
}

enum ColShapeType {
    TRIMESH = 0, ## Triangle mesh collision. Most accurate but more expensive.
    SINGLE_CONVEX = 1, ## Simple convex hull. Faster than trimesh but less accurate.
    SIMPLIFIED_CONVEX = 2, ## Simplified convex hull. Fastest option, least accurate.
}

## Points representing the whole path of the rope. 
## Individual meshes between each of the point will be generated.
var points: PackedVector3Array:
    set(value):
        points = value
        emit_changed()

## The material applied to all generated meshes.
var material: Material:
    set(value):
        material = value
        emit_changed()

## The render layer(s) that the rope instances will be drawn on. Use this to control which cameras can see the rope.
var visibility_layers: int = 1:
    set(value):
        visibility_layers = value
        emit_changed()
    
## When enabled, creates a single combined mesh for the entire rope. 
## When disabled, creates separate meshes between each pair of points, allowing for individual culling.
var single_mesh: bool = true:
    set(value):
        single_mesh = value
        emit_changed()

## Determines how the rope geometry is generated.
var mesh_type: MeshType = MeshType.EXTRUDED_CYLINDER:
    set(value):
        mesh_type = value
        emit_changed()
        notify_property_list_changed()

## Controls how much the rope sags between points, simulating the natural droop of a suspended cable. The offset is applied to intermediate vertices between the points.
var sag_offset: Vector3 = Vector3(0.0, -0.1, 0.0):
    set(value):
        sag_offset = value
        emit_changed()

## When enabled, the [member sag_offset] is applied in the node's local coordinate system rather than world space. Useful when the rope container rotates or moves, but the sag should always point in global space direction.
var sag_keep_local_space: bool = false:
    set(value):
        sag_keep_local_space = value
        emit_changed()

## The radius of the extruded cylinder. Controls the thickness of the rope.
var ext_radius: float = 0.5:
    set(value):
        ext_radius = value
        emit_changed()

## Number of edges around the cylinder's circumference. Higher values create a smoother, more circular cross-section but increase vertex count.
var ext_u_segments: int = 16:
    set(value):
        ext_u_segments = value
        emit_changed()

## Number of rings along each segment of the cylinder mesh. Higher values create smoother curves but increase vertex count.
var ext_v_segments: int = 8:
    set(value):
        ext_v_segments = value
        emit_changed()

## Shifts the texture coordinates in UV space.
var tex_uv_translation: Vector2 = Vector2.ZERO:
    set(value):
        tex_uv_translation = value
        emit_changed()

## The pivot point for UV rotation. (0.5, 0.5) rotates around the center, (0, 0) around the top left corner.
var tex_uv_rotation_origin: Vector2 = Vector2(0.5, 0.5):
    set(value):
        tex_uv_rotation_origin = value
        emit_changed()

## Rotates the texture coordinates clockwise by the specified angle in degrees.
var tex_uv_rotation_angle_degrees: float = 0.0:
    set(value):
        tex_uv_rotation_angle_degrees = value
        emit_changed()

## Scales the texture coordinates. Values greater than 1.0 to tile the texture, less than 1.0 stretch it.    
var tex_uv_scale: Vector2 = Vector2.ONE:
    set(value):
        tex_uv_scale = value
        emit_changed()

## The mesh that will be repeated along the rope path. Allows to create chains, links, or any custom repeating geometry.
var mse_mesh: ArrayMesh:
    set(value):
        mse_mesh = value
        emit_changed()

## Defines which direction the mesh "points" or faces forward along the rope path. This is necessary when the mesh's origin is not centered.
var mse_forward_axis: Vector3 = Vector3.RIGHT:
    set(value):
        mse_forward_axis = value
        emit_changed()

## Multiplier for the spacing between repeated mesh instances. Values less than 1.0 create tighter spacing, greater than 1.0 create looser spacing.
var mse_instance_spacing: float = 1.0:
    set(value):
        mse_instance_spacing = value
        emit_changed()

## Rotation applied to each mesh instance in their local space. Allows for further fine-tuning of repeated elements.
var mse_rotation_degrees: Vector3 = Vector3.ZERO:
    set(value):
        mse_rotation_degrees = value
        emit_changed()

## Controls how quickly the mesh transitions to lower LOD versions. Lower values = faster transitions.
var lod_bias: float = 0.02:
    set(value):
        lod_bias = value
        emit_changed()

## Distance at which the first LOD level appears.
var lod_level1_distance: float = 2.0:
    set(value):
        lod_level1_distance = value
        emit_changed()

## Distance at which the second LOD level appears.
var lod_level2_distance: float = 10.0:
    set(value):
        lod_level2_distance = value
        emit_changed()

## Distance at which the third (lowest detail) LOD level appears.
var lod_level3_distance: float = 40.0:
    set(value):
        lod_level3_distance = value
        emit_changed()

## Enables physics collision generation. When enabled, a StaticBody3D is created for each mesh segment (or a single body if [member single_mesh] is true).
var use_collisions: bool = false:
    set(value):
        use_collisions = value
        notify_property_list_changed()
        emit_changed()

## Generated collision shape type for the rope's StaticBody.
## **WARNING!** Right now prefer ColShapeType.TRIMESH when [member mesh_type] is set to [member ColShapeType.EXTRUDED_CYLINDER], other types will introduce collision errors.
var col_shape_type: ColShapeType = ColShapeType.TRIMESH:
    set(value):
        col_shape_type = value
        emit_changed()

## The physics layer this collision object is in.
var col_collision_layer: int = 0:
    set(value):
        col_collision_layer = value
        emit_changed()

## The physics layer(s) this collision object scans for collisions.
var col_collision_mask: int = 0:
    set(value):
        col_collision_mask = value
        emit_changed()

func _get_property_list() -> Array:
    var properties = []

    properties.append({
        "name": "material",
        "type": TYPE_OBJECT,
        "usage": PROPERTY_USAGE_DEFAULT,
        "hint": PROPERTY_HINT_RESOURCE_TYPE,
        "hint_string": "Material"
    })

    properties.append({
        "name": "single_mesh",
        "type": TYPE_BOOL,
        "usage": PROPERTY_USAGE_DEFAULT,
    })

    #region Mesh type
    properties.append({
        "name": "mesh_type",
        "type": TYPE_INT,
        "usage": PROPERTY_USAGE_DEFAULT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": "Extruded Cylinder,Mesh Segment Array"
    })

    if mesh_type == MeshType.EXTRUDED_CYLINDER:
        properties.append({
            "name": "Extruded Cylinder",
            "type": TYPE_NIL,
            "usage": PROPERTY_USAGE_GROUP,
            "hint_string": "ext_" # prefix
        })

        properties.append({
            "name": "ext_radius",
            "type": TYPE_FLOAT,
            "usage": PROPERTY_USAGE_DEFAULT
        })

        properties.append({
            "name": "ext_u_segments",
            "type": TYPE_INT,
            "usage": PROPERTY_USAGE_DEFAULT
        })

        properties.append({
            "name": "ext_v_segments",
            "type": TYPE_INT,
            "usage": PROPERTY_USAGE_DEFAULT
        })

        properties.append({
            "name": "Texture mapping",
            "type": TYPE_NIL,
            "usage": PROPERTY_USAGE_SUBGROUP,
            "hint_string": "tex_" # prefix
        })

        properties.append({
            "name": "tex_uv_translation",
            "type": TYPE_VECTOR2,
            "usage": PROPERTY_USAGE_DEFAULT
        })

        properties.append({
            "name": "tex_uv_rotation_origin",
            "type": TYPE_VECTOR2,
            "usage": PROPERTY_USAGE_DEFAULT
        })

        properties.append({
            "name": "tex_uv_rotation_angle_degrees",
            "type": TYPE_FLOAT,
            "usage": PROPERTY_USAGE_DEFAULT,
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": "-360.0,360.0,0.1" # min, max, step
        })

        properties.append({
            "name": "tex_uv_scale",
            "type": TYPE_VECTOR2,
            "usage": PROPERTY_USAGE_DEFAULT
        })
    elif mesh_type == MeshType.MESH_SEGMENT_ARRAY:
        properties.append({
            "name": "Mesh Segment Array",
            "type": TYPE_NIL,
            "usage": PROPERTY_USAGE_GROUP,
            "hint_string": "mse_" # prefix
        })

        properties.append({
            "name": "mse_mesh",
            "type": TYPE_OBJECT,
            "usage": PROPERTY_USAGE_DEFAULT,
            "hint": PROPERTY_HINT_RESOURCE_TYPE,
            "hint_string": "ArrayMesh"
        })

        properties.append({
            "name": "mse_instance_spacing",
            "type": TYPE_FLOAT,
            "usage": PROPERTY_USAGE_DEFAULT
        })
        
        properties.append({
            "name": "mse_forward_axis",
            "type": TYPE_VECTOR3,
            "usage": PROPERTY_USAGE_DEFAULT
        })
        
        properties.append({
            "name": "mse_rotation_degrees",
            "type": TYPE_VECTOR3,
            "usage": PROPERTY_USAGE_DEFAULT
        })
    #endregion

    #region Sag
    properties.append({
        "name": "Sag",
        "type": TYPE_NIL,
        "usage": PROPERTY_USAGE_GROUP,
        "hint_string": "sag_"
    })

    properties.append({
        "name": "sag_offset",
        "type": TYPE_VECTOR3,
        "usage": PROPERTY_USAGE_DEFAULT
    })

    properties.append({
        "name": "sag_keep_local_space",
        "type": TYPE_BOOL,
        "usage": PROPERTY_USAGE_DEFAULT,
    })
    #endregion

    #region Collisions
    properties.append({
        "name": "use_collisions",
        "type": TYPE_BOOL,
        "usage": PROPERTY_USAGE_DEFAULT,
    })
    
    if use_collisions:
        properties.append({
            "name": "Collision",
            "type": TYPE_NIL,
            "usage": PROPERTY_USAGE_GROUP,
            "hint_string": "col_"
        })

        properties.append({
            "name": "col_shape_type",
            "type": TYPE_INT,
            "hint": PROPERTY_HINT_ENUM,
            "hint_string": "Trimesh:0,Simple Convex:1,Simplified Convex:2",
            "usage": PROPERTY_USAGE_DEFAULT,
            "class_name": "shape_type"
        })

        properties.append({
            "name": "col_collision_layer",
            "type": TYPE_INT,
            "hint": PROPERTY_HINT_LAYERS_3D_PHYSICS,
            "usage": PROPERTY_USAGE_DEFAULT,
            "class_name": "collision_layer"
        })

        properties.append({
            "name": "col_collision_mask",
            "type": TYPE_INT,
            "hint": PROPERTY_HINT_LAYERS_3D_PHYSICS,
            "usage": PROPERTY_USAGE_DEFAULT,
            "class_name": "collision_mask"
        })
    #endregion

    #region Level of Detail
    properties.append({
        "name": "Level of Detail",
        "type": TYPE_NIL,
        "usage": PROPERTY_USAGE_GROUP,
        "hint_string": "lod_" # prefix
    })

    properties.append({
        "name": "lod_bias",
        "type": TYPE_FLOAT,
        "usage": PROPERTY_USAGE_DEFAULT,
        "hint": PROPERTY_HINT_RANGE,
        "hint_string": "0.001, 128.0.0,0.001" # min, max, step
    })

    properties.append({
        "name": "lod_level1_distance",
        "type": TYPE_FLOAT,
        "usage": PROPERTY_USAGE_DEFAULT
    })

    properties.append({
        "name": "lod_level2_distance",
        "type": TYPE_FLOAT,
        "usage": PROPERTY_USAGE_DEFAULT
    })

    properties.append({
        "name": "lod_level3_distance",
        "type": TYPE_FLOAT,
        "usage": PROPERTY_USAGE_DEFAULT
    })
    #endregion

    properties.append({
        "name": "points",
        "type": TYPE_PACKED_VECTOR3_ARRAY,
        "usage": PROPERTY_USAGE_DEFAULT
    })

    properties.append({
        "name": "visibility_layers",
        "type": TYPE_INT,
        "usage": PROPERTY_USAGE_DEFAULT,
        "hint": PROPERTY_HINT_LAYERS_3D_RENDER
    })
    
    return properties