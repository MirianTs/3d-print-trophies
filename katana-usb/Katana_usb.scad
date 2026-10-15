// Katana USB-stick case (approximate dimensions from photos — adjust the PCB values below after measuring).
// Parts (all print without supports):
//   "handle_half" x2 : tsuka (handle) + tsuba (guard) + kashira (pommel with lanyard hole), split at the PCB mid-plane.
//                      Print split face down; glue the two halves with 1.75 mm filament pins in the pin holes.
//   "blade"          : cap shaped as the blade, slides over the USB plug.
part = "plate";
$fn = 64;

// ---------- USB stick (measured approx.) ----------
pcb_l  = 29.5;   // green board length, from the metal plug to the end
pcb_w  = 13.2;   // board width
stick_h = 5.0;   // thickest point (board + chip + back components) — cavity is a bit taller
plug_w = 12.0; plug_h = 4.5;   // standard USB-A plug
clr = 0.3;       // clearance per side

// ---------- handle ----------
wall   = 1.6;
cav_w  = pcb_w + 2 * clr;
cav_h  = max(stick_h, plug_h) + 2 * clr;
W      = cav_w + 2 * wall;          // handle width  (y)
H      = cav_h + 2 * wall;          // handle height (z), split at z = 0
pom_l  = 9;                          // pommel length (solid, lanyard hole)
cav_x0 = pom_l;
cav_x1 = cav_x0 + pcb_l + 1.5;       // 1.5 mm of the metal plug sits inside
fw     = 1.5;                        // front wall of the handle
tsuba_t = 2.5; tsuba_ry = 12.5; tsuba_rz = 9.5;
x_tsuba = cav_x1 + fw;
x_front = x_tsuba + tsuba_t;
pin_d = 1.95; pin_depth = 3;
pins = [[pom_l - 2.2, 4], [pom_l - 2.2, -4], [x_tsuba + tsuba_t / 2, 10.3], [x_tsuba + tsuba_t / 2, -10.3]];
lanyard_d = 3.2; lanyard_x = 3.6;

// rounded-rectangle bar along x (an ellipse would let the rectangular cavity break through the corners)
module oval_bar(x0, x1, w, h) { r = min(2.6, h / 2 - 0.01); translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) offset(r = r) square([w - 2 * r, h - 2 * r], center = true); }

module handle_full() {
    difference() {
        union() {
            oval_bar(0, x_tsuba, W, H);
            // kashira (pommel cap) and fuchi (collar) bands
            hull() { oval_bar(1.2, pom_l - 2.5, W + 1.2, H + 1.2); oval_bar(0, 0.01, W - 1, H - 1); }
            oval_bar(x_tsuba - 2.4, x_tsuba, W + 1.0, H + 1.0);
            // tsuka-ito wrap: raised diamond bands on the top and bottom faces
            intersection() {
                oval_bar(pom_l - 2.5, x_tsuba - 2.4, W + 1.2, H + 1.2);
                union() for (s = [-1, 1]) for (i = [-2 : 8])
                    translate([pom_l + i * 5.5, 0, 0]) rotate([0, 0, s * 52]) cube([1.4, 60, 30], center = true);
            }
            // tsuba (guard) with a raised rim
            translate([x_tsuba, 0, 0]) rotate([0, 90, 0]) scale([tsuba_rz / tsuba_ry, 1, 1]) cylinder(r = tsuba_ry, h = tsuba_t, $fn = 96);
            translate([x_tsuba + tsuba_t - 0.01, 0, 0]) rotate([0, 90, 0]) scale([tsuba_rz / tsuba_ry, 1, 1])
                difference() { cylinder(r = tsuba_ry, h = 0.6, $fn = 96); translate([0, 0, -1]) cylinder(r = tsuba_ry - 1.2, h = 3, $fn = 96); }
        }
        // cavity for the board
        translate([cav_x0, -cav_w / 2, -cav_h / 2]) cube([cav_x1 - cav_x0 + 0.01, cav_w, cav_h]);
        // opening for the metal plug through the front wall and the guard
        translate([cav_x1 - 0.5, -(plug_w / 2 + clr), -(plug_h / 2 + clr)]) cube([20, plug_w + 2 * clr, plug_h + 2 * clr]);
        // decorative cut-outs in the guard (two small kidney windows)
        for (s = [-1, 1]) translate([x_tsuba - 1, s * 9.3, 0]) rotate([0, 90, 0]) scale([1.6, 1, 1]) cylinder(r = 1.2, h = 10);
        // lanyard hole through both halves
        translate([lanyard_x, 0, -20]) cylinder(d = lanyard_d, h = 40);
    }
}

module handle_half() {
    difference() {
        intersection() { handle_full(); translate([-5, -50, 0]) cube([100, 100, 50]); }
        for (p = pins) translate([p[0], p[1], -0.01]) cylinder(d = pin_d, h = pin_depth, $fn = 24);
    }
}

// ---------- blade cap (lies flat, edge towards -y, slight curve) ----------
cap_l    = 15;                         // habaki / collar part that holds the plug
pocket_d = 13;                         // how deep the plug goes in
cap_w = plug_w + 2 * clr + 2 * 1.8;
cap_h = plug_h + 2 * clr + 2 * 1.4;
blade_l = 62; sori = 3.5;              // blade length and curvature
function by(t) = sori * t * t;         // centre-line offset
module blade_section(w, t) {           // cross-section in (y, z): thin edge at -y, ridge (shinogi) near the back
    polygon([[-w / 2, 0], [w / 2, 0], [w / 2, t * 0.75], [w * 0.22, t], [-w * 0.2, t * 0.55], [-w / 2, 0.5]]);
}
module slice(x, y, w, t) { translate([x, y, 0]) rotate([90, 0, 90]) linear_extrude(0.4, center = true) blade_section(w, t); }   // thick slices so neighbouring hulls overlap
module blade() {
    difference() {
        union() {
            // habaki collar
            hull() {
                translate([0, -cap_w / 2, 0]) cube([cap_l, cap_w, cap_h - 1]);
                translate([0.6, -cap_w / 2 + 0.6, 0]) cube([cap_l - 1.2, cap_w - 1.2, cap_h]);
            }
            // blade body
            n = 24;
            for (i = [0 : n - 1]) hull() {
                for (j = [i, i + 1]) {
                    t = j / n;
                    w = 14 - 4.5 * t; th = 6.4 - 3.6 * t;
                    if (j < n) slice(cap_l - 0.5 + t * blade_l, by(t), w, th);
                    else {   // kissaki (tip): angled point towards the edge side
                        translate([cap_l - 0.5 + blade_l + 7, by(1) - 2.5, 0]) cylinder(d = 1.2, h = 1.2);
                        slice(cap_l - 0.5 + t * blade_l, by(t), w, th);
                    }
                }
            }
        }
        // pocket for the USB plug
        translate([-0.01, -(plug_w / 2 + clr), (cap_h - plug_h) / 2 - clr]) cube([pocket_d, plug_w + 2 * clr, plug_h + 2 * clr]);
    }
}

// ---------- output ----------
if (part == "handle_half") handle_half();
if (part == "blade") blade();
if (part == "plate") {           // everything for one print
    handle_half();
    translate([0, 30, 0]) handle_half();
    translate([0, -28, 0]) blade();
}
if (part == "assembled") {
    color("dimgray") { handle_half(); mirror([0, 0, 1]) handle_half(); }
    color("silver") translate([x_front + 0.5, 0, -cap_h / 2]) blade();
}

