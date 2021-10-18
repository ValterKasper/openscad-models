include <BOSL2/std.scad>
include <BOSL2/hull.scad>

$fn = 48;

wall_thickness = 1.2;
print_clearance = 0.15;
slide_clearance = 0.5;
eps = 0.001;

apartments_count_y = 5;
apartments_count_x = 3;

cover_size_x = 125;
cover_size_y = 166.6;
cover_size_z = 2;

box_size_x = cover_size_x + wall_thickness * 2 + slide_clearance * 2;
box_size_y = cover_size_y + wall_thickness + slide_clearance; 
box_size_z = 30; 

sliding_base = 2;

separator_slider_heigth = sliding_base * 2 + wall_thickness + print_clearance * 2;
cover_slider_heigth = cover_size_z + print_clearance * 2 + sliding_base * 2;

box_inner_size_x = cover_size_x + slide_clearance * 2;
box_inner_size_z = box_size_z - cover_slider_heigth - wall_thickness + sliding_base;


//  x---x
//  |   |
//  x---x   
//
//
//  x---x
//  |  /
//  x/   
module cover_sliding_profile() {
    sliding_profile_a = turtle([
        "ymove", cover_size_z / 2 + print_clearance + sliding_base,
        "xymove", [sliding_base, -sliding_base],
        "xmove", -sliding_base,
    ]);

    sliding_profile_b = turtle([
        "ymove", -cover_size_z / 2 - print_clearance - sliding_base,
        "xymove", [sliding_base, sliding_base],
        "xmove", -sliding_base,
    ]);

    region([sliding_profile_a]);
    region([sliding_profile_b]);
}

//  x\
//  |  \
//  x---x   
//
//
//  x---x
//  |  /
//  x/   
module separator_sliding(
    length, 
    anchor, 
    spin, 
    orient, 
    gap_size = wall_thickness + print_clearance * 2, 
    chamfer_ends = false
) {
    module profile() {
        profile_a = turtle([
            "ymove", gap_size / 2 + sliding_base,
            "xymove", [sliding_base, -sliding_base],
            "xmove", -sliding_base,
        ]);

        profile_b = turtle([
            "ymove", -gap_size / 2 - sliding_base,
            "xymove", [sliding_base, sliding_base],
            "xmove", -sliding_base,
        ]);

        move(x = -sliding_base / 2) {
            region([profile_a]);
            region([profile_b]);
        }
    }

    size = [
        sliding_base,
        separator_slider_heigth,
        length
    ];

    attachable(size = size, anchor = anchor, spin = spin, orient = orient) {
        union() {
            difference() {
                linear_extrude(length, center = true)
                profile();

                if (chamfer_ends)
                    position([TOP + RIGHT, BOTTOM + RIGHT])
                    chamfer_mask_y(l = separator_slider_heigth , chamfer = sliding_base);
            }
        }

        children();
    }
}

module separator_full_sliding(anchor, show_top = false) {
    size = [
        box_inner_size_x,
        separator_slider_heigth,
        box_inner_size_z, 
    ];
    attachable(size = size, anchor = anchor) {
        xflip_copy()
        move(x = -box_inner_size_x / 2)
        separator_sliding(box_inner_size_z, anchor = LEFT) {
            if (show_top) {
                position(TOP + LEFT)
                separator_sliding(
                    length = box_inner_size_x / 2, 
                    anchor = BOTTOM + LEFT, 
                    orient = RIGHT);
            }

            position(BOTTOM + LEFT)
            separator_sliding(
                length = box_inner_size_x / 2, 
                anchor = TOP + LEFT, 
                orient = LEFT);

        }

        children();
    }
}

module assortment_box(anchor, spin, orientation) {
    anchors = [
        anchorpt("cover", [
            0, 
            -box_size_y / 2, 
            box_size_z / 2 - cover_slider_heigth / 2
        ], FRONT),

        anchorpt("front_panel", [
            0, 
            -box_size_y / 2 + separator_slider_heigth / 2, 
            -box_size_z / 2 + wall_thickness
        ], UP),

        anchorpt("back_panel", [
            0, 
            box_size_y / 2 - separator_slider_heigth / 2, 
            -box_size_z / 2 + wall_thickness
        ], UP),
    ];

    size = [box_size_x, box_size_y, box_size_z];
    attachable(size = size, anchor = anchor, anchors = anchors) {
        //bottom
        move(z = -box_size_z / 2)
        xflip_copy()
        cube([box_size_x / 2, box_size_y, wall_thickness], anchor = RIGHT + BOTTOM) {
            // side
            position(LEFT + BOTTOM + FRONT) 
            cube([wall_thickness, box_size_y, box_size_z]) {
                // cover slider
                position(TOP + RIGHT + BACK)
                move(z = -(cover_slider_heigth) / 2)
                xrot(90)
                linear_extrude(box_size_y)
                cover_sliding_profile();

                // back
                position(LEFT + TOP + BACK)
                cube(
                    [box_size_x / 2, wall_thickness, cover_slider_heigth - sliding_base], 
                    anchor = TOP + LEFT + BACK) {
                        position(FRONT + LEFT + TOP)
                        cube(
                            [box_size_x / 2, sliding_base, sliding_base], 
                            anchor = BACK + LEFT + TOP);
                    }
            }
        };

        children();
    }
}

separtor_chamfer = 2 + print_clearance;
separtor_y_wall_thickness = wall_thickness * 1.5;

module separator_x(show_separator_y = true) {
    cuboid(
        [
            box_inner_size_x - print_clearance * 2, 
            wall_thickness + print_clearance * 2, 
            box_inner_size_z - print_clearance * 2
        ],
        chamfer = separtor_chamfer,
        edges = "Y",
        anchor = BOTTOM) {
            slider_lenght = box_inner_size_z * 0.7;

            xcopies(spacing = box_inner_size_x / 3, n = 2) {
                if (show_separator_y) {
                    attach(BACK, LEFT)
                    separator_sliding(length = slider_lenght, gap_size = separtor_y_wall_thickness,  chamfer_ends = true);

                    attach(BACK, FRONT)
                    separator_y();
                }
            }
        }
}

module separator_y() {
    cuboid(
        [
            separtor_y_wall_thickness, 
            box_size_y / apartments_count_y - print_clearance * 2 - wall_thickness * 2, 
            box_inner_size_z - print_clearance * 2
        ],
        chamfer = separtor_chamfer,
        edges = "X",
        anchor = BOTTOM);
}

show_cover = false;
show_separators = true;
show_box = true;



if (show_box)
assortment_box() {
    // cover
    if (show_cover) {
        color("silver", 0.4)
        position("cover")
        cube([cover_size_x, cover_size_y, cover_size_z], anchor = FRONT);
    }

    // separators and sliders
    position("front_panel") {
        ycopies(n = apartments_count_y + 1, l = box_size_y - separator_slider_heigth, sp = 0) {
            separator_full_sliding(anchor = BOTTOM);
            if (show_separators)
                separator_x();

        }

        // separator_x(show_separator_y = true);
    }

    // back panel separator slider
    position("back_panel") {
        separator_full_sliding(anchor = BOTTOM, show_top = true);
    }

    yflip_copy()
    xflip_copy()
    move(x = 5 + wall_thickness + print_clearance, y = -5 - wall_thickness - sliding_base - print_clearance)
    position(BOTTOM + BACK + LEFT)
    zcyl(h = sliding_base, r1 = 3, r2 = 5, anchor = TOP);
}
