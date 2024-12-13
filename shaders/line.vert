#version 320 es

uniform FrameInfo {
  mat4 mvp;
  vec4 color;
} frame_info;

uniform LineInfo {
  float width;
} line_info;

in vec2 position;
in vec2 normal;
out vec4 v_color;

void main() {
  v_color = frame_info.color;

  vec2 offset = normal * line_info.width * 0.5;
  gl_Position = frame_info.mvp * vec4(position + offset, 0.0, 1.0);
}