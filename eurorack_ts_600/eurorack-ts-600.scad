// based on the datasheet here https://www.farnell.com/datasheets/1928824.pdf

/*
    all top-level modules in this file:

    - flat_template(); // 2d template for laser cutter / 2d printer
    - drill_template(); // 3d template for 3d printing
    - flat_template_with_only_rail_profiles(); // 2d template without the position holder, and including rail profiles. Use this for laser cutting the holes.
    - ts600() // a single rail profile
    - module mounting_holes(show_right=true, show_left=true) // make circles that indicate where the mounting holes should be drilled relative to the ts600 profile
    - rounded_rectangle(x,y,roundness); // make a 2d rounded rect, forkd from https://www.thingiverse.com/thing:213733
*/

// customizable parameters:

body_height=3;
arrow_offset=0.5;
spine_offset=1;
is_flat=false; // if true, we're just making an outline not a 3d shape

// everything after this is ts-600 or eurorack spec stuff you won't want to modify

one_inch = 25.4; // one inch in mm

eurorack_screw_distance = 122.50; // mm

circle_quality = 100;

total_x = one_inch; // total width of a profile along the x-axis
total_y = 0.291 * one_inch;  // total height of a profile along the y-axis

half_total_x = total_x/2; // convenient half-width helper
half_total_y = total_y/2; // convenient half-height helper

screw_hole_opening_width = 0.118 * one_inch; // the opening of the screw-hole
half_screw_hole_opening_width = screw_hole_opening_width/2;

opening_depth = 0.073 * one_inch; // the depth of the screw hole's opening

side_screw_cavern_y = 0.203 * one_inch;
side_screw_cavern_y_half = side_screw_cavern_y/2;
side_screw_cavern_x = 0.104 * one_inch;
side_screw_center_x = 0.750 * one_inch / 2;

side_screw_back_slot_x = 0.050 * one_inch;

middle_hole_y_offset = 0.055 * one_inch;
middle_screw_hole_inset_y = middle_hole_y_offset + (side_screw_cavern_x/2);
middle_screw_hole_center_y = (half_total_y) - middle_screw_hole_inset_y;

screw_radius = sqrt(half_screw_hole_opening_width^2+(side_screw_cavern_x/2)^2);

module screw_hole(starting_x) {
    module half_screw_hole(starting_x) {
        polygon(points = [
        /* 1 */ [starting_x, 0],
        /* 2 */ [starting_x,half_screw_hole_opening_width],
        /* 3 */ [starting_x+opening_depth, half_screw_hole_opening_width],
        /* 4 */ [starting_x+opening_depth, side_screw_cavern_y_half],
        /* 5 */ [starting_x+opening_depth+side_screw_cavern_x, side_screw_cavern_y_half],
        /* 6 */ [starting_x+opening_depth+side_screw_cavern_x, half_screw_hole_opening_width],
        /* 7 */ [starting_x+opening_depth+side_screw_cavern_x+side_screw_back_slot_x, half_screw_hole_opening_width],
    
        /* mid */ [starting_x+opening_depth+side_screw_cavern_x+side_screw_back_slot_x, 0],
        ]);
    }

    union() {
        half_screw_hole(starting_x);
        mirror([0,1,0]) half_screw_hole(starting_x);
    }
}

module ts600() {
    module half_ts600() {
        difference() {
            translate([-half_total_x/2,0,0]) square(size = [half_total_x, total_y], center = true);
            translate([-half_total_x,0,0]) screw_hole(0);
            translate([0,half_total_y+(opening_depth-middle_hole_y_offset),0]) rotate(-90, [0,0,1]) screw_hole(0);
        }
    }

    half_ts600();
    mirror([16,0,0]) half_ts600();
}

module mounting_holes(show_right=true, show_left=true) {
    // ** make rail mounting holes
    // center:
    translate([0,middle_screw_hole_center_y,0]) circle(r=screw_radius, $fn=circle_quality);
    // left
    if (show_left) {
        translate([-side_screw_center_x,0,0]) circle(r=screw_radius, $fn=circle_quality);
    }
    // right
    if (show_right) {
        translate([side_screw_center_x,0,0]) circle(r=screw_radius, $fn=circle_quality);
    }
}

