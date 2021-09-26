include <BOSL2/std.scad>
include <BOSL2/hull.scad>
include <BOSL2/metric_screws.scad>

$fn = 12;

center_color = "#777"; // ["white", "#333", "#777", "Gold", "GoldenRod"]
front_color = "white"; // ["white", "#333", "#777", "Gold", "GoldenRod"]

eps = 0.01;
print_clearance = 0.15;
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

module case_preview() {
    recolor(center_color)
    center_blok()
    position(CENTER + FRONT) 

    color(front_color)
    render(convexity = 1) front_block() {
        position(BOTTOM + BACK) 
        front_screw_block(anchor = BOTTOM);
    }
}

function get_nut_holder_outer_diameter(bolt_size = 3) =
    get_metric_nut_size(bolt_size) * 1.6;

// nut -> matica
// bolt -> skrutka
// screw -> skrutka
// Cylinder with hole inside for nut
module nut_holder(bolt_size = 3) {
    echo(str("Variable = nut_size ",  get_metric_nut_size(bolt_size)));
    echo(str("Variable = nut_thickness ",  get_metric_nut_thickness(bolt_size)));

    module nut_mask() {
        bolt_inner_diameter = get_metric_nut_size(bolt_size) + print_clearance * 2;
        bolt_height = get_metric_nut_thickness(bolt_size) + print_clearance * 2;
        linear_extrude(bolt_height, center = true)
        hexagon(id = bolt_inner_diameter);

        screw_diameter = bolt_size + print_clearance * 2;
        zcyl(d = screw_diameter, h = 20);
    }

    diff("hole")
    zcyl(d = get_nut_holder_outer_diameter(bolt_size), h = 5) {
        tags("hole") nut_mask();
    }
}

module pcb_holder_demo() {
    nut_holder();

    move(x = struct_size, y = 0)
    nut_holder();

    move(x = struct_size, y = struct_size)
    nut_holder();

    move(x = 0, y = struct_size)
    nut_holder();

    struct_size = 60;
    path = turtle([
        "xmove", struct_size,
        "left", 135,
        "untilx", struct_size / 2,
        "jump", [0, 0]
    ]);

    down(2.5)
    difference() {
        linear_extrude(3)
        shell2d([3, -3], ir = 2, or = 2) {
            oval_size = 3;
            yflip_copy(y = struct_size / 2)
            region([path]);

            xflip_copy(x = 29.5)
            right(struct_size)
            rot(90)
            region([path]);
        }

        zcyl(r = 4, h = 20);
    }
}

x_pi_screw_dist = 58;
y_pi_screw_dist = 49;
pi_bolt_size = 2.5;


function muv(size, path, radius) = move([
    size[0] / 2 - radius, 
    size[1] / 2 - radius, 
    0], 
    p = path);

// [A, B, C, D]
//  B----A
//  |    |
//  C----D   
//  TODO sprav nejak, aby sa dali spravne umiestnovat objekty voci rounded_rect
function rounded_rect(corner_centers_distances, rounding = [1, 1, 1, 1]) = 
    let(
        nut_holder_radius = get_nut_holder_outer_diameter() / 2 - 2,
        size = corner_centers_distances + [nut_holder_radius * 2, nut_holder_radius * 2],
        r0 = rect(
            size = size, 
            rounding = [
                nut_holder_radius * rounding[0], 
                nut_holder_radius * rounding[1], 
                nut_holder_radius * rounding[2], 
                nut_holder_radius * rounding[3]
                ],
                center = true),
        outer_rect = muv(size, r0, nut_holder_radius),
        inner_rect = muv(size, rect(
            size = [
                size[0] - nut_holder_radius * 4, 
                size[1] - nut_holder_radius * 4
            ], 
            center = true, 
            rounding = nut_holder_radius), nut_holder_radius)
    )
    difference(outer_rect, inner_rect);

//  O---O---O
//  |       |
//  O---O---O
//  |   |   |
//  O---O---O
//  |       |
//  O---O---O
module holder() {
    module pi_holder() {
        region(rounded_rect([x_pi_screw_dist, y_pi_screw_dist]));
        region(rounded_rect([x_pi_screw_dist / 2, y_pi_screw_dist]));
        move(x = x_pi_screw_dist / 2)
        region(rounded_rect([x_pi_screw_dist / 2, y_pi_screw_dist]));
    }

    // top
    move(y = -20)
    region(rounded_rect([x_pi_screw_dist, 20]));

    // center
    pi_holder();

    // bottom
    move(y = y_pi_screw_dist)
    region(rounded_rect([x_pi_screw_dist, 30]));

    // TODO remove
    move(y = y_pi_screw_dist)
    union() {
        oval(r = get_nut_holder_outer_diameter() / 2);
        move(x = x_pi_screw_dist)
        oval(r = get_nut_holder_outer_diameter() / 2);
    }
}

holder_height = 2;

linear_extrude(holder_height)
holder();

xflip_copy(x = x_pi_screw_dist / 2)
move(z = holder_height, y = y_pi_screw_dist)
#zcyl(
    d = get_metric_bolt_head_size(pi_bolt_size),
    h = get_metric_bolt_head_height(pi_bolt_size),
    anchor = BOTTOM) {
        zcyl(
            d = pi_bolt_size - print_clearance * 2,
            h = 4,
            anchor = BOTTOM);
    };

echo(str("Variable = get_metric_bolt_head_size ", get_metric_bolt_head_size(pi_bolt_size)));
echo(str("Variable = get_metric_bolt_head_height ", get_metric_bolt_head_height(pi_bolt_size)));






