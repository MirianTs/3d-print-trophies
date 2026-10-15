// Full assembled darts trophy with the planned print colours (preview/render only).
include <Darts_trophy_v2.scad>
include <Darts_plates.scad>
part = "none";   // silence the included files' own outputs

bronze = [0.80, 0.60, 0.32];
blk = [0.10, 0.10, 0.10];
red = [0.80, 0.10, 0.10];
wht = [0.96, 0.96, 0.96];
e = 0.05;   // small gaps between colour bands to avoid z-fighting in the preview

module zband(z0, z1) { intersection() { children(); translate([-200, -200, z0]) cube([400, 400, z1 - z0]); } }

// base — Silk Bronze
color(bronze) base();

// board — black body, red segments, white wires/numbers
translate([0, T, cz]) rotate([90, 0, 0]) {
    color(blk) zband(-1, T - e) board();
    color(red) zband(T + e, T + h_seg - e) board();
    color(wht) zband(T + h_seg + e, T + 5) board();
}

// dart (two glued halves) — Silk Bronze, peg in treble 20
color(bronze) translate([t20[0], hole_depth - h_top - 0.5, cz + t20[1]]) rotate([0, 0, -90]) {
    dart_half(); mirror([0, 0, 1]) dart_half();
}

// "DARTS 1st" plate on the upper step, name plate in the recess — black backing, white text
module plate_colours() {
    color(blk) zband(-1, plate_t - e) children();
    color(wht) zband(plate_t + e, plate_t + text_h + 1) children();
}
by = T / 2;
translate([0, by - base2[1] / 2, base1[2] + 4.2]) rotate([90, 0, 0]) plate_colours() darts_plate();
translate([0, by - base1[1] / 2 + 0.8, 7]) rotate([90, 0, 0]) plate_colours() name_plate();
