tool
extends Reference

var width = null
var height = null
var grid_count = null
var scale = null
var heights = null
var min_height = null
var max_height = null

func _init():
    self.width = 0
    self.height = 0
    self.grid_count = 0
    self.scale = 0.0
    self.heights = []
    self.min_height = NAN
    self.max_height = NAN

func read(f):
    self.width = f.get_32()
    self.height = f.get_32()
    self.grid_count = f.get_32()
    self.scale = f.get_float()
    
    for h in range(self.height):
        var row = []
        for w in range(self.width):
            var height = f.get_float()
            row.append(height)
            
            if is_nan(self.min_height) or (height < self.min_height):
                self.min_height = height
            
            if is_nan(self.max_height) or (height > self.max_height):
                self.max_height = height
                
        self.heights.append(row)
        
    # NOTE: File contains more data that we currently don't use