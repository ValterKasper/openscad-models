include <BOSL2/std.scad>
include <BOSL2/hull.scad>

/* [Shown model] */
// Type
model_type = "box"; // ["box", "panel", "separator"]

/* [Apartments] */
apartments_count_y = 5;
apartments_count_x = 3;

/* [Cover] */
// [mm]
cover_size_x = 125;
// [mm]
cover_size_y = 166.6;
// [mm]
cover_size_z = 2;

/* [Box] */
box_is_double_sided = true;
box_show_separators = true;
// [mm]
box_size_z = 30; 

module __Customizer_Limit__ () {}
/* [Clearences & others] */
box_show_cover = false;
wall_thickness = 1.2;
print_clearance = 0.15;
slider_base = 2;
cover_slider_clearance_x = 0.5;
cover_slider_clearance_y = 0.4;
separator_slider_clearance_y = 0.3;
$fn = 48;
eps = 0.001;

box_size_x = cover_size_x + wall_thickness * 2 + cover_slider_clearance_x * 2;
box_size_y = cover_size_y + wall_thickness + cover_slider_clearance_x; 

separator_slider_gap_size = wall_thickness + separator_slider_clearance_y * 2;
cover_slider_gap_size = cover_size_z + cover_slider_clearance_y * 2; 

box_inner_size_x = cover_size_x + cover_slider_clearance_x * 2;
box_inner_size_z = box_size_z - get_slider_height(cover_slider_gap_size) - wall_thickness + slider_base;

function get_slider_height(gap_height) = gap_height + slider_base * 2;

module _slider(
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
                    chamfer_edge_mask(l = size[1], chamfer = slider_base, orient = BACK);
            }
        }

        children();
    }
}

module _separator_full_slider(anchor, show_top = false) {
    size = [
        box_inner_size_x,
        get_slider_height(separator_slider_gap_size),
        box_inner_size_z, 
    ];
    attachable(size = size, anchor = anchor) {
        xflip_copy()
        move(x = -box_inner_size_x / 2)
        _slider(box_inner_size_z, gap_height = separator_slider_gap_size,  anchor = LEFT) {
            if (show_top) {
                position(TOP + LEFT)
                _slider(
                    length = box_inner_size_x / 2, 
                    gap_height = separator_slider_gap_size,
                    anchor = BOTTOM + LEFT, 
                    orient = RIGHT);
            }

            position(BOTTOM + LEFT)
            _slider(
                length = box_inner_size_x / 2, 
                gap_height = separator_slider_gap_size,
                anchor = TOP + LEFT, 
                orient = LEFT);

        }

        children();
    }
}

module _assortment_box_base(anchor, spin, orientation) {
    anchors = [
        named_anchor("cover", [
            0, 
            -box_size_y / 2, 
            box_size_z / 2 - get_slider_height(cover_slider_gap_size) / 2
        ], FRONT),

        named_anchor("front_panel", [
            0, 
            -box_size_y / 2 + get_slider_height(separator_slider_gap_size) / 2, 
            -box_size_z / 2 + wall_thickness
        ], UP),

        named_anchor("back_panel", [
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
                // cover _slider
                position(RIGHT + TOP)
                _slider(
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

module separator_x(show_separator_y = true) {
    separtor_chamfer = 2 + print_clearance;
    separtor_y_wall_thickness = wall_thickness * 1.5;

    module separator_y() {
        cuboid(
            [
                separtor_y_wall_thickness, 
                (box_size_y - get_slider_height(separator_slider_gap_size)) / apartments_count_y - separator_slider_gap_size - print_clearance, 
                box_inner_size_z - print_clearance * 2
            ],
            chamfer = separtor_chamfer * 1.2,
            edges = "X",
            anchor = BOTTOM);
    }

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

            xcopies(spacing = box_inner_size_x / (apartments_count_x), n = apartments_count_x - 1) {
                if (show_separator_y) {
                    attach(BACK, LEFT)
                    _slider(length = slider_lenght, gap_height = separtor_y_wall_thickness,  chamfer_ends = true);

                    attach(BACK, FRONT)
                    separator_y();
                }
            }
        }
}

module assortment_box() {
    if (box_is_double_sided) {
        zflip_copy(z = - box_size_z / 2 + wall_thickness / 2)
        assortment_box_single_side();
    } else {
        assortment_box_single_side();
    }

    module assortment_box_single_side() {
        _assortment_box_base() {
                // cover
                if (box_show_cover) {
                    color("silver", 0.4)
                    position("cover")
                    cube([cover_size_x, cover_size_y, cover_size_z], anchor = FRONT);
                }

                // separators and sliders
                position("front_panel") {
                    ycopies(n = apartments_count_y + 1, l = box_size_y - get_slider_height(separator_slider_gap_size), sp = 0) {
                        _separator_full_slider(anchor = BOTTOM);
                        if (box_show_separators) {
                            separator_x(show_separator_y = $idx != apartments_count_y);
                        }

                    }
                }

                // back panel separator _slider
                position("back_panel") {
                    _separator_full_slider(anchor = BOTTOM, show_top = true) {
                        // back panel vertical prismoids
                        width_multiplier = 1.4;
                        xcopies(spacing = box_inner_size_x / (apartments_count_x), n = apartments_count_x - 1)
                        position(BACK)
                        prismoid(
                            size1 = [get_slider_height(separator_slider_gap_size) * width_multiplier, box_inner_size_z], 
                            size2 = [separator_slider_gap_size * width_multiplier, box_inner_size_z], 
                            h = slider_base,
                            anchor = TOP,
                            orient = BACK
                        );

                        // back panel bottom prismoid
                        top_width = get_slider_height(separator_slider_gap_size) / 2;
                        bottom_width = get_slider_height(separator_slider_gap_size);
                        move(z = separator_slider_gap_size / 2)
                        position(BACK + BOTTOM)
                        prismoid(
                            size1 = [bottom_width, box_inner_size_x],
                            size2 = [top_width, box_inner_size_x],
                            h = slider_base,
                            shift = [-(top_width - bottom_width) / 2, 0],
                            anchor = TOP,
                            orient = BACK,
                            spin = 90
                        );
                    };
                }

                if (!box_is_double_sided)
                    yflip_copy()
                    xflip_copy()
                    move(x = 5 + wall_thickness + print_clearance, y = -5 - wall_thickness - slider_base - print_clearance)
                    position(BOTTOM + BACK + LEFT)
                    zcyl(h = slider_base, r1 = 3, r2 = 5, anchor = TOP);
        }
    }
}

if (model_type == "box") {
    assortment_box();
} else if (model_type == "separator") {
    separator_x();
} else if (model_type == "panel") {
    separator_x(show_separator_y = false);
}