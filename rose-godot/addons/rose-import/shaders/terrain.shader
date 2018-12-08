shader_type spatial;
render_mode unshaded;

uniform sampler2D layer1;
uniform sampler2D layer2;
uniform int rotation = 0;

void fragment() {
    vec2 rotated_uv2 = UV2;
    
    if (rotation == 2) { // Flip Horizontal
        rotated_uv2 = vec2(1.0 - UV2.x, UV2.y);
    }
    if (rotation == 3) { // Flip Vertical
        rotated_uv2 = vec2(UV2.x, 1.0 - UV2.y);
    }
    if (rotation == 4) { // Flip
        rotated_uv2 = vec2(1.0 - UV2.x, 1.0 - UV2.y);
    }
    if (rotation == 5) { // Clockwise 90
        rotated_uv2 = vec2(-UV2.y, UV2.x)
    }
    if (rotation == 6) { // CounterClockwise 90
        rotated_uv2 = vec2(UV2.y, -UV2.x)
    }
    
    vec4 layer1_tex = texture(layer1, UV);
    vec4 layer2_tex = texture(layer2, rotated_uv2);
    
    ALBEDO = mix(layer1_tex.rgba, layer2_tex.rgba, layer2_tex.a).rgb;
}