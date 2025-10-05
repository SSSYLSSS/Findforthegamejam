shader_type canvas_item;

uniform vec2 effect_center = vec2(0.5);
uniform float effect_scale = 1.0;
uniform float effect_repeat = 2.0;
uniform vec2 scroll_speed = vec2(0.0);

uniform sampler2D image_texture;
uniform sampler2D image_multiplier; // 新增的纹理
uniform sampler2D image_add : hint_default_black;

vec2 coordinates(vec2 uv, vec2 center, float scale, float repeat) {
    // 计算从中心到当前点的向量
    vec2 dir = uv - center;
    
    // 计算极坐标
    float radius = length(dir);
    float angle = atan(dir.y, dir.x);
    
    // 将角度归一化到[0, 2π]范围
    angle = mod(angle, TAU);
    
    // 应用重复次数
    angle = angle * repeat;
    
    // 应用缩放
    radius = radius * scale;
    
    // 将极坐标映射回UV坐标
    vec2 polar_uv = vec2(
        angle / TAU,  // 角度分量映射到[0,1]
        radius        // 半径分量
    );
    
    return polar_uv;
}

void fragment() {
    // 计算变换后的UV坐标
    vec2 transformed_uv = coordinates(UV, effect_center, effect_scale, effect_repeat);
    
    // 应用纹理重复
    transformed_uv = fract(mod(transformed_uv+(TIME*scroll_speed), 1.0));
    
    // 采样主纹理
    vec4 main_tex = texture(image_texture, transformed_uv);
    
    // 采样乘数纹理（使用原始UV坐标）
    vec4 multiplier_tex = texture(image_multiplier, UV);
    
	vec4 add_tex = texture(image_add, UV);
    // 混合纹理
    vec4 final_color = main_tex * multiplier_tex * add_tex;
    
    // 输出最终颜色
    COLOR = final_color;
}