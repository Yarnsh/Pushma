shader_type canvas_item;

uniform sampler2D palette_r : filter_nearest;
uniform sampler2D palette_g : filter_nearest;
uniform sampler2D palette_b : filter_nearest;

uniform float alpha : hint_range(0.0, 1.0);

void fragment() {
	vec4 sp = texture(TEXTURE, UV);
	
	// calculate pixel luminosity (https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color)
	//float lum = (sp.r * 0.299) + (sp.g * 0.587) + (sp.b * 0.114);
	float lum = max(sp.r, max(sp.g, sp.b));
	
	vec3 p1 = texture(palette_r, vec2(lum, 0.0)).rgb * sp.r;
	if (sp.g > sp.r) {
		p1 = texture(palette_g, vec2(lum, 0.0)).rgb * sp.g;
	}
	if (sp.b > sp.g && sp.b > sp.r) {
		p1 = texture(palette_b, vec2(lum, 0.0)).rgb * sp.b;
	}
	
	COLOR.rgb = p1;
	COLOR.a = alpha * sp.a;
}