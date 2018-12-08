tool
extends Spatial

enum Gender {
    MALE,
    FEMALE,
}

enum State {
    NONE = 0,
    IDLE = 1 << 0,
    WALKING = 1 << 1,
    RUNNING = 1 << 2,
}

export (Gender) var gender = Gender.MALE setget set_gender
export (State) var state = State.NONE setget set_state

const MALE_SKELETON = preload("res://character/male.zmd")
const FEMALE_SKELETON = preload("res://character/female.zmd")

var defaults = {
    "male": {
        "face": "res://character/face/face1_male.zms",
        "hair": "res://character/hair/hair1_male.zms",
        "body": "res://character/body/body1_male.zms",
        "legs": "res://character/legs/legs1_male.zms",
        "hands": "res://character/hands/hands1_male.zms",
        "feet": "res://character/feet/feet1_male.zms",
    },
    "female": {
        "face": "res://character/face/face1_female.zms",
        "hair": "res://character/hair/hair1_female.zms",
        "body": "res://character/body/body1_female.zms",
        "legs": "res://character/legs/legs1_female.zms",
        "hands": "res://character/hands/hands1_female.zms",
        "feet": "res://character/feet/feet1_female.zms",
    }
}

var animations = {
    "male": [
        ["Empty Run", "res://character/animations/empty_run_male.zmo"],
        ["Empty Idle", "res://character/animations/empty_idle_male.zmo"],
    ],
    "female": [
        ["Empty Run", "res://character/animations/empty_run_female.zmo"],
        ["Empty Idle", "res://character/animations/empty_idle_female.zmo"],
    ],
}

func _ready():
    pass

func _process(delta):
    pass
    
func set_gender(g):
    if !g:
        gender = Gender.MALE

    if g != Gender.MALE and g != Gender.FEMALE:
        printerr("Attempted to set invalid gender: %s" % g)
        gender = Gender.MALE
        return
    
    gender = g
    
    var skel = null
    var key = ""
    
    match self.gender:
        Gender.MALE:
            skel = MALE_SKELETON.instance().get_node("Skeleton").duplicate()
            key = "male"
        Gender.FEMALE:
            skel = FEMALE_SKELETON.instance().get_node("Skeleton").duplicate()
            key = "female"
    
    if(self.has_node("Skeleton")):
        $Skeleton.replace_by(skel, true)
        $Skeleton/Head/Face.mesh = load(defaults[key]["face"])
        $Skeleton/Head/Hair.mesh = load(defaults[key]["hair"])
        $Skeleton/Body.mesh = load(defaults[key]["body"])
        $Skeleton/Legs.mesh = load(defaults[key]["legs"])
        $Skeleton/Hands.mesh = load(defaults[key]["hands"])
        $Skeleton/Feet.mesh = load(defaults[key]["feet"])
        
        $AnimationPlayer.replace_by(AnimationPlayer.new())
        for anim_data in animations[key]:
            $AnimationPlayer.add_animation(anim_data[0], load(anim_data[1]))
    
func set_state(s):
    state = s
    
    if(self.has_node("AnimationPlayer")):
        $AnimationPlayer.stop(true)

        match state:
            State.IDLE:
                $AnimationPlayer.play("Empty Idle")
            State.RUNNING:
                $AnimationPlayer.play("Empty Run")
