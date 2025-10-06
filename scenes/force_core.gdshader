shader_type canvas_item;

// 运动参数
uniform float rotation_speed = 1.0;      // 旋转速度
uniform float centrifugal_speed = 0.1;   // 向心速度（半径减小速度）
uniform vec2 effect_center = vec2(0.5);   // 漩涡中心

// 像素化参数
uniform float pixel_size = 8.0;          // 像素块大小
uniform float effect_scale = 1.0;        // 缩放比例
uniform float effect_repeat = 2.0;       // 图案重复次数

// 纹理
uniform sampler2D image_texture;
uniform sampler2D image_multiplier;
uniform sampler2D image_add : hint_default_black;

// 像素漩涡函数：保持像素方块不扭曲的向心旋转
vec2 pixel_vortex(vec2 uv, float pixel_size_param, float rot_speed, float centri_speed, vec2 center, float scale, float repeat) {
    // 使用固定的游戏分辨率320x180
    vec2 game_resolution = vec2(320.0, 180.0);
    
    // 将UV坐标转换为像素坐标
    vec2 pixel_coord = uv * game_resolution;
    
    // 计算像素块（确保像素块为方形）
    vec2 pixel_block = floor(pixel_coord / pixel_size_param) * pixel_size_param;
    
    // 计算像素块中心
    vec2 block_center = pixel_block + pixel_size_param * 0.5;
    
    // 计算从漩涡中心到像素块中心的向量
    vec2 center_pixel = center * game_resolution;
    vec2 dir = block_center - center_pixel;
    float radius = length(dir);
    float angle = atan(dir.y, dir.x);
    
    // 应用重复次数
    angle = angle * repeat;
    
    // 应用缩放
    radius = radius * scale;
    
    // 应用旋转效果：角度随时间变化
    angle += TIME * rot_speed;
    
    // 应用向心效果：半径随时间减小
    radius = radius * (1.0 - centri_speed * fract(TIME * 0.5)); // 使用fract创建循环效果
    
    // 计算新的像素块位置（保持方形朝向）
    vec2 new_dir = vec2(cos(angle), sin(angle)) * radius;
    vec2 new_block_center = center_pixel + new_dir;
    
    // 将新位置转换回UV坐标
    vec2 new_uv = new_block_center / game_resolution;
    
    return new_uv;
}

void fragment() {
    // 应用像素漩涡效果
    vec2 vortex_uv = pixel_vortex(UV, pixel_size, rotation_speed, centrifugal_speed, effect_center, effect_scale, effect_repeat);
    
    // 采样纹理
    vec4 main_tex = texture(image_texture, vortex_uv);
    vec4 multiplier_tex = texture(image_multiplier, UV);
    vec4 add_tex = texture(image_add, UV);
    
    // 混合颜色
    vec4 final_color = main_tex * multiplier_tex * add_tex;
    
    // 输出最终颜色
    COLOR = final_color;
}