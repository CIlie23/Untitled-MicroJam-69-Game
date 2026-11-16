shader_type canvas_item;

uniform vec4 soul_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform float white_threshold = 0.95;

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (all(greaterThan(pixel.rgb, vec3(white_threshold)))) {
		COLOR.rgb = soul_color.rgb;
	}
}
