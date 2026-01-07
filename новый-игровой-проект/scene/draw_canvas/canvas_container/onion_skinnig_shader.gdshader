shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float alpha;
uniform sampler2D canvas_texture;

void fragment() {
	vec2 uv = UV;
    vec4 current_color = texture(canvas_texture, uv);
	if (current_color.a != 0.0){
		COLOR = vec4(color.rgb, min(alpha, current_color.a * color.a));
	} else {
		COLOR = current_color;
	}
	
}

