shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// 1. Hologram Color & Tint
uniform vec3 hologram_color : source_color = vec3(0.0, 0.8, 1.0); // Classic Cyan
uniform float tint_intensity : hint_range(0.0, 1.0) = 0.9;

// 2. Hologram Waves (Soft rolling projection lines)
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;
uniform float wave_frequency : hint_range(0.0, 20.0) = 15.0;
uniform float wave_amplitude : hint_range(0.0, 0.5) = 0.15;

// 3. Pixelation
uniform float pixel_size : hint_range(1.0, 20.0) = 3.0;

// 4. Glitch & Aberration (Kept very subtle for the hologram feel)
uniform float glitch_intensity : hint_range(0.0, 0.05) = 0.005;

// 5. Particles (Floating projection dust)
uniform float particle_density : hint_range(0.0, 1.0) = 0.99;
uniform vec3 particle_color : source_color = vec3(0.6, 1.0, 1.0);
uniform float particle_glow : hint_range(1.0, 10.0) = 2.5;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 size = vec2(textureSize(screen_texture, 0)) / pixel_size;
    vec2 pixelated_uv = round(SCREEN_UV * size) / size;

    // Subtle horizontal glitch to simulate projection instability
    float glitch = (rand(vec2(TIME * 5.0, pixelated_uv.y)) - 0.5) * glitch_intensity;
    pixelated_uv.x += glitch * step(0.95, rand(vec2(TIME, pixelated_uv.y)));

    // Chromatic aberration (Subtle)
    float r = texture(screen_texture, pixelated_uv + vec2(0.002, 0.0)).r;
    float g = texture(screen_texture, pixelated_uv).g;
    float b = texture(screen_texture, pixelated_uv - vec2(0.002, 0.0)).b;
    vec3 color = vec3(r, g, b);

    // Apply Hologram Tint (Convert to grayscale, then multiply by hologram color)
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 tinted_color = vec3(luminance) * hologram_color;
    color = mix(color, tinted_color, tint_intensity);

    // Add Soft Hologram Scanning Waves
    float wave = sin(pixelated_uv.y * wave_frequency - TIME * wave_speed) * 0.5 + 0.5;
    color += hologram_color * wave * wave_amplitude;

    // Hologram Flicker (Overall brightness instability)
    float flicker = rand(vec2(TIME, 0.0));
    color *= 0.9 + (flicker * 0.1);

    // Generate Particles (Floating holographic dots)
   // vec2 scrolling_uv = pixelated_uv + vec2(TIME * 0.02, TIME * 0.08);
   // float p_noise = rand(floor(scrolling_uv * 120.0));
  //  float particle = step(particle_density, p_noise);
    
    // Make particles blink
  //  particle *= sin(TIME * 5.0 + rand(floor(scrolling_uv * 120.0)) * 10.0) * 0.5 + 0.5;
    
    // Add particles to final color
  //  color += particle * particle_color * particle_glow;

    COLOR = vec4(color, 1.0);
}