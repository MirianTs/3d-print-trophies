// Darts trophy v2 — three separate prints, no supports:
//   part = "board"     dartboard lying face-up; colour changes by height:
//                      black body (0..T) -> red raised segments (T..T+1) -> white wires/numbers (T+1..T+2)
//   part = "base"      stepped base with cradle + slot for the board tab, name-sticker recess (text printed separately)
//   part = "dart"      dart lying flat, peg plugs into treble-20
//   part = "assembled" preview only
part = "assembled";
$fn = 96;
font_bold = "Arial:style=Bold";

// ---------- board ----------
R = 55;           // board radius
T = 6;            // board thickness  (colour change 1 at z = T)
h_seg = 1.0;      // red segment relief (colour change 2 at z = T + h_seg)
h_top = 2.0;      // white wires / numbers / bull / rim height above the face
r_bull = 2.2; r_obull = 4.8; r_tri_in = 23.2; r_tri_out = 26.2; r_dbl_in = 39; r_dbl_out = 42.5;
wire = 0.9;
nums = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5];
function ang(i) = 90 - 18 * i;   // clockwise from the top as seen from the front

// tab on the bottom edge of the board (flush with the back face so it prints without support)
tab_w = 24; tab_len = 8; tab_t = 4;
clear = 0.3;      // per side, tab <-> slot
// dart socket in treble-20
peg_d = 4.0; hole_d = 4.6; hole_depth = 6;
t20 = [0, (r_tri_in + r_tri_out) / 2];

module sector(r1_, r2_, a1_, a2_) {
    r1 = r1_ + 0.15; r2 = r2_ - 0.15; a1 = a1_ + 0.4; a2 = a2_ - 0.4;
    polygon(concat([for (a = [a1 : (a2 - a1) / 12 : a2]) [r2 * cos(a), r2 * sin(a)]],
                   [for (a = [a2 : (a1 - a2) / 12 : a1]) [r1 * cos(a), r1 * sin(a)]]));
}
module ring(r, w) { difference() { circle(r + w / 2); circle(r - w / 2); } }

module segments_2d() {
    for (i = [0:19]) {
        a1 = ang(i) - 9; a2 = ang(i) + 9;
        if (i % 2 == 0) { sector(r_obull, r_tri_in, a1, a2); sector(r_tri_out, r_dbl_in, a1, a2); }
        else            { sector(r_tri_in, r_tri_out, a1, a2); sector(r_dbl_in, r_dbl_out, a1, a2); }
    }
    circle(r_obull - 0.15);
}
module wires_2d() {
    for (r = [r_obull, r_tri_in, r_tri_out, r_dbl_in, r_dbl_out]) ring(r, wire);
    for (i = [0:19]) rotate(ang(i) + 9) translate([r_obull, -wire / 2]) square([r_dbl_out - r_obull, wire]);
    circle(r_bull);
    ring(R - 1.2, 1.4);   // outer rim bead
}
module numbers_2d() {
    for (i = [0:19]) {
        a = ang(i); rn = (r_dbl_out + R) / 2;
        translate([rn * cos(a), rn * sin(a)])
            text(str(nums[i]), size = 5, font = font_bold, halign = "center", valign = "center");
    }
}

// board in print orientation: back on the bed, face up at z = T, "20" towards +Y, tab towards -Y
module board() {
    difference() {
        union() {
            cylinder(r = R, h = T);
            translate([-tab_w / 2, -R - tab_len, 0]) cube([tab_w, tab_len + 3, tab_t]);
            translate([0, 0, T - 0.01]) linear_extrude(h_seg + 0.01) segments_2d();
            translate([0, 0, T - 0.01]) linear_extrude(h_top + 0.01) { wires_2d(); numbers_2d(); }
        }
        translate([t20[0], t20[1], T + h_top - hole_depth]) cylinder(d = hole_d, h = hole_depth + 1, $fn = 48);
    }
}

