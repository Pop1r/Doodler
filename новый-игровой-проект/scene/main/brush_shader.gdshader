shader_type canvas_item;
render_mode blend_disabled;

uniform sampler2D canvas_texture;
uniform vec4 brush_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float brush_size : hint_range(0.001, 0.1) = 0.02;
uniform vec2 draw_position;
uniform vec2 previous_draw_position;
uniform bool is_drawing = false;

uniform vec2 texture_size = vec2(1920.0, 1080.0);
uniform bool is_eraser = false;
uniform bool allow_blending = true;

// ПАРАМЕТРЫ СГЛАЖИВАНИЯ
uniform float smoothing : hint_range(0.0, 0.3) = 0.1;

// Упрощенная функция для рисования линии со сглаживанием
float draw_line(vec2 start, vec2 end, vec2 uv, float radius) {
    vec2 line_dir = end - start;
    float line_length = length(line_dir);
    
    if (line_length < 0.0001) {
        // Если точки совпадают, рисуем точку
        return 1.0 - smoothstep(radius - radius * smoothing, radius + radius * smoothing, distance(uv, start));
    }
    
    line_dir = normalize(line_dir);
    vec2 to_pixel = uv - start;
    float projection = dot(to_pixel, line_dir);
    projection = clamp(projection, 0.0, line_length);
    
    vec2 closest_point = start + line_dir * projection;
    float dist = distance(uv, closest_point);
    
    return 1.0 - smoothstep(radius - radius * smoothing, radius + radius * smoothing, dist);
}

vec2 correct_coordinates(vec2 coord) {
    float aspect_ratio = texture_size.x / texture_size.y;
    return vec2(coord.x * aspect_ratio, coord.y);
}

void fragment() {
    vec2 uv = UV;
    vec4 current_color = texture(canvas_texture, uv);
    
    float total_alpha = 0.0;
    
    if (is_drawing) {
        // ПРИМЕНЯЕМ КОРРЕКЦИЮ КООРДИНАТ ко всем точкам
        vec2 corrected_uv = correct_coordinates(uv);
        vec2 corrected_draw_pos = correct_coordinates(draw_position);
        vec2 corrected_prev_pos = correct_coordinates(previous_draw_position);
        
        // Также корректируем размер кисти
        float aspect_ratio = texture_size.x / texture_size.y;
        float corrected_brush_size = brush_size * aspect_ratio;
        
        total_alpha = draw_line(corrected_prev_pos, corrected_draw_pos, corrected_uv, corrected_brush_size);
        
        // Ограничиваем альфа-значение
        total_alpha = clamp(total_alpha, 0.0, 1.0);
    }
    
    if (is_eraser) {
        // Ластик: уменьшаем альфа там, где рисуем
        COLOR = vec4(current_color.rgb, current_color.a * (1.0 - total_alpha));
    } else {
        if (allow_blending) {
            // Смешивание цветов
            float final_alpha = total_alpha * brush_color.a;
			if (current_color.a == 0.0){
				current_color.rgb = brush_color.rgb;
			} 
            COLOR = vec4(
                mix(current_color.rgb, brush_color.rgb, final_alpha),
                max(current_color.a, final_alpha)
            );
        } else {
            // Замена цвета
            if (total_alpha > 0.01) {
                COLOR = vec4(brush_color.rgb, max(current_color.a, total_alpha * brush_color.a));
            } else {
                COLOR = current_color;
            }
        }
    }
}