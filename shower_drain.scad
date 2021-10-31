include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

module __Customizer_Limit__ () {}

$fn = 24;

drain_thickness = 4.5;
drain_height = 110;
hole_diameter = 5.5;
hole_radius = hole_diameter / 2;

module hole_mask(xy1, xy2) {
    hole_offset_z = 15;
    hole_profile = turtle([
        "arcsteps", 8,
        "ymove", -hole_offset_z, 
        "xmove", hole_radius * 1.8,
        "jump", [hole_radius, 0],
        "setdir", 90,
        "arcright", hole_radius, 90,
        "ymove", 1,
        "xmove", -hole_radius,
        "xmove", -hole_radius,
        "yjump", 0]);

    path_extrude2d([[xy1[0], xy1[1], 0], [xy2[0], xy2[1], 0]])
        region([xflip(p = hole_profile), hole_profile]);
}

module shower_drain_base() {
    // top plate
    cube(size=[drain_height, drain_height, drain_thickness], anchor=BOTTOM)

    // bottom support 
    intersection() {
        zcyl(h = 100, d = 105);

        bottom_half()
        move(z = -12)
        spheroid(d = 325, style = "icosa", anchor = BOTTOM);
    }
}

difference() {
    small_hole_lenght = 22;
    big_hole_lenght = 42;
    distance_between_holes = 12;

    zrot(45)
    shower_drain_base();

    // holes
    move(z = drain_thickness - hole_radius)
    zrot_copies(n = 4, cp = [0, 0, 0])
    move(y = distance_between_holes)
    union() {
        hole_mask([0, 0], [0, big_hole_lenght]);

        xflip_copy()
        move(y = (big_hole_lenght - small_hole_lenght) / 2, x = distance_between_holes)
        hole_mask([0, 0], [0, small_hole_lenght]);
    }
}




