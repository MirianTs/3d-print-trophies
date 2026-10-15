// Karambit-in-stone trophy. All parts print flat / without supports.
//   "knife"   blade + tang + ring, flat                         (Burnt Titanium)
//   "scales"  2 handle scales: black base, red top (pause at layer 7) with grip grooves showing black
//   "rock"    low-poly stone with a slot for the blade tip and a flat front with a plate recess (Matte white)
//   "plate"   name plate: black backing, white text (pause at layer 6)
//   "assembled" colour preview;  "g_*" groups for the artefact-free render
part = "assembled";
winner = "სახელი გვარი";
title  = "CS 1st";
font_lat = "Arial:style=Bold"; font_geo = "Sylfaen";
$fn = 96;

// ---------- karambit 2D (x forward, y up; handle along +y, blade below) ----------
knife_t = 4.0;                 // core thickness
scale_base = 1.2; scale_top = 1.0;   // scale: black then red
function arc(c, r, a0, a1, n = 30) = [for (i = [0 : n]) let(a = a0 + (a1 - a0) * i / n) [c[0] + r * cos(a), c[1] + r * sin(a)]];
tip = [44, -22];
module blade_2d() {
    polygon(concat(arc([26, 2], 32, 180, 300), [tip], arc([27, 5], 23, 290, 180)));
}
module handle_2d() {   // slightly curved grip
    hull() for (p = [[0, 0], [1.5, 20], [1, 40], [-1, 55]]) translate(p) circle(r = 7);
}
module ring_2d(hole = true) { translate([-1, 68]) difference() { circle(r = 11); if (hole) circle(r = 7); } }
module knife_2d() { union() { blade_2d(); handle_2d(); ring_2d(); translate([-9, -1]) square([18, 3]); } }

module knife_core() { linear_extrude(knife_t) knife_2d(); }

// handle scale (one side). Print with the black face down; mirror for the other side.
module scale_2d() { difference() { offset(delta = -0.6) handle_2d(); } }
module scale_piece() {
    difference() {
        linear_extrude(scale_base + scale_top) scale_2d();
        // grip grooves through the red layer to show the black underneath
        translate([0, 0, scale_base]) linear_extrude(scale_top + 1) intersection() {
            offset(delta = -2.2) handle_2d();
            for (i = [0 : 12]) translate([-10, 4 + i * 4]) rotate(25) square([30, 1.2]);
        }
    }
}

// knife as assembled (core centred on z = 0), before placing in the rock
module knife_assembled(core = true, blk = true, red = true) {
    if (core) translate([0, 0, -knife_t / 2]) knife_core();
    for (s = [1, -1]) mirror([0, 0, s < 0 ? 1 : 0]) translate([0, 0, knife_t / 2]) {
        if (blk) intersection() { scale_piece(); translate([-50, -50, 0]) cube([100, 200, scale_base]); }
        if (red) intersection() { scale_piece(); translate([-50, -50, scale_base + 0.02]) cube([100, 200, 10]); }
    }
}

// ---------- placement: knife stands in the rock, tip down ----------
knife_rot = -28;      // tilt of the whole knife (0 = handle vertical)
rock_top = 30;
sink = 13;            // how deep the lowest part of the blade goes into the rock
blade_pts = concat(arc([26, 2], 32, 180, 300), [tip], arc([27, 5], 23, 290, 180));
function rot2(p, a) = [p[0] * cos(a) - p[1] * sin(a), p[0] * sin(a) + p[1] * cos(a)];
rot_pts = [for (p = blade_pts) rot2(p, knife_rot)];
low_y = min([for (p = rot_pts) p[1]]);
low_x = [for (p = rot_pts) if (p[1] == low_y) p[0]][0];
module place_knife() {
    // drop the knife so its lowest blade point is 'sink' below the rock top, centred over the rock
    translate([-low_x, 0, rock_top - sink - low_y]) rotate([90, 0, 0]) rotate([0, 0, knife_rot]) children();
}