// rounded rect module taken from https://www.thingiverse.com/thing:213733
// then made 2D for compatibility

module rounded_rectangle(x,y,roundness) {
    module semi_rounded_rectangle(x,y,roundness) {
        module rounded_edge(r) {
            translate([r / 2, r / 2, 0])
            difference() {
                square([r + 0.01, r + 0.01], center=true);
                translate([r/2, r/2, 0])
                    circle(r=r, $fn=circle_quality);
            }
        }
    
        difference() {	
            square([x,y], center=true);
            translate([-x/2,-y/2,0]) rounded_edge(roundness);
            rotate([0,0,-180]) translate([-x/2,-y/2,0]) rounded_edge(roundness);
            rotate([0,0,90]) translate([x/2,y/2,0]) rounded_edge(roundness);
        }
    }

    intersection() {
        semi_rounded_rectangle(x,y,roundness);
        mirror([1,0,0]) semi_rounded_rectangle(x,y,roundness);
    }
}

// end rounded rect module

module arrow(height=4, width=6) {
    module half_arrow(height, width) {
        polygon([
            [-width,0],
            [-width,height/2],
            [0,height/2],
            [0,height],
            [width,0]
        ]);
    }
    rotate(180,[0,0,1])
    union() {
        half_arrow(height/2, width/2);
        mirror([0,1,0]) half_arrow(height/2, width/2);
    }

}

module flat_template() {
    union() {
        difference() {
            union() {
                translate([0,eurorack_screw_distance/2,0]) rounded_rectangle(total_x, total_y, total_y/4);
                square([10, eurorack_screw_distance-6], center=true);
                translate([0,-eurorack_screw_distance/2,0]) rounded_rectangle(total_x, total_y, total_y/4);
            }
        
            translate([0,-eurorack_screw_distance/2,0]) {
                //ts600();
                mounting_holes(show_left=false);
            }
        
            translate([0,eurorack_screw_distance/2,0])
                rotate(180, [0,0,1]) {
                    //ts600();
                    mounting_holes(show_right=false);
                };
                
            // arrow_marker
            translate([-8,eurorack_screw_distance/2,0]) arrow(height=4, width=6);
            translate([-8,-eurorack_screw_distance/2,0]) arrow(height=4, width=6);
        }
    }
}

module flat_template_with_only_rail_profiles() {
    union() {
            translate([0,-eurorack_screw_distance/2,0]) {
                ts600();
                mounting_holes(show_left=false);
            }
        
            translate([0,eurorack_screw_distance/2,0])
                rotate(180, [0,0,1]) {
                    ts600();
                    mounting_holes(show_right=false);
                };
        }
}


module drill_template() {
    union() {
        linear_extrude(height=body_height) difference() {
            union() {
                translate([0,eurorack_screw_distance/2,0]) rounded_rectangle(total_x, total_y, total_y/4);
                square([10, eurorack_screw_distance-6], center=true);
                translate([0,-eurorack_screw_distance/2,0]) rounded_rectangle(total_x, total_y, total_y/4);
            }
        
            translate([0,-eurorack_screw_distance/2,0]) {
                //ts600();
                mounting_holes(show_left=false);
            }
        
            translate([0,eurorack_screw_distance/2,0])
                rotate(180, [0,0,1]) {
                    //ts600();
                    mounting_holes(show_right=false);
                };
        }
        // extrude a spine
        linear_extrude(height=body_height+spine_offset) rounded_rectangle(3, eurorack_screw_distance-10, 1.5);
        // arrow_marker
        linear_extrude(height=body_height+arrow_offset) translate([-8,eurorack_screw_distance/2,0]) arrow(height=4, width=6);
        linear_extrude(height=body_height+arrow_offset) translate([-8,-eurorack_screw_distance/2,0]) arrow(height=4, width=6);
    }
}


if (is_flat) {
    flat_template();
} else {
    drill_template();
}
