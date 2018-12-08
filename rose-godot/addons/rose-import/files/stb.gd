tool
extends Reference

var columns = null
var rows = null

func _init():
    self.columns = []
    self.rows = []
    
func read(f):
    var identifier = f.get_fstring(3)
    var version = f.get_fstring(1)
    var offset = f.get_32()
    
    var row_count = f.get_32()
    var col_count = f.get_32()
    
    # f.seek(offset)
    
    var row_height = f.get_32()
    for i in range(col_count + 1):
        var col_width = f.get_16()
    
    for i in range(col_count):
        self.columns.push_back(f.get_string_u16())
    var id_col_name = f.get_string_u16()
    
    for i in range(row_count - 1):
        var row_name = f.get_string_u16()
    
    for i in range(row_count - 1):
        var row = []
        for j in range(col_count - 1):
            row.push_back(f.get_string_u16())
        self.rows.push_back(row)    
    