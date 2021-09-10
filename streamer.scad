include <BOSL2/std.scad>
include <BOSL2/hull.scad>

$fn = 64;

module center_blok() {   
    yrot(90)
    linear_extrude(100)
    shell2d(-1.8) {
        rect([40, 90], rounding = 10, anchor = CENTER);
    }
}

// include <BOSL2/beziers.scad>
// tri = [
//     [[-50,-33,0], [-25,16,50], [0,66,0]],
//     [[0,-33,50], [25,16,50]],
//     [[50,-33,0]]
// ];
// vnf = bezier_patch(tri, splinesteps=16);
// vnf_polyhedron(vnf);

r1 = yrot(45, p = path3d(rect(10, 20)));
r2 = xrot(30, p = path3d(rect(10, 20), fill = 70));
echo(str("Variable = ", r1));
//  skin([r1, r2], slices = 10);
// #stroke(r1, closed = true);
// #stroke(r2, closed = true);

path2 = turtle([
    "jump", [5, -2],
    "ymove", -3,
    "xmove", -10,
    "ymove", 3,
    "jump", [0, 0]
]);

angle = 15;
p1 = yrot(angle, p = path3d(path2));
p2 = yflip(yrot(-angle, p = path3d(path2)));

t1 = [[0, 0, 0], p1[1], p2[1], [0, 0, 0]];
t2 = [[0, 0, 0], p1[4], p2[4], [0, 0, 0]];

module doit(path) {
    skin([path, up(1, p = path)], slices = 3);
}

module part() {
    doit(p1);
    doit(p2);
    doit(t1);
    doit(t2);
}

xflip_copy(x = cos(angle) * 5)
yflip_copy(y = -5)
part();


