shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// 1. Sepia Tone
uniform float sepia_intensity : hint_range(0.0, 1.0) = 1.0;
uniform vec3 sepia_tint : source_color = vec3(1.2, 1.05, 0.9);

// 2. Film Grain & Vignette
uniform float grain_amount : hint_range(0.0, 0.5) = 0.08;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 1;

// 3. Dirt & Scratches
uniform float scratch_amount : hint_range(0.9, 1.0) = 0.995;

// 4. Floating Dust (Particles)
uniform float dust_density : hint_range(0.0, 1.0) = 0.99;
uniform float dust_speed : hint_range(0.0, 5.0) = 0.5;

// Pseudo-random generator
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec3 color = texture(screen_texture, uv).rgb;

    // 1. Apply Sepia Filter
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 sepia_color = vec3(luminance) * sepia_tint;
    color = mix(color, sepia_color, sepia_intensity);

    // 2. Apply Film Grain
    float grain = rand(uv + TIME);
    color -= grain * grain_amount;

    // 3. Apply Vignette (Darkened edges)
    float dist = distance(uv, vec2(0.5));
    color *= smoothstep(0.1, vignette_intensity, 0.8 - dist);

    // 4. Apply Vertical Film Scratches
    // Scratches jump around based on time
    float scratch = step(scratch_amount, rand(vec2(uv.x * 10.0, floor(TIME * 12.0))));
    color += scratch * 0.15; // Add light vertical streaks

    // 5. Apply Floating Dust (Like old camera lens dust)
    // Moves slowly upwards and slightly sideways
  //  vec2 scrolling_uv = uv + vec2(TIME * 0.02, TIME * -0.05) * dust_speed;
 //  float dust_noise = rand(floor(scrolling_uv * 200.0));
  //  float dust = step(dust_density, dust_noise);

    // Make dust flicker
   // dust *= sin(TIME * 4.0 + rand(floor(scrolling_uv * 200.0)) * 10.0) * 0.5 + 0.5;

    // Add dust to the final color (warm, subtle spots)
 //   color += dust * vec3(0.9, 0.8, 0.6) * 0.6;

    COLOR = vec4(color, 1.0);
}