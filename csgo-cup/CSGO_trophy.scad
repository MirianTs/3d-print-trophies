// CS-style tournament trophy — classic cup with karambit-style knife handles, C4 brick, plates.
// Parts (all print without supports):
//   "cup"     upright; peg at the bottom fits the base socket         (Silk Bronze)
//   "knife"   print 2, flat; tab glues into the slot on the cup side    (Burnt Titanium)
//   "base"    stepped base, socket, name-plate recess                   (Matte black)
//   "c4"      small C4 brick glued on the base top                      (Burnt Titanium / black)
//   "plates"  "CT vs T" + winner name: black backing, white text (pause at layer 6)
//   "assembled" colour preview
part = "assembled";
winner = "სახელი გვარი";
$fn = 120;
font_lat = "Arial:style=Bold";
font_geo = "Sylfaen";

// ---------- cup ----------
outer = [[0, 0], [22, 0], [22, 2.5], [14, 6], [7, 10], [6, 22], [9, 25], [9, 28], [6, 31], [6, 38],
         [14, 46], [24, 56], [30, 70], [33, 88], [34, 100], [35.5, 101.5], [35.5, 103], [0, 103]];
inner = [[0, 60], [21, 60], [27.4, 71], [30.5, 88], [31.6, 100], [32.6, 104], [0, 104]];
peg_r = 6; peg_h = 6; sock_clr = 0.3;
boss_z = [70, 92]; slot_t = 3.4; slot_d = 5;
emboss = 2.0;

module cup_body() { rotate_extrude() polygon(outer); }
module cup_offset() { rotate_extrude() intersection() { offset(delta = emboss) polygon(outer); square([100, 200]); } }
// side bosses that hold the knives (45-degree wedge underneath so they print without support)
module boss(s) {
    mirror([s < 0 ? 1 : 0, 0, 0]) difference() {
        hull() {
            translate([26, -4, boss_z[0] + 8]) cube([10, 8, boss_z[1] - boss_z[0] - 8]);
            translate([26, -4, boss_z[0]]) cube([1, 8, 1]);
        }
        translate([36 - slot_d, -slot_t / 2, boss_z[0] + 6]) cube([slot_d + 1, slot_t, 30]);
    }
}
module cup() {
    difference() {
        union() {
            cup_body();
            translate([0, 0, -peg_h]) cylinder(r = peg_r, h = peg_h + 0.01);
            boss(1); boss(-1);
            // raised "1st" on the front
            intersection() {
                cup_offset();
                translate([0, 0, 79]) rotate([90, 0, 0]) linear_extrude(50)
                    text("1st", size = 17, font = font_lat, halign = "center", valign = "center");
            }
        }
        rotate_extrude() polygon(inner);
    }
}

// ---------- karambit knife (2D in u = outward, v = up; extruded 3 mm) ----------
knife_t = 3.0;
module knife_2d() {
    // tab that goes into the cup slot
    translate([-slot_d + 0.3, 2]) square([slot_d, 16]);
    // handle with finger grooves
    difference() {
        hull() { translate([0, 0]) square([7, 20]); translate([3.5, 21]) circle(r = 3.5); }
        for (v = [5, 10, 15]) translate([8.2, v]) circle(r = 1.6);
    }
    // finger ring
    translate([3.5, 27]) difference() { circle(r = 6.5); circle(r = 3.8); }
    // curved claw blade
    intersection() {
        difference() { translate([16, 5]) circle(r = 16); translate([20, 10]) circle(r = 15.2); }
        translate([2, -12]) square([40, 40]);
    }
    // guard
    translate([-0.5, -1.5]) square([9, 2.2]);
}
module knife() { linear_extrude(knife_t) knife_2d(); }

// ---------- base ----------
base1 = [80, 80, 14]; base2 = [66, 66, 10];
top_z = base1[2] + base2[2];
module chamfered_block(s, c) {
    hull() {
        translate([-s[0] / 2, -s[1] / 2, 0]) cube([s[0], s[1], s[2] - c]);
        translate([-s[0] / 2 + c, -s[1] / 2 + c, 0]) cube([s[0] - 2 * c, s[1] - 2 * c, s[2]]);
    }
}
module base() {
    difference() {
        union() { chamfered_block(base1, 2); translate([0, 0, base1[2]]) chamfered_block(base2, 2); }
        translate([0, 0, top_z - peg_h - 0.5]) cylinder(r = peg_r + sock_clr, h = peg_h + 1);
        translate([-36, -base1[1] / 2 - 1, 2.5]) cube([72, 1.8, 9]);   // name-plate recess
    }
}

