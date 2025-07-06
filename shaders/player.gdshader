shader_type canvas_item;
uniform float intensity = 1.0;


void fragment() {
	COLOR *= vec4(1.0 * intensity, 1.0 / intensity, 1.0 / intensity,1);
}