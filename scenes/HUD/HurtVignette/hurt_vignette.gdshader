shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.75, 0.0, 0.05, 1.0);
uniform float inner : hint_range(0.0, 1.0) = 0.35;
uniform float outer : hint_range(0.0, 1.5) = 0.75;

void fragment() {
	float edge = smoothstep(inner, outer, distance(UV, vec2(0.5)));
	COLOR = vec4(tint.rgb, edge * intensity);
}
