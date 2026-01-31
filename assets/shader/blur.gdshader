shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform float inner_radius : hint_range(0.0, 1.0) = 0.3;
uniform vec3 edge_color : source_color = vec3(0.4, 0.6, 1.0);
uniform float color_blend : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	float x = abs(UV.r - 0.5) * 2.0;
	float y = abs(UV.g - 0.5) * 2.0;
	float dist = sqrt(x*x + y*y);
	
	float blur_factor = smoothstep(inner_radius, 1.0, dist);
	float blur_size = blur_factor * blur_amount * 0.003;
	
	vec4 color = vec4(0.0);
	
	color += texture(screen_texture, SCREEN_UV + vec2(-blur_size, -blur_size));
	color += texture(screen_texture, SCREEN_UV + vec2(0.0, -blur_size));
	color += texture(screen_texture, SCREEN_UV + vec2(blur_size, -blur_size));
	color += texture(screen_texture, SCREEN_UV + vec2(-blur_size, 0.0));
	color += texture(screen_texture, SCREEN_UV);
	color += texture(screen_texture, SCREEN_UV + vec2(blur_size, 0.0));
	color += texture(screen_texture, SCREEN_UV + vec2(-blur_size, blur_size));
	color += texture(screen_texture, SCREEN_UV + vec2(0.0, blur_size));
	color += texture(screen_texture, SCREEN_UV + vec2(blur_size, blur_size));
	
	color = color / 9.0;
	
	color.rgb = mix(color.rgb, edge_color, blur_factor * color_blend);
	
	COLOR = color;
}