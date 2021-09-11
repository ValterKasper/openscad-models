include <BOSL2/std.scad>
include <BOSL2/hull.scad>

$fn = 64;

pattern_angle = 12;
pattern_width = 16;
pattern_height = 5;
pattern_height_parts_ratio = 0.6;

wall_thickness = 1.8;

size_multiplier = 45;
width_relative = 4;
width = 4 * size_multiplier;
height = 1 * size_multiplier;
depth = 3 * size_multiplier;
rounding = 0.3 * size_multiplier;

module center_blok() {   
    yrot(90)
    linear_extrude(depth, center = true)
    shell2d(-wall_thickness) {
        rect([height, width], rounding = rounding, anchor = CENTER);
    }
}

/*
---------------------
|                   |
\                   /
    \           /
        \   /
*/
function pattern_path() = 
    let(
        pattern_half_width = (pattern_width / 2)  / cos(pattern_angle),
        pattern_height_part_b = pattern_height * pattern_height_parts_ratio,
        pattern_height_part_a = pattern_height - pattern_height_part_b
    )
    turtle([
        "jump", [pattern_half_width, -pattern_height_part_b],
        "ymove", -pattern_height_part_a,
        "xmove", -(pattern_half_width * 2),
        "ymove", pattern_height_part_a,
        "jump", [0, 0]
    ]);

pattern_top = yrot(pattern_angle, p = path3d(pattern_path()));
pattern_bottom = yflip(yrot(-pattern_angle, p = path3d(pattern_path())));

triangle_right = [[0, 0, 0], pattern_top[1], pattern_bottom[1], [0, 0, 0]];
triengle_left = [[0, 0, 0], pattern_top[4], pattern_bottom[4], [0, 0, 0]];

module part() {
    module thicken(path) {
        skin([path, up(wall_thickness, p = path)], slices = 1);
    }

    thicken(pattern_top);
    thicken(pattern_bottom);
    thicken(triangle_right);
    thicken(triengle_left);
}

module pattern() {
    xflip_copy(x = pattern_width / 2)
    yflip_copy(y = -pattern_height)
    part();
}

pattern();
right((pattern_width / 2) * 4)
pattern();

//center_blok();




