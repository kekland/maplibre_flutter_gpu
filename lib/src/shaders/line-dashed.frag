#version 460 core

#pragma prelude: interpolation
#pragma prelude: tile

in highp float v_line_length;

#pragma prop: declare(highp vec4 color)
#pragma prop: declare(float opacity)
#pragma prop: declare(float width)
#pragma prop: declare(sampler2D dasharray)

out highp vec4 f_color;

void main() {
  #pragma prop: resolve(...)

  float line_position = v_line_length / width;
  float dash_value = texture(dasharray, vec2(line_position / dasharray_size.x, 0.5)).r;
  if (dash_value < 0.5) discard;

  f_color = color * (opacity * tile.opacity);
}
