include <BOSL2/std.scad>
include <BOSL2/hull.scad>

$fn = 64;

center_color = "silver"; // ["white", "#333", "#777", "Gold", "GoldenRod"]
front_color = "white"; // ["white", "#333", "#777", "Gold", "GoldenRod"]

eps = 0.01;
print_clearance = 0.2;
wall_thickness = 1.4;

// size_multiplier = 45;
size_multiplier = 20;
width_relative = 4;
height_relative = 1;
width = width_relative * size_multiplier;
height = height_relative * size_multiplier;
depth = 3 * size_multiplier;
rounding = 0.3 * size_multiplier;


shape_angle = 12;
paterns_width_count = 3;
paterns_height_count = 1;
full_pattern_count_of_shapes_y = 4;
full_pattern_count_of_shapes_x = 2;
front_block_width = width - wall_thickness * 2 - print_clearance * 2;
front_block_height = height - wall_thickness * 2 - print_clearance * 2;
shape_width = (front_block_width / paterns_width_count) / full_pattern_count_of_shapes_x;
shape_height = (front_block_height / paterns_height_count) / full_pattern_count_of_shapes_y;
shape_height_parts_ratio = 0.6;

module center_blok(anchor = CENTER, spin = 0, orient) {   
    size = [
        width,
        depth,
        height 
    ];
    attachable(anchor, spin, orient, size) {
        zrot(90)
        yrot(90)
        linear_extrude(depth, center = true)
        shell2d(-wall_thickness) {
            rect([height, width], rounding = rounding, anchor = CENTER);
        }

        children();
    }
}

module center_blok_mask(anchor = CENTER, spin = 0, orient) {
    size = [
        width - wall_thickness * 2 - print_clearance * 2,
        depth,
        height - wall_thickness * 2 - print_clearance * 2
    ];
    attachable(anchor, spin, orient, size) {
        zrot(90)
        yrot(90)
        linear_extrude(depth, center = true)
        rect([size[2], size[0]], rounding = rounding - wall_thickness, anchor = CENTER);

        children();
    }
}

function shape_depth() = (shape_width / 2) * tan(shape_angle);
function pattern_depth() = shape_depth() * 2 + wall_thickness;

/*
---------------------
|                   |
\                   /
    \           /
        \   /
*/
function shape_path() = 
    let(
        shape_half_width = (shape_width / 2)  / cos(shape_angle),
        shape_height_part_b = shape_height * shape_height_parts_ratio,
        shape_height_part_a = shape_height - shape_height_part_b
    )
    turtle([
        "jump", [shape_half_width, -shape_height_part_b],
        "ymove", -shape_height_part_a,
        "xmove", -(shape_half_width * 2),
        "ymove", shape_height_part_a,
        "jump", [0, 0]
    ]);

module thicken(path) {
    skin([path, up(wall_thickness, p = path)], slices = 1);
}

module pattern(anchor = CENTER, spin = 0, orient) {
    size = [
        shape_width, 
        shape_height * 2, 
        pattern_depth()
    ];
    attachable(anchor, spin, orient, size = size) {
        shape_top = yrot(shape_angle, p = path3d(shape_path()));
        shape_bottom = yflip(yrot(-shape_angle, p = path3d(shape_path())));

        triangle_right = [[0, 0, 0], shape_top[1], shape_bottom[1], [0, 0, 0]];
        triangle_left = [[0, 0, 0], shape_top[4], shape_bottom[4], [0, 0, 0]];

        down(wall_thickness / 2)
        union() {
            thicken(shape_top);
            thicken(shape_bottom);
            thicken(triangle_right);
            thicken(triangle_left);
        }

        children();
    }
}

// symetric in X and Y
module full_pattern(anchor = CENTER, spin = 0, orient) {
    size = [
        shape_width * full_pattern_count_of_shapes_x, 
        shape_height * full_pattern_count_of_shapes_y, 
        pattern_depth()
    ];
    attachable(anchor, spin, orient, size = size) {
        yflip_copy()
        xflip_copy()
        pattern(anchor = RIGHT + FRONT);

        children();
    }
}

module front_screw_block(anchor = CENTER) {
    block_width = shape_width;
    block_depth = ((shape_depth() + (shape_width / 2)));
    size = [
        shape_width,
        block_depth,
        wall_thickness
    ];
    attachable(anchor, size = size) {
        difference() {
            path = turtle([
                "left", shape_angle, 
                "untilx", shape_width / 2,
                "ymove", shape_width / 2,
                "xmove", -shape_width,
                "ymove", -shape_width / 2,
                "jump", [0, 0] 
            ]);
            linear_extrude(wall_thickness, center = true)
            move(y = -block_depth / 2)
            region([path]);   

            move(y = block_depth / 5)
            zcyl(d = 3 + eps, h = wall_thickness + eps);
        }

        children();
    }
}

module front_block(anchor = CENTER) {
    size = [
        front_block_width,
        pattern_depth(),
        front_block_height
    ];
    attachable(anchor, size = size) {
        intersection() {
            move(x = -front_block_width / 2, z = front_block_height / 2)
            full_pattern(anchor = BACK + LEFT, orient = FRONT) {
                attach(RIGHT, LEFT) full_pattern() 
                attach(RIGHT, LEFT) full_pattern();
            }
            center_blok_mask(anchor = CENTER);
        }

        children();
    }
}

recolor(center_color)
center_blok()
position(CENTER + FRONT) 

color(front_color)
render(convexity = 3) front_block() {
    position(BOTTOM + BACK) 
    front_screw_block(anchor = BOTTOM);
}