// ---------- base ----------
base1 = [96, 56, 14];
base2 = [84, 44, 10];
top_z = base1[2] + base2[2];
cradle_h = 12;              // board's lowest point sits this far above the upper step
cz = top_z + cradle_h + R;  // board centre height when assembled
cradle_w = 60; cradle_t = 12;
// assembled board occupies y = 0 (face) .. T (back); the tab sits at the back: y = T - tab_t .. T
module chamfered_block(s, c) {
    hull() {
        translate([-s[0] / 2, -s[1] / 2, 0]) cube([s[0], s[1], s[2] - c]);
        translate([-s[0] / 2 + c, -s[1] / 2 + c, 0]) cube([s[0] - 2 * c, s[1] - 2 * c, s[2]]);
    }
}
module base() {
    by = T / 2;   // base centred under the board
    difference() {
        union() {
            translate([0, by, 0]) chamfered_block(base1, 2);
            translate([0, by, base1[2]]) chamfered_block(base2, 2);
            // cradle with a concave top that follows the board edge
            difference() {
                translate([-cradle_w / 2, by - cradle_t / 2, top_z - 0.01]) cube([cradle_w, cradle_t, cradle_h + 20]);
                translate([0, -50, cz]) rotate([-90, 0, 0]) cylinder(r = R, h = 100);
            }
        }
        // name-sticker recess
        translate([-38, by - base1[1] / 2 - 1, 2.5]) cube([76, 1.8, 9]);
        // slot for the board tab
        translate([-tab_w / 2 - clear, T - tab_t - clear, top_z + cradle_h - tab_len - 0.5])
            cube([tab_w + 2 * clear, tab_t + 2 * clear, tab_len + 20]);
    }
}

// ---------- dart ----------
dart_profile = [
    [0, 0], [0, peg_d / 2 - 0.3], [0.6, peg_d / 2], [5.5, peg_d / 2], [5.5, 3.6], [10, 3.6],
    [11, 3.1], [12, 3.6], [14, 3.6], [15, 3.1], [16, 3.6], [18, 3.6], [19, 3.1], [20, 3.6],
    [22, 3.6], [23, 3.1], [24, 3.6], [28, 3.6], [31, 2.0], [44, 2.0], [46, 1.6], [62, 1.6], [62, 0]
];
cut = 1.5;
module dart() {
    translate([0, 0, cut]) intersection() {
        union() {
            rotate([0, 90, 0]) rotate_extrude($fn = 48) polygon([for (p = dart_profile) [p[1], p[0]]]);
            translate([0, 0, -cut]) linear_extrude(1.4) polygon([[44, 0], [50, 11], [62, 13], [62, -13], [50, -11]]);
        }
        translate([-1, -20, -cut]) cube([70, 40, 20]);
    }
}

// ---------- dart in two halves (glue together) ----------
// Each half: half of the round body on its flat face, half-thickness of the two "horizontal" flights,
// plus one full upright flight. Two identical halves glued face to face = round dart with 4 flights.
fl_t = 1.2;        // flight thickness
dowel_d = 1.95;    // holes for 1.75 mm filament pieces used as alignment pins
dowel_x = [13, 21];
module flight_2d() { polygon([[44, 0], [50, 11], [62, 13], [62, 0]]); }   // one wing, in (x, out)
module dart_half() {
    difference() {
        union() {
            intersection() {
                rotate([0, 90, 0]) rotate_extrude($fn = 64) polygon([for (p = dart_profile) [p[1], p[0]]]);
                translate([-1, -20, 0]) cube([70, 40, 20]);
            }
            // horizontal flights: half their thickness on the bed
            linear_extrude(fl_t / 2) { flight_2d(); mirror([0, 1]) flight_2d(); }
            // upright flight
            translate([0, fl_t / 2, 0]) rotate([90, 0, 0]) linear_extrude(fl_t) flight_2d();
        }
        for (x = dowel_x) translate([x, 0, -1]) cylinder(d = dowel_d, h = 4, $fn = 24);
    }
}

// ---------- output ----------
if (part == "dart_halves") { dart_half(); translate([0, 32, 0]) dart_half(); }
if (part == "dart_halves_assembled") { dart_half(); mirror([0, 0, 1]) dart_half(); }
if (part == "board") board();
if (part == "base")  base();
if (part == "dart")  dart();
if (part == "assembled") {
    color("dimgray") base();
    // stand the board up: face (+Z in print) -> -Y, "20" (+Y in print) -> +Z, back -> y = T
    color("black") translate([0, T, cz]) rotate([90, 0, 0]) board();
    color("red") translate([t20[0], -(h_top - hole_depth) - 0.5, cz + t20[1] - cut]) rotate([0, 0, -90]) dart();
}

