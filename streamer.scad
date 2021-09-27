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


module nut_holder_nut_mask(bolt_size = 3) {
    bolt_inner_diameter = get_metric_nut_size(bolt_size) + print_clearance * 2;
    bolt_height = get_metric_nut_thickness(bolt_size) + print_clearance * 2;
    linear_extrude(bolt_height, center = true)
    hexagon(id = bolt_inner_diameter);

    screw_diameter = bolt_size + print_clearance * 2;
    zcyl(d = screw_diameter, h = 20);
}

// nut -> matica
// bolt -> skrutka
// screw -> skrutka
// Cylinder with hole inside for nut
module nut_holder(anchor, bolt_size = 3) {
    d = get_nut_holder_outer_diameter(bolt_size);
    h = 5;
    attachable(anchor = anchor, d = d, h = h) {
        cyl(d = get_nut_holder_outer_diameter(bolt_size), h = 5);

        children();
    }
}

x_rpi_screw_dist = 58;
y_rpi_screw_dist = 49;
rpi_bolt_size = 2.5;
holder_height = 2;
hole_distance = 3.5;
rpi_pcb_thickness = 1;
rpi_size_x = 85;
rpi_size_y = 56;

//  Rounding = [A, B, C, D]
//  B----A
//  |    |
//  C----D   
module rounded_hollow_cube(
    corner_centers_distances, 
    height = holder_height, 
    rounding = [1, 1, 1, 1], 
    anchor, spin, orient
) {
    nut_holder_radius = get_nut_holder_outer_diameter() / 2 - 2;
    size = corner_centers_distances + [nut_holder_radius * 2, nut_holder_radius * 2];

    function muv(path) = move([
        0,//size[0] / 2 - nut_holder_radius, 
        0,//size[1] / 2 - nut_holder_radius, 
        0], 
        p = path);

    function rounded_rect(corner_centers_distances, rounding = [1, 1, 1, 1]) = 
        let(
            r0 = rect(
                size = size, 
                rounding = [
                    nut_holder_radius * rounding[0], 
                    nut_holder_radius * rounding[1], 
                    nut_holder_radius * rounding[2], 
                    nut_holder_radius * rounding[3]
                    ],
                    center = true),
            outer_rect = muv(r0),
            inner_rect = muv(rect(
                size = [
                    size[0] - nut_holder_radius * 4, 
                    size[1] - nut_holder_radius * 4
                ], 
                center = true, 
                rounding = nut_holder_radius))
        )
        difference(outer_rect, inner_rect);

    anchors = [
        anchorpt("f", [0, -size[1] / 2, 0], FRONT, 0),
        anchorpt("b", [0, size[1] / 2, 0], BACK, 180),
        anchorpt("l", [-size[0] / 2, 0, 0], LEFT, -90),
        anchorpt("r", [size[0] / 2, 0, 0], RIGHT, 90),
    ];

    attachable(
        anchor, 
        spin, 
        orient, 
        [corner_centers_distances[0], corner_centers_distances[1], height],
        anchors = anchors
    ) {
        linear_extrude(height, center = true)
        region(rounded_rect(corner_centers_distances, rounding));

        children();
    }
}

//  Anchors
//  B----A
//  |    |
//  C----D   
module rpi(anchor, spin, orient) {
    half_pcb = rpi_pcb_thickness / 2;

    anchors = [
        anchorpt("A", [hole_distance + x_rpi_screw_dist, rpi_size_y - hole_distance, -half_pcb], BOTTOM),
        anchorpt("B", [hole_distance, rpi_size_y - hole_distance, -half_pcb], BOTTOM),
        anchorpt("C", [hole_distance, hole_distance, -half_pcb], BOTTOM),
        anchorpt("D", [hole_distance + x_rpi_screw_dist, hole_distance, -half_pcb], BOTTOM),
    ];

    attachable(
        anchor, 
        spin, 
        orient, 
        offset = [rpi_size_x / 2, rpi_size_y / 2, 0],
        [rpi_size_x, rpi_size_y, rpi_pcb_thickness],
        anchors = anchors
    ) {
        color("green", 0.25)
        linear_extrude(rpi_pcb_thickness, center = true)
        diff("bolt")
        rect([rpi_size_x, rpi_size_y]) {
            tags("bolt") 
            position(LEFT + BACK)
            move(x = hole_distance, y = -hole_distance) 
            oval(d = rpi_bolt_size);

            tags("bolt") 
            position(LEFT + BACK)
            move(x = hole_distance + x_rpi_screw_dist, y = -hole_distance) 
            oval(d = rpi_bolt_size);

            tags("bolt") 
            position(LEFT + FRONT)
            move(x = hole_distance, y = hole_distance) 
            oval(d = rpi_bolt_size);

            tags("bolt") 
            position(LEFT + FRONT)
            move(x = hole_distance + x_rpi_screw_dist, y = hole_distance) 
            oval(d = rpi_bolt_size);
        }

        children();
    }
}

