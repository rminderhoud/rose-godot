extends Camera

export(NodePath) var look_at = null
export(float) var distance = 2.5

const MIN_DISTANCE = 1.0
const MAX_DISTANCE = 10.0

var pitch = 0.0 
var yaw = 0.0

func _ready():
    pass

func _process(delta):
    var target = get_node(look_at)
    
    pitch = clamp(pitch, -PI/2 + 0.01, PI/2 - 0.01)
    distance = clamp(distance, MIN_DISTANCE, MAX_DISTANCE)
    
    var pos = Vector3(0, 0, -distance)
    pos = pos.rotated(Vector3(1, 0, 0), pitch)
    pos = pos.rotated(Vector3(0, 1, 0), yaw)
    self.global_transform.origin = target.global_transform.origin + pos
    self.look_at(target.global_transform.origin, Vector3(0, 1, 0))
    