// ---------- rock ----------
rock_seed = 7;
function ring_pts(n, rx, ry, z, jit, seed) = let(r = rands(-jit, jit, n * 2, seed))
    [for (i = [0 : n - 1]) let(a = 360 * i / n + r[2 * i] * 4) [cos(a) * (rx + r[2 * i + 1]), sin(a) * (ry + r[2 * i + 1]), z]];
module rock_raw() {
    pts = concat(ring_pts(11, 46, 34, 0, 2.5, rock_seed),
                 ring_pts(10, 40, 29, 14, 4, rock_seed + 1),
                 ring_pts(8, 27, 20, rock_top - 2, 4, rock_seed + 2),
                 [[4, 2, rock_top + 2], [-8, -3, rock_top], [10, -6, rock_top - 1]]);
    hull() for (p = pts) translate(p) cube(0.01, center = true);
}
plate_w = 60; plate_h = 15; plate_t = 1.0; text_h = 1.0;
front_y = -26;                       // flat front cut
module rock() {
    difference() {
        intersection() {
            rock_raw();
            translate([-100, front_y, 0]) cube([200, 200, 100]);
            translate([-100, -100, 0]) cube([200, 200, 100]);
        }
        // plate recess on the flat front
        translate([0, front_y - 0.01, 3 + plate_h / 2 + 0.5]) rotate([-90, 0, 0])
            linear_extrude(0.8) offset(delta = 0.3) square([plate_w, plate_h], center = true);
        // slot for the blade: the knife core grown by 0.3 mm
        place_knife() translate([0, 0, -knife_t / 2 - 0.3]) linear_extrude(knife_t + 0.6) offset(delta = 0.3) blade_2d();
    }
}

// ---------- plate ----------
module plate() {
    linear_extrude(plate_t) offset(r = 1) offset(delta = -1) square([plate_w, plate_h], center = true);
    translate([0, 0, plate_t - 0.01]) linear_extrude(text_h + 0.01) {
        difference() { offset(r = 1) offset(delta = -1) square([plate_w - 1.2, plate_h - 1.2], center = true);
                       offset(r = 0.4) offset(delta = -0.4) square([plate_w - 2.8, plate_h - 2.8], center = true); }
        translate([0, 3]) text(title, size = 4, font = font_lat, halign = "center", valign = "center", spacing = 1.1);
        translate([0, -3.3]) text(winner, size = 4, font = font_geo, halign = "center", valign = "center");
    }
}
module plate_placed() { translate([0, front_y + 0.8, 3 + plate_h / 2 + 0.5]) rotate([90, 0, 0]) children(); }

// ---------- outputs ----------
if (part == "knife") knife_core();
if (part == "scales") { scale_piece(); translate([30, 0, 0]) mirror([1, 0, 0]) scale_piece(); }
if (part == "rock") rock();
if (part == "plate") plate();

if (part == "g_rock") rock();
if (part == "g_core") place_knife() knife_assembled(true, false, false);
if (part == "g_blk") place_knife() knife_assembled(false, true, false);
if (part == "g_red") place_knife() knife_assembled(false, false, true);
if (part == "g_plate_blk") plate_placed() intersection() { plate(); translate([-50, -50, -1]) cube([100, 100, plate_t + 1]); }
if (part == "g_plate_wht") plate_placed() intersection() { plate(); translate([-50, -50, plate_t + 0.02]) cube([100, 100, 5]); }

if (part == "assembled") {
    color([0.92, 0.91, 0.88]) rock();
    place_knife() {
        color([0.30, 0.33, 0.42]) knife_assembled(true, false, false);
        color([0.10, 0.10, 0.10]) knife_assembled(false, true, false);
        color([0.80, 0.10, 0.10]) knife_assembled(false, false, true);
    }
    plate_placed() color([0.1, 0.1, 0.1]) plate();
}
