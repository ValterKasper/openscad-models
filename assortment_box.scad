include <BOSL2/std.scad>
include <BOSL2/hull.scad>

$fn = 48;

wall_thickness = 1.2;
print_clearance = 0.15;
slide_clearance = 0.5;
eps = 0.001;

box_width = 100/1.8;
box_depth = 80/1.8; 
box_height = 35/1.8; 

// box();
cover_width = 30;
cover_height = 2;
cover_length = 40;
bottom_height = 2;
bottom_height_b = 0.2;
top_height = 1.4;
overhang_x = 2;
slide_cover_wall_thickness = 2;
sliding_base = 2;

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
        "ymove", cover_height / 2 + print_clearance + sliding_base,
        "xmove", sliding_base,
        "ymove", -sliding_base,
        "xmove", -sliding_base,
    ]);

    sliding_profile_b = turtle([
        "ymove", -cover_height / 2 - print_clearance - sliding_base,
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
module separator_sliding_profile() {
    profile_a = turtle([
        "ymove", wall_thickness / 2 + print_clearance + sliding_base,
        "xymove", [sliding_base, -sliding_base],
        "xmove", -sliding_base,
    ]);

    profile_b = turtle([
        "ymove", -wall_thickness / 2 - print_clearance - sliding_base,
        "xymove", [sliding_base, sliding_base],
        "xmove", -sliding_base,
    ]);

    region([profile_a]);
    region([profile_b]);
}


// todo:
//  - size should be base on box_SIZE
//  - add anchors for separators a front panel
module assortment_box() {
    cover_slider_heigth = cover_height + print_clearance * 2 + sliding_base * 2;
    box_inner_size_x = cover_width + slide_clearance * 2;
    //bottom
    xflip_copy()
    cube([box_inner_size_x / 2 + wall_thickness, cover_length, wall_thickness], anchor = RIGHT + FRONT + BOTTOM) {
        // side
        position(LEFT + BOTTOM + FRONT) 
        cube([wall_thickness, cover_length, box_height + cover_slider_heigth]) {
            // cover slider
            position(TOP + RIGHT)
            move(z = -(cover_slider_heigth) / 2)
            xrot(90)
            linear_extrude(cover_length, center = true)
            cover_sliding_profile();

            // separator sliders
            position(BOTTOM + RIGHT)
            linear_extrude(box_height + sliding_base)
            separator_sliding_profile();

            move(y = wall_thickness / 2 + print_clearance + sliding_base)
            position(BOTTOM + FRONT + RIGHT)
            linear_extrude(box_height + sliding_base)
            separator_sliding_profile();
        }

        // back
        position(BACK + BOTTOM + LEFT)
        cube([cover_width / 2 + wall_thickness + slide_clearance, wall_thickness, box_height + cover_slider_heigth], anchor = BACK + BOTTOM + LEFT);
    };
}


// TODO
//  - make attachable
module cover() {
    move(z = bottom_height + slide_clearance)
    cube([cover_width, 40, cover_height], anchor = BOTTOM + BACK);
}

// TODO
//  - make attachable
//  - add sliding profile for vertical separator
module horizontal_separator() {
    // separator
    xrot(90)
    #linear_extrude(wall_thickness)
    rect(
        [box_inner_size_x - print_clearance * 2, box_height - print_clearance * 2], 
        rounding = [2, 2, 0, 0]);
}

// TODO
//  - make vertival separator

assortment_box();
