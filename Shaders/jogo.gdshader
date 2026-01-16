shader_type canvas_item;

// This line is the magic fix. It grabs the game screen behind the ColorRect.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment(){
    // OLD CODE (Wrong): vec4 color = texture(TEXTURE, UV);
    // NEW CODE (Correct): Read from the screen texture using SCREEN_UV
    vec4 color = texture(screen_texture, SCREEN_UV);

    // Grain
    float noise = (random(UV + vec2(TIME, 0.0)) - 0.5) * grain_amount;

    // Vignette
    vec2 uv = UV - 0.5;
    float vignette = 1.0 - dot(uv, uv) * vignette_intensity;
    color.rgb *= mix(1.0, vignette, vignette_opacity);

    // Apply Grain
    color.rgb += noise;

    COLOR = color;
}