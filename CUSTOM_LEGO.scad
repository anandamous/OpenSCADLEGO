// FILE: CUSTOM_LEGO.scad
// AUTHOR: Anand T. Egan
// UPDATED: 2025-04-29
// FOR: 'CS 453 Robotics & 3D Printing' at the University of Alaska, Fairbanks

// LEGO® is a trademark of the LEGO Group of companies, which does not sponsor, authorize, or endorse this project.
// This script replicates LEGO®-style components such as bricks, tiles, and baseplates solely for educational purposes.
// The LEGO Group’s design of interlocking plastic bricks, including the appearance of LEGO® bricks, tiles, and baseplates,
// is protected by various intellectual property rights, including trademarks and design patents.
// This project is non-commercial and it's only intention is to explore 3D modeling concepts in OpenSCAD.

// ENTER THE BLOCK PARAMETERS HERE
// UNITS OF MEASUREMENT: STUDS

// The type of block?
// Brick - "brick" - (block with studs on top)
// Tile - "tile" - (block with no studs on top)
// plate - "plate" (1/3 height) *OR* directly change height to 1/3
// NOTE: When plate is select, height parameter is overriden and set to 1/3
// I was planning on more types of blocks, like slopes, or round, but I did not have enough time for that.
type = "brick"; //["brick", "tile", "plate" ]

// Length
// Enter an integer, no decimals/fractions
length = 2;

// Width
// Enter an integer, no decimals/fractions
width = 2;

// Height
// Enter a number, decimals/fractions allowed
// 
// '1' = Normal height, '1/3' = Plate height
height = 1.0;//[0.33:0.01:20]

// Create the bottom tubes?
// "true" or "false"
tubes = true;

// Recale the studs to be bigger?
// Helpful when printing with certain materials like PLA
// '1.00' - default
// '1.05' - helped with PLA on Prusa Mini+
stud_rescale = 1.03;

// Recale the bottom tubes to be bigger?
// Helpful when printing with certain materials like PLA
// '1.00' - default
// '1.01' - helped with PLA on Prusa Mini+
tube_rescale = 1.01;

block(
    type = type,
    length = length,
    width = width,
    height = height,
    tubes = tubes,
    stud_rescale = stud_rescale,
    tube_rescale = tube_rescale
);