// ---------- C4 brick ----------
module c4() {
    difference() {
        hull() for (x = [-10, 10], y = [-6, 6]) translate([x, y, 0]) cylinder(r = 1.5, h = 6, $fn = 24);
        translate([-8.5, 0.5, 5]) cube([8, 4.5, 2]);   // screen recess
    }
    for (i = [0:2], j = [0:3]) translate([1 + j * 2.4, -5 + i * 2.4, 6 - 0.01]) cube([1.8, 1.8, 0.8]);  // keypad
    for (y = [-3.5, 3.5]) translate([-12, y, 3]) rotate([0, 90, 0]) cylinder(r = 0.8, h = 24, $fn = 16);  // straps
}

// ---------- plates ----------
plate_t = 1.0; text_h = 1.0; r_c = 1.0;
module rplate(w, h) { linear_extrude(plate_t) offset(r = r_c) offset(delta = -r_c) square([w, h], center = true); }
module frame(w, h) {
    translate([0, 0, plate_t - 0.01]) linear_extrude(text_h + 0.01) difference() {
        offset(r = r_c) offset(delta = -r_c) square([w - 1.2, h - 1.2], center = true);
        offset(r = r_c - 0.6) offset(delta = -(r_c - 0.6)) square([w - 2.8, h - 2.8], center = true);
    }
}
module ct_plate() {
    w = 56; h = 7.4; rplate(w, h); frame(w, h);
    translate([0, 0, plate_t - 0.01]) linear_extrude(text_h + 0.01)
        text("CT  vs  T", size = 4.4, font = font_lat, halign = "center", valign = "center", spacing = 1.12);
}
module name_plate() {
    w = 71.2; h = 8.2; rplate(w, h); frame(w, h);
    translate([0, -0.3, plate_t - 0.01]) linear_extrude(text_h + 0.01)
        text(winner, size = 4.6, font = font_geo, halign = "center", valign = "center", spacing = 1.08);
}

// black backing + white text, for the colour preview
module pc() { color([0.10, 0.10, 0.10]) intersection() { children(); translate([-200, -200, -1]) cube([400, 400, plate_t + 0.95]); }
              color([0.96, 0.96, 0.96]) intersection() { children(); translate([-200, -200, plate_t + 0.05]) cube([400, 400, 5]); } }

// ---------- output ----------
if (part == "cup") cup();
if (part == "knife") { knife(); translate([0, 45, 0]) knife(); }
if (part == "base") base();
if (part == "c4") c4();
if (part == "plates") { translate([0, 7, 0]) ct_plate(); translate([0, -7, 0]) name_plate(); }
// assembled-position groups, exported separately for an artefact-free colour render
if (part == "g_cup") translate([0, 0, top_z]) cup();
if (part == "g_knives") for (s = [1, -1]) translate([0, 0, top_z]) mirror([s < 0 ? 1 : 0, 0, 0])
    translate([36 - slot_d + 0.3 + slot_d - 0.3, knife_t / 2, boss_z[0] + 6 - 2]) rotate([90, 0, 0]) knife();
if (part == "g_base") base();
if (part == "g_c4") translate([20, -20, top_z]) rotate([0, 0, 35]) c4();
module plates_placed() {
    translate([0, -base2[1] / 2, base1[2] + 4.2]) rotate([90, 0, 0]) children(0);
    translate([0, -base1[1] / 2 + 0.8, 7]) rotate([90, 0, 0]) children(1);
}
if (part == "g_plates_blk") plates_placed() {
    intersection() { ct_plate(); translate([-100, -100, -1]) cube([200, 200, plate_t + 1]); }
    intersection() { name_plate(); translate([-100, -100, -1]) cube([200, 200, plate_t + 1]); } }
if (part == "g_plates_wht") plates_placed() {
    intersection() { ct_plate(); translate([-100, -100, plate_t + 0.02]) cube([200, 200, 5]); }
    intersection() { name_plate(); translate([-100, -100, plate_t + 0.02]) cube([200, 200, 5]); } }

if (part == "assembled") {
    bronze = [0.80, 0.60, 0.32]; ti = [0.30, 0.33, 0.42]; blk = [0.10, 0.10, 0.10]; wht = [0.96, 0.96, 0.96];
    color(blk) base();
    color(bronze) translate([0, 0, top_z]) cup();
    for (s = [1, -1]) color(ti) translate([0, 0, top_z]) mirror([s < 0 ? 1 : 0, 0, 0])
        translate([36 - slot_d + 0.3 + slot_d - 0.3, knife_t / 2, boss_z[0] + 6 - 2]) rotate([90, 0, 0]) knife();
    color(ti) translate([20, -20, top_z]) rotate([0, 0, 35]) c4();
    translate([0, -base2[1] / 2, base1[2] + 4.2]) rotate([90, 0, 0]) pc() ct_plate();
    translate([0, -base1[1] / 2 + 0.8, 7]) rotate([90, 0, 0]) pc() name_plate();
}
