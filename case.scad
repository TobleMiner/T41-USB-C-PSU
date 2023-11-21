$fn = 100;

module post(height=1.6) {
    cylinder(height, d=2.2 - 0.1);
}

module posts(height=1.6) {
    translate([2.3, 2.1, 0]) post();
    translate([26.95, 2.1, 0]) post();
    translate([48, 2.1, 0]) post();
    translate([2.3, 15.9, 0]) post();
    translate([48, 15.9, 0]) post();
}

module upstream_port(depth=7.35) {
    width = 8.94 + 0.1;
    height = 3.16 + 0.1;
    color("#bbb") translate([-width/2, -4.84 - (depth - 7.35), 0]) {
        translate([height/4, 0, height/4]) {
            translate([0, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
            translate([width - height / 2, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
            translate([0, 0, height - height/2]) {
                translate([0, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
                translate([width - height / 2, depth/2, 0]) rotate([90, 0, 0]) cylinder(depth, d=height/2, center=true);
            }
        }
        translate([0, 0, height/4]) cube([width, depth, height - height/2]);
        translate([height/4, 0, 0]) cube([width - height/2, depth, height]);
    }
}

module pcb() {
    difference() {
        color("green") translate([-0.05, -0.05, 0]) cube([50 + 0.1, 18 + 0.1, 1.6 + 0.01]);
        posts();
    };
    translate([0, 0, 1.6]) {
        translate([29.946, 12.114, 0]) color("#666") linear_extrude(3.7 + 0.5) square([9, 9.5], center=true); // Inductor
        translate([4.3, 9, 0]) rotate([0, 0, -90]) upstream_port(); // USB-C port
        translate([4, 1, 0]) cube([46, 16, 2]); // SMD components
        translate([9.7, 10.2, 0]) color("#333") linear_extrude(3) square([3.5, 7], center=true); // TVS diode
        translate([6.5, 2.3, 0]) linear_extrude(2) square([3.6, 3.7], center=true);
    }
    translate([0, 0, -1]) {
        difference() {
            union() {
                translate([3, 2, 0]) cube([47, 14, 1.1]); // Thermal pad
                translate([50, 3, 0]) cube([1, 12, 6]); // Connection area
            }
            posts();
        }
    }
}

module pcb_case() {
    pcb();
    translate([0, 0, 1.6]) {
        translate([2, 9, 0]) rotate([0, 0, -90]) upstream_port(); // USB-C port extension
    }
}

module pcb_bottom_case() {
    pcb_case();
    translate([-0.05, -0.05, 1.6]) {
        cube([50 + 0.1, 18 + 0.1, 5]); // Ensure no overlap over PCB
    }
}

module pcb_top_case() {
    pcb_case();
    translate([0, 0, 1.6]) {
        translate([4.3, 9, 0]) linear_extrude(3.16 / 2) square([7.35, 8.94 + 0.1], center=true);
        translate([3, 9, 0]) linear_extrude(3.16 / 2) square([7.35, 8.94 + 0.1], center=true);
    }
    posts();
}

module rounded_rect(x, y, z, r) {
    translate([r, r, 0]) {
        cylinder(z, r=r);
        translate([x - r * 2, 0, 0]) cylinder(z, r=r);
        translate([0, y - r * 2]) {
            cylinder(z, r=r);
            translate([x - r * 2, 0, 0]) cylinder(z, r=r);
        }
    }
    translate([r, 0, 0]) cube([x - r*2, y, z]);
    translate([0, r, 0]) cube([x, y - r*2, z]);
}

module hexagon(h, r) {
    translate([0, 0, h/2]) cylinder(h, r=r, center=true, $fn=6);
}

module hex_nut() {
    hexagon(1.6, 4.32/2);
}

module hex_screw() {
    translate([0, 0, 7.7]) cylinder(1.9, d=3.7);
    cylinder(9.6, d=2.2);
}

module hex_screw_nut() {
    color("#ccc") {
        hex_screw();
        translate([0, 0, 1.5]) hex_screw();
        hex_nut();
        translate([0, 0, -0.5]) hex_nut();
    }
}

module features() {
    translate([0, 0, 0.1]) {
        translate([3.5, 3.5, 0]) hex_screw_nut();
        translate([65 - 3.5, 3.5, 0]) hex_screw_nut();
        translate([0, 30 - 3.5, 0]) {
            translate([3.5, 0, 0]) hex_screw_nut();
            translate([65 - 3.5, 0, 0]) hex_screw_nut();
        }
    }
}

module bottom_case() {
    difference() {
        rounded_rect(65, 30, 6, 3);
        union() {
            translate([2, 6, 3]) pcb_bottom_case();
            features();
            translate([53, 9, 3 + 1.6]) cube([20, 12, 3]); // Connection area
        }
    }
    translate([60 - 5.4, 15 - 2, 0]) cylinder(8, r=1.5);
    translate([60 - 1.6, 15 + 2, 0]) cylinder(8, r=1.5);
    translate([60 + 2.2, 15 - 2, 0]) cylinder(8, r=1.5);
}

module top_case() {
    difference() {
        union() {
            translate([2 + 0.2, 6 + 0.1, 4.6]) cube([50 - 0.4, 18 - 0.2, 1.4]);
            translate([0, 0, 6]) rounded_rect(65, 30, 5, 3);
        }
        union() {
            translate([2, 6, 3]) pcb_top_case();
            features();
            translate([60 - 5.4, 15 - 2, 0]) cylinder(8 + 0.1, r=1.5 + 0.1);
            translate([60 - 1.6, 15 + 2, 0]) cylinder(8 + 0.1, r=1.5 + 0.1);
            translate([60 + 2.2, 15 - 2, 0]) cylinder(8 + 0.1, r=1.5 + 0.1);
            translate([53, 9, 3 + 1.6]) cube([20, 12, 3]); // Connection area
        }
    }
}

module case() {
    //bottom_case();
    top_case();
}

difference() {
    case();
    union() {
        translate([6.5, 0, 0]) {
            translate([0, 2, 2]) cube([47.5, 2, 6]);
            translate([47.5, 2, 2]) cube([4.5, 5, 6]);
            translate([0, 26, 2]) cube([47.5, 2, 6]);
            translate([47.5, 23, 2]) cube([4.5, 5, 6]);
        }
        translate([0, 0, 6]) {
            translate([12, 7 + 6, 0]) cube([7, 10, 3]);
            translate([19, 7 + 10, 0]) cube([8, 6, 3]);
            translate([19, 7, 0]) cube([8, 5, 3]);
            translate([27, 7, 0]) cube([15, 16, 3]);
            translate([47, 7, 0]) cube([5, 16, 3]);
        }
    }
}