module block(

    // The default parameters for a block; a classic 2x2 LEGO brick
    type = "brick",
    length = 2,
    width = 2,
    height = 1,
    tubes = true,
    stud_rescale = 1,
    tube_rescale = 1
    
    ) {
    
    // === CONSTANTS ===
    // Block dimension and structural constants
    block_height = 9.6;          // Height of a standard brick (Official LEGO standard is 9.6mm)
    wall_thickness = 1.45;       // Thickness of exterior walls of the block
    roof_thickness = 1;          // Thickness of the top of the block

    // Stud constants
    stud_diameter = 4.85;        // Diameter of the top stud (Official LEGO standard is 4.8mm)
    stud_height = 1.8;           // Height of the top stud (Official LEGO standard is 1.8mm)
    stud_spacing = 8;            // Distance between the centers of studs (Official LEGO standard is 8mm)

    // Tube constants - (bottom support structure)
    tube_diameter = 6.5;         // Diameter of interior support tubes
    tube_wall_thickness = 0.85;  // Thickness of the walls for center posts

    // Pin parameters - (used when block is 1 stud wide/long)
    pin_diameter = 3;            // Diameter of pin (Official LEGO standard is 3mm)
    pin_radius = pin_diameter / 2;

    // Utility constants
    precision = 0.1;             // Precision for cylinder rounding
    fit_tolerance = 0.1;         // Offset to help avoid tight fit issues

    // === VARIABLES ===
    // Adjust stud size by user-defined scale
    stud_diameter_rescaled = stud_diameter * stud_rescale;
    stud_radius = stud_diameter_rescaled / 2;
    tube_diameter_rescaled = tube_diameter*tube_rescale;
    tube_radius = tube_diameter_rescaled / 2;

    // Don't want to overwrite a literal
    // If "plate" type, override the height
    fixed_height = (type == "plate") ? 1/3 : height;
    
    // Normalize dimensions so length is always the longer side
    adjusted_length = max(width, length);
    adjusted_width = min(width, length);
    adjusted_height = max(1/3, fixed_height); // Make sure height is never less than 1/3

    scaled_block_height = adjusted_height * block_height;
                      
    // Calculate total physical size of the stud area (to center them)
    total_studs_length = (stud_diameter_rescaled * adjusted_length)
                       + ((adjusted_length - 1) 
                       * (stud_spacing - (stud_diameter_rescaled)));
                       
    total_studs_width = (stud_diameter_rescaled * adjusted_width) 
                      + ((adjusted_width - 1) 
                      * (stud_spacing - (stud_diameter_rescaled)));

    total_tubes_length = (tube_diameter_rescaled * (adjusted_length - 1))
                       + ((adjusted_length - 2) 
                       * (stud_spacing - tube_diameter_rescaled));

    total_tubes_width = (tube_diameter_rescaled * (adjusted_width - 1)) 
                      + ((adjusted_width - 2) 
                      * (stud_spacing - tube_diameter_rescaled));

    // Pins used when block is 1 stud wide/long
    total_pins_length = (pin_diameter * (adjusted_length - 1)) 
                      + max(0, ((adjusted_length - 2) 
                      * (stud_spacing - pin_diameter)));

    total_pins_width = (pin_diameter * (adjusted_width - 1)) 
                     + max(0, ((adjusted_width - 2) 
                     * (stud_spacing - pin_diameter)));

    // Total physical block dimensions
    overall_length = (adjusted_length * stud_spacing) - (2 * fit_tolerance);
    overall_width = (adjusted_width * stud_spacing) - (2 * fit_tolerance);
    
    // === MAIN BLOCK STRUCTURE ===
    translate([-overall_length/2, -overall_width/2, 0])
        union() {
            difference() {
                union() {                    
                    // Outer block shell
                    difference() {
                        // Solid cuboid for block body
                        cube([
                            overall_length, 
                            overall_width, 
                            scaled_block_height
                        ]);
                        // Hollow center.
                        translate([wall_thickness, wall_thickness, -roof_thickness]) 
                            cube([
                                overall_length - wall_thickness * 2,
                                overall_width - wall_thickness * 2,
                                scaled_block_height
                            ]);
                    }

                    // === STUDS ===    
                    // The studs on top of the block IF IT IS NOT A "tile" block
                    if ( type != "tile") {
                        // Position and loop to place studs on top
                        translate([stud_radius, stud_radius, 0]) 
                            translate([(overall_length - total_studs_length) / 2, (overall_width - total_studs_width) / 2, 0]) {
                                for (ycount=[0:adjusted_width-1]) {
                                    for (xcount = [0 : adjusted_length - 1]) {
                                        translate([xcount * stud_spacing, ycount * stud_spacing, scaled_block_height]) 
                                            stud();
                                    }
                                }
                            }
                    }

                    // === TUBES (if block is 2x2 or larger) ===
                    if (adjusted_width > 1 && adjusted_length > 1
                                           && roof_thickness < block_height * fixed_height) {
                        translate([tube_radius, tube_radius, 0]) {
                            translate([(overall_length - total_tubes_length)/2, (overall_width - total_tubes_width)/2, 0]) {
                                union() {
                                    // tubes
                                    if(tubes) {
                                        for (ycount=[1 : adjusted_width - 1]) {
                                            for (xcount = [1 : adjusted_length - 1]) {
                                                translate([(xcount - 1) * stud_spacing, (ycount - 1) * stud_spacing, 0]) 
                                                    tube();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // === PINS (used when brick is a single row/column) ===
                    if ((adjusted_width == 1 || adjusted_length == 1) 
                                        && adjusted_width != adjusted_length 
                                        && roof_thickness < block_height * fixed_height) {
                        // Pins
                        if (adjusted_width == 1) {
                            // Single row - add pin support length side
                            translate([pin_radius + (overall_length - total_pins_length) / 2, overall_width/2, 0]) {
                                for (xcount = [1 : adjusted_length - 1]) {
                                    translate([(xcount - 1) * stud_spacing, 0, 0]) 
                                        cylinder(
                                            r = pin_radius,
                                            h = scaled_block_height,
                                            $fs = precision
                                        );
                                }
                            }
                        }
                        else {
                            // Single column - add pin support width side
                            translate([overall_length / 2, pin_radius + (overall_width - total_pins_width) / 2, 0]) {
                                for (ycount = [1 : adjusted_width - 1]) {
                                    translate([0, (ycount - 1) * stud_spacing, 0]) 
                                        cylinder(
                                            r = pin_radius,
                                            h = scaled_block_height,
                                            $fs = precision
                                        );
                                }
                            }
                        }
                    }
                }
                
            }
        
    }

    // === STUD MODULE ===
    // Generates a stud, used to connect pieces together
    module stud() {
        stud_body_height = stud_height;
        cylinder(
            r = stud_radius, 
            h = stud_body_height, 
            $fs = precision
        );  

    }

    // === TUBE MODULE ===
    // Generates a hollow tube, used for strength
    module tube() {
        difference() {
            // Outer cylinder
            cylinder(
                r = tube_radius, 
                h = scaled_block_height,
                $fs = precision
            );
            // Inner hollow
            translate([0,0,-0.5]) 
                cylinder(
                    r = tube_radius - tube_wall_thickness, 
                    h = scaled_block_height + 1,
                    $fs = precision
                );
        }
    }
}