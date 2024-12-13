#version 320 es

uniform FrameInfo {
  mat4 mvp;
  vec4 color;
} frame_info;

in vec2 position;
out vec4 v_color;

void main() {
  v_color = frame_info.color;
  gl_Position = frame_info.mvp * vec4(position, 0.0, 1.0);
}