uniform vec2 light_position;
uniform vec3 light_color;
uniform float light_size;

vec4 effect(vec4 originalColor, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec2 aux = light_position - screen_coords.xy;
	float distance = length(aux);
  float attenuation = 1.0 / (1.0 + 5.0 * (distance / (light_size * 20)))﻿;
	vec4 color = vec4(attenuation, attenuation, attenuation, pow(attenuation, 3)) * vec4(light_color / 255.0, 1);

	return color;
}
