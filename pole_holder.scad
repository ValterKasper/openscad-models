include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <BOSL2/screws.scad>

$fn = 48;

eps = 0.01;
height = 30;
difference() {
    difference() {
        hull() {
            up(height)
            linear_extrude(2)
            oval(d=30, anchor = CENTER);

            linear_extrude(2)
            rect([50, 50], rounding = 3, anchor = CENTER);
        }
        // left_half()
        cylinder_mask(l=32, r1=30, r2=15, rounding2=5, from_end=true, anchor = BOTTOM);
    }

    down(eps)
    union() {
        offset = 16;
        yflip_copy()
        xflip_copy()
        move(x = offset, y = offset)
        zcyl(d = 4, l = 3, anchor = BOTTOM) {
            position(TOP) zcyl(d = 8, l = 40, anchor = BOTTOM);
        };

        hole_diameter = 20;
        screw("M24", length=height + 2 + eps * 2, anchor=BOTTOM,  head="")
        position(TOP) rounding_hole_mask(d = hole_diameter, rounding = 5);
    }
}







