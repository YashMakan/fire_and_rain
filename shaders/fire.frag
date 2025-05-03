#version 460 core
precision highp float;
#include <flutter/runtime_effect.glsl>

// ─── Uniforms supplied by Flame ────────────────────────────────────
uniform vec2  resolution;   // slot 0,1   –  component size   (px)
uniform float u_time;       // slot 2     –  seconds since spawn
uniform float u_speed;      // slot 3     –  current vertical speed (+y = down)

// ─── Constants you can tweak ───────────────────────────────────────
const int   SHAPE_OCTAVES   = 5;
const int   TEXTURE_OCTAVES = 6;
const float STRETCH_STRENGTH = 0.45;   // tail length
const float MAX_SPEED_TAIL   = 600.0;  // speed (px/s) that maxes the tail

// ─── Noise helpers (unchanged) ─────────────────────────────────────
float random(vec2 st){
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

float noise(vec2 st){
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i+vec2(1.,0.));
    float c = random(i+vec2(0.,1.));
    float d = random(i+vec2(1.,1.));
    vec2 u = f*f*(3.-2.*f);
    return mix(a,b,u.x)+(c-a)*u.y*(1.-u.x)+(d-b)*u.y*u.x;
}

float fbmShape(vec2 st,float persistence,float lacunarity){
    float total=0.,freq=1.,amp=1.,maxV=0.;
    for(int i=0;i<SHAPE_OCTAVES;i++){
        total+=noise(st*freq)*amp;
        maxV+=amp;
        amp*=persistence;
        freq*=lacunarity;
    }
    return maxV>0.?total/maxV:0.;
}

float fbmTexture(vec2 st,float persistence,float lacunarity){
    float total=0.,freq=1.,amp=1.,maxV=0.;
    for(int i=0;i<TEXTURE_OCTAVES;i++){
        total+=noise(st*freq)*amp;
        maxV+=amp;
        amp*=persistence;
        freq*=lacunarity;
    }
    return maxV>0.?total/maxV:0.;
}

// ─── Fragment entry point ──────────────────────────────────────────
layout(location = 0) out vec4 fragColor;

void main(){
    // Normalised ‑1‥+1 space (origin at centre)
    vec2 uv  = FlutterFragCoord().xy / resolution;
    vec2 pos = (uv - 0.5) * 2.0;

    // ── Gravity stretch (upstream = negative‑y) ────────────────────
    float speedNorm = clamp(u_speed / MAX_SPEED_TAIL, 0.0, 1.0);
    float stretch   = 1.0
        - STRETCH_STRENGTH * speedNorm * smoothstep(0.0, -1.0, pos.y);
    vec2 gpos = vec2(pos.x, pos.y * stretch);      // ← use gpos henceforth

    // Distance from centre BEFORE distortion (for fall‑off)
    float undistorted_dist = length(gpos);

    // ── Parameters ────────────────────────────────────────────────
    float time_scale        = 0.8;
    float displacement_scale= 0.3;
    float texture_scale     = 0.6;
    float persistence       = 0.5;
    float lacunarity        = 2.0;

    // Radial fall‑off for noise
    float noise_falloff = 1.0 - smoothstep(0.5, 0.9, undistorted_dist);

    // ── Shape distortion ──────────────────────────────────────────
    vec2 base_off = vec2(
        fbmShape(gpos*1.5 + vec2(u_time*time_scale*0.3,0.), persistence, lacunarity) - 0.5,
        fbmShape(gpos*1.5 + vec2(0., u_time*time_scale*0.4), persistence, lacunarity) - 0.5
    );
    vec2 distortion = base_off * noise_falloff;
    vec2 dpos       = gpos + distortion * displacement_scale;
    float dist      = length(dpos);

    // ── Flicker & radius ──────────────────────────────────────────
    float baseRadius   = 0.35;
    float globalFlick  = 0.03 * sin(u_time * 6.0);
    float localFlick   = noise(gpos*4.0 + u_time*time_scale*2.0);
    float flicker      = globalFlick + 0.08 * (localFlick - 0.5)*noise_falloff;
    float radius       = baseRadius + flicker;

    // ── Mask (alpha) ──────────────────────────────────────────────
    float edgeSoftness = 0.1;
    float mask         = smoothstep(radius+edgeSoftness*0.5,
                                    radius-edgeSoftness*0.5,
                                    dist);

    // ── Texture modulation ────────────────────────────────────────
    float texNoise = fbmTexture(
        gpos*3.0 + vec2(u_time*time_scale, -u_time*time_scale*0.7),
        persistence, lacunarity);
    float texIntensity = 1.0 + (texNoise - 0.5) * texture_scale * noise_falloff;

    // ── Colour gradient ───────────────────────────────────────────
    vec3 core = vec3(1.0, 0.9, 0.6);
    vec3 mid  = vec3(1.0, 0.5, 0.0);
    vec3 rim  = vec3(0.4, 0.05,0.0);
    float t   = clamp(dist / max(radius, 0.01), 0.0, 1.0);
    vec3 col  = mix(core, mid, smoothstep(0.0,0.5,t));
         col  = mix(col , rim, smoothstep(0.5,1.0,t));
         col *= texIntensity;
         col  = mix(col, vec3(1.0,1.0,0.9),
                    smoothstep(1.3,1.5,texIntensity)*0.5);
         col  = clamp(col,0.0,1.0);

    // ── Premultiplied alpha output ────────────────────────────────
    fragColor = vec4(col * mask, mask);
}
