include <BOSL2/std.scad>
include <BOSL2/hull.scad>

$fn = 48;

wall_thickness = 1.2;
print_clearance = 0.15;
cover_slider_clearance_x = 0.5;
cover_slider_clearance_y = 0.4;
separator_slider_clearance_y = 0.25;
eps = 0.001;

apartments_count_y = 5;
apartments_count_x = 3;

cover_size_x = 125;
cover_size_y = 166.6;
cover_size_z = 2;

box_size_x = cover_size_x + wall_thickness * 2 + cover_slider_clearance_x * 2;
box_size_y = cover_size_y + wall_thickness + cover_slider_clearance_x; 
box_size_z = 30; 

slider_base = 2;

separator_slider_gap_size = wall_thickness + separator_slider_clearance_y * 2;
cover_slider_gap_size = cover_size_z + cover_slider_clearance_y * 2; 

box_inner_size_x = cover_size_x + cover_slider_clearance_x * 2;
box_inner_size_z = box_size_z - get_slider_height(cover_slider_gap_size) - wall_thickness + slider_base;

function get_slider_height(gap_height) = gap_height + slider_base * 2;

module slider(
    length, 
    anchor, 
    spin, 
    orient, 
    gap_height, 
    chamfer_ends = false
) {
    /*
        x\
        |  \
        x---x   


        x---x
        |  /
        x/  
    */
    module profile() {
        profile_a = turtle([
            "ymove", gap_height / 2 + slider_base,
            "xymove", [slider_base, -slider_base],
            "xmove", -slider_base,
        ]);

        profile_b = turtle([
            "ymove", -gap_height / 2 - slider_base,
            "xymove", [slider_base, slider_base],
            "xmove", -slider_base,
        ]);

        move(x = -slider_base / 2) {
            region([profile_a]);
            region([profile_b]);
        }
    }

    size = [
        slider_base,
        slider_base * 2 + gap_height,
        length
    ];

    attachable(size = size, anchor = anchor, spin = spin, orient = orient) {
        union() {
            difference() {
                linear_extrude(length, center = true)
                profile();

                if (chamfer_ends)
                    position([TOP + RIGHT, BOTTOM + RIGHT])
                    chamfer_mask_y(l = size[1] , chamfer = slider_base);
            }
        }

        children();
    }
}

module separator_full_slider(anchor, show_top = false) {
    size = [
        box_inner_size_x,
        get_slider_height(separator_slider_gap_size),
        box_inner_size_z, 
    ];
    attachable(size = size, anchor = anchor) {
        xflip_copy()
        move(x = -box_inner_size_x / 2)
        slider(box_inner_size_z, gap_height = separator_slider_gap_size,  anchor = LEFT) {
            if (show_top) {
                position(TOP + LEFT)
                slider(
                    length = box_inner_size_x / 2, 
                    gap_height = separator_slider_gap_size,
                    anchor = BOTTOM + LEFT, 
                    orient = RIGHT);
            }

            position(BOTTOM + LEFT)
            slider(
                length = box_inner_size_x / 2, 
                gap_height = separator_slider_gap_size,
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
            box_size_z / 2 - get_slider_height(cover_slider_gap_size) / 2
        ], FRONT),

        anchorpt("front_panel", [
            0, 
            -box_size_y / 2 + get_slider_height(separator_slider_gap_size) / 2, 
            -box_size_z / 2 + wall_thickness
        ], UP),

        anchorpt("back_panel", [
            0, 
            box_size_y / 2 - get_slider_height(separator_slider_gap_size) / 2, 
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
                position(RIGHT + TOP)
                slider(
                    gap_height = cover_slider_gap_size, 
                    length = box_size_y,
                    anchor = LEFT + FRONT,
                    orient = BACK);

                // back
                position(LEFT + TOP + BACK)
                cube(
                    [box_size_x / 2, wall_thickness, get_slider_height(cover_slider_gap_size) - slider_base], 
                    anchor = TOP + LEFT + BACK) {
                        position(FRONT + LEFT + TOP)
                        cube(
                            [box_size_x / 2, slider_base, slider_base], 
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
                    slider(length = slider_lenght, gap_height = separtor_y_wall_thickness,  chamfer_ends = true);

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
            box_size_y / apartments_count_y - print_clearance * 2 * 1.5 - wall_thickness * 2, 
            box_inner_size_z - print_clearance * 2
        ],
        chamfer = separtor_chamfer * 1.2,
        edges = "X",
        anchor = BOTTOM);
}

show_cover = false;
show_separators = false;
show_box = false;

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
        ycopies(n = apartments_count_y + 1, l = box_size_y - get_slider_height(separator_slider_gap_size), sp = 0) {
            separator_full_slider(anchor = BOTTOM);
            if (show_separators)
                separator_x();

        }

        // separator_x(show_separator_y = true);
    }

    // back panel separator slider
    position("back_panel") {
        separator_full_slider(anchor = BOTTOM, show_top = true);
    }

    yflip_copy()
    xflip_copy()
    move(x = 5 + wall_thickness + print_clearance, y = -5 - wall_thickness - slider_base - print_clearance)
    position(BOTTOM + BACK + LEFT)
    zcyl(h = slider_base, r1 = 3, r2 = 5, anchor = TOP);
}
