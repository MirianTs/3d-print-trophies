// Two plates for the darts trophy, printed together: black backing (0..plate_t), white raised text (plate_t..plate_t+text_h).
// Colour change: pause at the first layer above plate_t.
plate_t = 1.0;   // black backing
text_h  = 1.0;   // white raised text
r_c = 1.0;       // corner radius
part = "both";

module rplate(w, h) {
    linear_extrude(plate_t) offset(r = r_c) offset(delta = -r_c) square([w, h], center = true);
}
module raised(w, h) {   // thin white border around the plate edge
    translate([0, 0, plate_t - 0.01]) linear_extrude(text_h + 0.01)
        difference() {
            offset(r = r_c) offset(delta = -r_c) square([w - 1.2, h - 1.2], center = true);
            offset(r = r_c - 0.6) offset(delta = -(r_c - 0.6)) square([w - 2.8, h - 2.8], center = true);
        }
}

// "DARTS 1st" — glued on the front of the upper step (flat face ~84 x 8 mm)
module darts_plate() {
    w = 70; h = 7.4;
    rplate(w, h);
    raised(w, h);
    translate([0, 0, plate_t - 0.01]) linear_extrude(text_h + 0.01)
        text("DARTS  1st", size = 4.4, font = "Arial:style=Bold", halign = "center", valign = "center", spacing = 1.12);
}

// name plate — sits in the 76 x 9 mm recess on the lower step
module name_plate() {
    w = 75.2; h = 8.2;
    rplate(w, h);
    raised(w, h);
    translate([0, -0.3, plate_t - 0.01]) linear_extrude(text_h + 0.01)
        text("სახელი გვარი", size = 4.6, font = "Sylfaen", halign = "center", valign = "center", spacing = 1.08);
}

if (part == "both") { translate([0, 7, 0]) darts_plate(); translate([0, -7, 0]) name_plate(); }
