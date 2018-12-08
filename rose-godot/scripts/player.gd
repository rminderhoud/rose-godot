extends Spatial

const CLICK_DISTANCE = 1000

var _mouse_right_down = false
var _check_click = false
var _click_pos = null

var _move = false
var _move_to = false
var _move_from = false

func _process(delta):
    var cur_anim = $Character/AnimationPlayer.current_animation;
    if(self._move):
        self.move()
        if not cur_anim == "Empty Run":
            $Character/AnimationPlayer.play("Empty Run")
    else:
        if not cur_anim == "Empty Idle":
            $Character/AnimationPlayer.play("Empty Idle")
        

func _physics_process(delta):
    if self._check_click:
        var from = $Camera.project_ray_origin(self._click_pos)
        var to = from + $Camera.project_ray_normal(self._click_pos) * CLICK_DISTANCE
        var space_state = get_world().direct_space_state
        var result = space_state.intersect_ray(from, to)
        
        if result:
            if not result.collider == self:
                self._move = true
                self._move_to = result.position
                self._move_from = self.global_transform.origin
                self.look_at(Vector3(self._move_to.x, self.global_transform.origin.y, self._move_to.z), Vector3(0, 1, 0))
            
        self._check_click = false
        self._click_pos = null
        
func _unhandled_input(event):
    if event is InputEventMouseButton:
        match event.button_index:
            BUTTON_WHEEL_DOWN:
                $Camera.distance += 1.5
            BUTTON_WHEEL_UP:
                $Camera.distance -= 1.5
            BUTTON_RIGHT:
                _mouse_right_down = event.pressed
            BUTTON_LEFT:
                if event.pressed:
                    self._check_click = true
                    self._click_pos = event.position

    if event is InputEventMouseMotion:
        if _mouse_right_down:
            $Camera.yaw += -event.relative.x / 100
            $Camera.pitch += event.relative.y / 100

func move():
    self._move = true
    
    var cur_pos = self.global_transform.origin
    
    var speed = 5
    var dir = (self._move_to - cur_pos).normalized() * speed * self.get_physics_process_delta_time()
    dir.y = -9.8
    
    var dist_to_floor = $FloorCast.get_collision_point().distance_squared_to(cur_pos)
    if dist_to_floor <= 0.01:
        dir.y = 0

    # TODO: Replace this with own movement function to avoid the stops
    var collision = self.move_and_collide(dir)
    
    if collision:
        var is_floor = collision.normal.dot(Vector3(0, 1, 0)) >= cos(45)
        if not is_floor:
            self._move = false
    
    if dir.length() <= 0.01:
        self._move = false
    
    print("Moving")