module pcb_snap(anchor = FRONT, spin) {
    snap_cylinder_d = 1.6;
    snap_height = holder_height + get_metric_bolt_head_height(rpi_bolt_size) + rpi_pcb_thickness + snap_cylinder_d;
    snap_width = 8;
    snap_depth = hole_distance + holder_height;
    attachable(
            anchor = anchor, 
            size = [snap_width, snap_depth, snap_height],
            offset = [0, snap_depth / 2, 0],
            spin = spin
        ) {
            cube([snap_width, hole_distance, holder_height], anchor = FRONT) {
                position(BACK + BOTTOM)
                cube([
                        snap_width, 
                        holder_height, 
                        snap_height
                    ],
                    anchor = FRONT + BOTTOM) {
                        position(FRONT + TOP)
                        xcyl(d = snap_cylinder_d, h = snap_width, anchor = TOP);
                    };
            };

            children();
        }
}

//  B---O---O---O---O---A
//  |   |           |   |
//  O---X---O---O---O---O
//  |   |RPI|RPI|RPI|   |
//  |   |RPI|RPI|RPI|   |
//  C---O---O---O---O---D
module holder(anchor, show_rpi = false) {
    x_side_size = 20;
    y_top_size = 20;
    x_distance_to_rpi_end = rpi_size_x - hole_distance * 2 - x_rpi_screw_dist;
    module knut() {
        zcyl(
            d = get_nut_holder_outer_diameter(), 
            h = holder_height) {
                position(TOP)
                zcyl(
                    d = get_metric_bolt_head_size(rpi_bolt_size),
                    h = get_metric_bolt_head_height(rpi_bolt_size),
                    anchor = BOTTOM) {
                        zcyl(
                            d = rpi_bolt_size,
                            h = 4,
                            anchor = BOTTOM);
                };
        };
    }

    anchors = [

    ];
    size = [
        x_rpi_screw_dist + x_distance_to_rpi_end + x_side_size * 2, 
        y_rpi_screw_dist + y_top_size, 
        holder_height
    ];
    offset = [
        x_distance_to_rpi_end / 2, 
        y_top_size / 2, 
        0
    ];
    attachable(anchor = anchor, size = size, offset = offset, anchors = anchors) {
        diff("nut_mask")
            rounded_hollow_cube([x_rpi_screw_dist, y_rpi_screw_dist]) {

                // top
                position(BACK)
                rounded_hollow_cube([x_rpi_screw_dist, y_top_size], anchor = FRONT) {
                    position(LEFT)
                    rounded_hollow_cube([x_side_size, y_top_size], anchor = RIGHT) {
                        // nut B
                        position(LEFT + BACK + BOTTOM)
                        nut_holder(anchor = BOTTOM)
                        tags("nut_mask") 
                        nut_holder_nut_mask();
                    };

                    position(RIGHT)
                    rounded_hollow_cube([x_side_size + x_distance_to_rpi_end, y_top_size], anchor = LEFT) {
                        // nut A
                        position(RIGHT + BACK + BOTTOM)
                        nut_holder(anchor = BOTTOM)
                        tags("nut_mask") 
                        nut_holder_nut_mask();
                    }
                };

                // bottom
                position(LEFT) 
                rounded_hollow_cube([x_rpi_screw_dist / 2, y_rpi_screw_dist], anchor = LEFT) {
                    position(LEFT)
                    rounded_hollow_cube([x_side_size, y_rpi_screw_dist], anchor = RIGHT) {
                        // nut C
                        position(LEFT + FRONT + BOTTOM)
                        nut_holder(anchor = BOTTOM)
                        tags("nut_mask") 
                        nut_holder_nut_mask();
                    };

                };
                position(RIGHT) 
                rounded_hollow_cube([x_rpi_screw_dist / 2, y_rpi_screw_dist], anchor = RIGHT)  {
                
                    position(RIGHT)
                    rounded_hollow_cube([x_distance_to_rpi_end, y_rpi_screw_dist], anchor = LEFT) {
                        position(RIGHT)
                        rounded_hollow_cube([x_side_size, y_rpi_screw_dist], anchor = LEFT) {
                            // nut D
                            position(RIGHT + FRONT + BOTTOM)
                            nut_holder(anchor = BOTTOM)
                            tags("nut_mask") 
                            nut_holder_nut_mask();
                        };
                    };
                };

                // knuts
                position([LEFT + BACK, RIGHT + BACK])
                knut();

                // snaps
                position(BACK)
                pcb_snap();
                position(LEFT)
                move(y = 17)
                pcb_snap(spin = 90);
                position(LEFT)
                move(y = -17)
                pcb_snap(spin = 90);

                if (show_rpi)
                    position(BACK + LEFT+ TOP)
                    move(z = get_metric_bolt_head_height(rpi_bolt_size))
                    rpi(anchor = "B");
            };
        children();
    }
}

holder(show_rpi = true) show_anchors();



