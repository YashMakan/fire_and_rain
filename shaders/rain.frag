#version 460 core
precision highp float;
#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float u_time;
uniform float u_speed;

layout(location = 0) out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / resolution;
    vec2 pos = uv * 2.0 - 1.0; // -1 to 1 space

    // Ellipse parameters for raindrop shape
    float radiusX = 0.12;
    float radiusY = 0.85;

    // Ellipse formula
    float ellipse = pow(pos.x / radiusX, 2.0) + pow(pos.y / radiusY, 2.0);

    // Soft alpha edges with smoothstep
    float alpha = smoothstep(1.0, 0.95, ellipse);

    // Vertical gradient for highlight (top brighter)
    float highlight = smoothstep(-1.0, 0.0, pos.y);

    // Base blue color with white highlight on top
    vec3 baseColor = vec3(0.5, 0.7, 0.9);
    vec3 highlightColor = vec3(1.0, 1.0, 1.0);

    vec3 color = mix(baseColor, highlightColor, highlight);

    // Make it more transparent and watery
    alpha *= 0.4 + 0.6 * abs(sin(u_time * 5.0));

    fragColor = vec4(color, alpha);
}
