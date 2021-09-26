include <BOSL2/std.scad>
include <BOSL2/hull.scad>

wall_thickness = 1.2;
print_clearance = 0.15;
eps = 0.001;

$fn = 48;

box_width = 100/1.8;
box_depth = 80/1.8; 
box_height = 35/1.8; 

bottom_path = rect([box_width, box_depth], rounding = 5, anchor = LEFT) ;

path = turtle([
    "jump", [box_width, 0]]
);

module rail(anchor) {
    diff("diff")
    rect([wall_thickness * 3 + print_clearance * 2, wall_thickness], anchor = anchor) {
        position(CENTER) 
        tags("diff") 
        rect(
            [wall_thickness + print_clearance * 2, wall_thickness + eps], 
            anchor = CENTER);
    }  
}

module box() {
    linear_extrude(box_height) {
        stroke(bottom_path, closed = true, width = wall_thickness); 

        stroke(path, width = wall_thickness);
    }

    yflip_copy()
    linear_extrude(box_height * 0.75) {
        move(x = box_width / 2, y = box_depth / 2 - wall_thickness / 2)
        #rail(BACK);

        move(x = box_width / 2, y = wall_thickness / 2.1)
        rail(FRONT);
    }

    linear_extrude(wall_thickness)
    region([bottom_path]);
}

module separator() {
    linear_extrude(wall_thickness)
    rect(
        [box_depth / 2 - wall_thickness - print_clearance * 2, box_height - wall_thickness - print_clearance], 
        rounding = [2, 2, 0, 0]);
}

left(50)
separator();

box();