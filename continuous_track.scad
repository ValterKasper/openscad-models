include <BOSL2/std.scad>
include <BOSL2/hull.scad>



$fn = 24;
c = 0.01;

// mm
print_clearance = 0.2;

hole_radius = 2; // [1:0.1:10]
hole_thickness = 1; // [0.6:0.1:6]
holder_radius = hole_radius + hole_thickness;
track_thickness = 1.8; // [1:0.2:4]
track_radius = track_thickness / 2;
track_width = 10; // [4:40]
overhang_height = 3; // [1:0.5:10]
holder_height = 3; // [1:0.2:10]
remaining_track_extension = 4; // [2:1:15]
track_half_height = overhang_height + holder_height + remaining_track_extension;
track_height = track_half_height * 2;
left_side_track_start = 
    zrot(-45, 
        right(holder_radius + print_clearance + track_radius, 
            [0, 0]));
right_side_track_start = xflip(left_side_track_start);

function round_teardrop(r1, r2, p2) = 
    let(
        oval1 = oval(r = r1),
        oval2 = move(p2, oval(r = r2))
    )
    hull_points(flatten([oval1, oval2]));

function hull_points(points) = select(points, hull(points));

function hole(r, h) = 
    let(
        hole_overhang_side = 0.7
    )
    turtle([
        "move", r,
        "ymove", h - hole_overhang_side,
        "turn", 45,
        "untily", h,
        "xjump", 0,
        "ymove", -h
    ]);

module hole(r, h) {
    rotate_extrude($fn=60)
        region([hole(r, h)]);
}

// right side
function right_side_teardrop() = 
    round_teardrop(
        r1 = holder_radius, 
        r2 = track_radius, 
        p2 = right_side_track_start);

function move_to_right_side_of_track(points) = 
    move(right_side_track_start, points);

module right_side() {
    difference() {
        union() {
            // holder
            down(holder_height)
                linear_extrude(height=holder_height)
                    region([right_side_teardrop()]);

            // overhang
            down(holder_height)
            hull() {
                linear_extrude(height=0.1)
                    region([right_side_teardrop()]);

                down(overhang_height)
                linear_extrude(height=0.1)
                    region([move(right_side_track_start, oval(r = track_radius))]);
            }
        }

        // hole
        down(track_half_height - c)
            hole(r=hole_radius, h=track_half_height);
    }
}

// left side
function left_side_teardrop() = 
    round_teardrop(
        r1 = hole_radius - print_clearance, 
        r2 = track_radius, 
        p2 = left_side_track_start);

module left_side() {
    // cylinder
    snap_height = overhang_height;
    cylinder_height = holder_height + overhang_height;
    down(cylinder_height)
        hole(r=hole_radius - print_clearance, h=cylinder_height);

    // snap of cylinder
    cylinder_to_track_path = hull_points(flatten([
        move(left_side_track_start, oval(r=track_radius)),
        move(left_side_track_start + [-holder_radius - track_radius, hole_thickness], oval(r=track_radius))
    ]));
    hull() {
        down(cylinder_height)
        linear_extrude(height=0.1)
            region([oval(r=hole_radius - print_clearance)]);

        down(track_half_height)
        linear_extrude(height=0.7)
            region([cylinder_to_track_path]);
    }
}

function track_center_path() = 
    let(
        all_points = flatten([
            oval(d = track_thickness), 
            left(track_width, oval(d = track_thickness))
        ])
    )
    hull_points(all_points);

module track_center() {
    down(track_half_height)
    linear_extrude(height=track_half_height)
        move(right_side_track_start)
            region([track_center_path()]);
}

left_side_offset = track_width + left_side_track_start[0] - right_side_track_start[0];

module track_piece_internal(left = true, right = true) {
    zflip_copy(z=-track_half_height) {
        if (left) {
            right_side();  
        }

        if (right) {
            left(left_side_offset)
            left_side();
        }

        track_center();
    }
}

module track_piece(left = true, right = true, r = holder_radius, h = track_height, anchor=CENTER, spin=0, orient=UP) {
    anchors = [
        anchorpt("end_top", [-left_side_offset, 0, track_half_height], TOP, 0),
        anchorpt("end_bottom", [-left_side_offset, 0, -track_half_height], BOTTOM, 0),
        anchorpt("end_center", [-left_side_offset, 0, 0], TOP, 0)
    ];
    attachable(anchor, spin, orient, r=r, l=h, anchors=anchors) {
        up(track_half_height)
        track_piece_internal(left, right);
        children();
    }
}

spin = -45;
track_piece(left = false, spin=spin - 135)
position("end_center") track_piece(spin=spin)
position("end_center") track_piece(spin=spin)
position("end_center") track_piece(spin=spin)
position("end_center") track_piece(right = false, spin=spin);


