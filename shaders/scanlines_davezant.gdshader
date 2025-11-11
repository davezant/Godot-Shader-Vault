shader_type canvas_item;

uniform sampler2D screen_texture;

uniform float scan_density = 220.0;      
uniform float thickness = 0.35;        
uniform float intensity = 0.55;        
uniform float flicker_strength = 0.03;   
uniform float speed = 0.0;             

uniform float vignette_strength = 0.7;  
uniform float rgb_offset = 1.2;        
uniform float chroma_power = 0.7;      
uniform float curvature = 0.15;        
uniform float wave_speed = 3.0;         
uniform float wave_amplitude = 0.003;   

uniform vec4 tint = vec4(0.545, 0.271, 0.074, 1.0);

render_mode blend_mix, unshaded;

vec2 curve_uv(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    uv.x *= 1.0 + (uv.y * uv.y) * curvature;
    uv.y *= 1.0 + (uv.x * uv.x) * curvature;
    uv = (uv + 1.0) * 0.5;
    return uv;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    uv = curve_uv(uv);

    // onda horizontal sutil
    uv.y += sin(uv.x * 50.0 + TIME * wave_speed) * wave_amplitude;

    // separação RGB animada
    float off = rgb_offset / 1024.0;
    float shake = sin(TIME * 50.0) * 0.5 + sin(TIME * 13.0) * 0.5;
    off += shake * 0.0005;

    vec3 col;
    col.r = texture(screen_texture, uv + vec2(-off * chroma_power, 0.0)).r;
    col.g = texture(screen_texture, uv).g;
    col.b = texture(screen_texture, uv + vec2(off * chroma_power, 0.0)).b;

    float t = TIME * speed / max(1.0, scan_density);
    float pos = uv.y * scan_density + t;
    float line = smoothstep(0.5 - thickness * 0.5, 0.5 + thickness * 0.5, abs(fract(pos) - 0.5));
    float scan_mod = 1.0 - line * intensity;

    float flicker = 1.0 + sin(TIME * 120.0) * flicker_strength;

    col *= scan_mod * flicker * tint.rgb;

    vec2 centered = SCREEN_UV * 2.0 - 1.0;
    float radius = length(centered);
    float vignette = smoothstep(1.0 - vignette_strength, 1.0, radius);
    col *= 1.0 - vignette;

    float alpha = 0.6; // ajuste entre 0 (totalmente transparente) e 1 (opaco)
    COLOR = vec4(col, alpha);
}
