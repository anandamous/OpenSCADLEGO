## **CS 453 Robotics & 3D Printing**

# **Custom LEGO® Bricks via OpenSCAD**

## **By Anand Egan**

## **May 1, 2025**

**NOTE:** LEGO® is a trademark of the LEGO Group, which does not sponsor, authorize, or endorse this project. This project is purely educational.

## **Introduction**

I’ve always enjoyed how versatile LEGO® bricks are, and how satisfying it is to snap together tiny yet amazingly engineered bricks. Additionally, I’ve found OpenSCAD’s ability to parameterize 3D models to be a powerful tool, making design development much easier. For my CS 453 Robotics & 3D Printing final project, I set out to combine OpenSCAD’s parameter ability with the classic interlocking LEGO® brick to create an OpenSCAD project that allows users to create their own LEGO® bricks via parameters. My goals for the project were:

- **Fully parametric design:** Allow users to specify parameters for the blocks, such as block type (brick, tile, and plate), length, width, and height.

- **Accurate proportions**: Match dimensions from official LEGO® bricks

- **3D-printability:** Factor in wall thickness, clearance tolerances, and stud rescaling for PLA printing.

Below, I share the design approach, code structure, print testing on a QIDI Q1 Pro, and lessons learned.

## **Design Rationale**

### **Block Types**

- **Brick:** Standard brick height (9.6 mm) with studs on top.

- **Tile:** Smooth top block (no studs), ideal for finishing surfaces.

- **Plate:** One-third brick height (3.2 mm) with studs on top, matching LEGO® plate height.

### **Key Parameters**

- **Length & width (studs):** Integer counts (ex: 2x4, 1x5, etc.).

- **Height:** By default 1 brick height (9.6 mm), or 1/3 for plates. Users can create their own “cursed” parameters if they so choose, like a 5x height scale.

- **Stud rescaling:** An optional scale factor that can compensate for the nature of different materials to prevent bricks from not fitting, such as PLA shrinkage (which can be resolved via 1.05 stud rescaling from my testing)

- **Interior reinforcement:** Option to include hollow tubes (for ≥2x2 blocks) or pins (for single‑row/column bricks).

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdIk3O4_sD25iwlWUzEFskw4V6ShPlVsljK1-bRFBslI8PrfoSKu1cH9_9viVsF6l6grc1QOumjqgMo7--K_1EgBtZm8uATA_VaDwIIdfkwWdYYxCatUW_DaVbe6HKBZydaVjuu-g?key=8ow8Sl_SKdfE-ERETZjIOWHj)

[From Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Lego_dimensions.svg)

### **Technical Highlights**

Official LEGO® dimensions are encoded as constants in the script:

|                     |           |                                                                                |
| :-----------------: | :-------: | :----------------------------------------------------------------------------: |
|    **Component**    | **Value** |                                    **Notes**                                   |
|     Block Height    |   9.6 mm  |         Standard LEGO® brick height; plates are 1/3 of this (\~3.2 mm)         |
|    Wall Thickness   |  1.45 mm  | Matches LEGO® standards and ensures print strength without overuse of material |
|    Roof Thickness   |    1 mm   |                       Thickness of the brick’s top shell                       |
|    Stud Diameter    |  4.85 mm  |         Slightly increased from the official 4.8 mm to improve PLA fit         |
|     Stud Height     |   1.8 mm  |                Matches LEGO® specs for proper stacking behavior                |
|     Stud Spacing    |    8 mm   |                     Center to center distance between studs                    |
|    Tube Diameter    |   6.5 mm  |                    Diameter of support tubes under the brick                   |
| Tube Wall Thickness |  0.85 mm  |                       Thickness of the support tube walls                      |
|     Pin Diameter    |    3 mm   |    Used for 1xN or Nx1 bricks to add strength when full tubes aren’t viable    |
|      Precision      |   0.1 mm  |                  Controls smoothness of cylinders in OpenSCAD                  |
|    Fit Tolerance    |   0.1 mm  |     Subtracted from final dimensions to prevent overly tight fits in prints    |

## **Implementation Overview**

The `CUSTOM_LEGO.scad` script is organized into three main phases: setup, geometry construction, and feature modules.

1\. **Parameter and Constant Definitions**

- Declares LEGO® standard constants (\`block\_height\`, \`wall\_thickness\`, \`roof\_thickness\`, stud specs, tube specs, pin specs) alongside user parameters (\`type\`, \`length\`, \`width\`, \`height\`, \`tubes\`, \`stud\_rescale\`)

2\. **Derived Dimension Calculations**

- Computes \`stud\_radius\` and \`tube\_radius\` after applying \`stud\_rescale\`.

- Overrides \`fixed\_height\` for plates (\`type == "plate"\`).

- Normalizes dimensions so that \`adjusted\_length\` ≥ \`adjusted\_width\` and enforces \`adjusted\_height\` ≥ 1/3.

- Calculates \`scaled\_block\_height = adjusted\_height \* block\_height\`.

- Computes layout extents (\`total\_studs\_length\`, \`total\_tubes\_length\`, \`total\_pins\_length\`, etc.) for positioning loops.

- Determines \`overall\_length\` and \`overall\_width\`, subtracting \`2 \* fit\_tolerance\` to prevent overly tight fits.

3\. **Geometry Construction**

- Applies a \`translate()\` to center the block at the origin.

- **Outer Shell:** Uses a \`difference()\` to subtract an inner cuboid (offset by \`wall\_thickness\` and negative \`roof\_thickness\`) from a solid cube of size (\`overall\_length\`, \`overall\_width\`, \`scaled\_block\_height\`).

- **Studs:** If \`type != "tile"\`, nested for loops iterate over \`adjusted\_length\` and \`adjusted\_width\`, translating to each stud center and invoking the \`stud()\` module.

- **Tubes:** When \`adjusted\_length > 1 && adjusted\_width > 1\`, nested loops place hollow support tubes via the \`tube()\` module.

- **Pins:** For single row or single column bricks (\`adjusted\_length == 1\` or \`adjusted\_width == 1\`), linear loops add full-height solid cylinders as pin supports.

4\. **Feature Modules**

- \`stud()\`: Generates a cylinder of radius \`stud\_radius\` and height \`stud\_height\`

- \`tube()\`: Produces a hollow cylinder by subtracting an inner cylinder (radius \`tube\_radius - tube\_wall\_thickness\`) from an outer cylinder (radius \`tube\_radius\`).


## **Testing - Printing on the QIDI Q1 Pro with PLA**

### **Tuning for Fit**

- I observed loose stud-tube clearances upon the first print. After much trial and error, changing \`fit\_tolerance\` to 0.1 mm and setting \`stud\_rescale = 1.05\` allowed studs to click in smoothly without sacrificing clutch power.

- Wall thickness and tube wall thickness remained at LEGO-standard values (1.45 mm exterior, 0.85 mm tube walls), which printed decently well on the QIDI Q1 Pro. Unfortunately, I was not able to figure out how to allow users to fit studs into the interior tubes like one would a normal LEGO® brick.


## **Examples:**

**2x2 Brick Invocation:**

|                                                                                                                  |
| ---------------------------------------------------------------------------------------------------------------- |
| block(    type = "brick",    length = 2,    width = 2,    height = 1,    tubes = true,    stud\_rescale = 1.05); |

**2x2 Brick Preview:**

****![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXfVW0eiNtQVTyh0l9-fzEe8bcFGKoIObvorMEhcX1gjidrfc7oAmW9wDfahP24EOmXNKMGAwSnhQseapT5z6VmcAQ-kq9ZgfnIMTu_dIFROqfJQzSGF8Nlc7Yp5ChdDClZwkDLoYw?key=8ow8Sl_SKdfE-ERETZjIOWHj)****

**1x5 Plate Invocation:**

|                                                                                                                  |
| ---------------------------------------------------------------------------------------------------------------- |
| block(    type = "plate",    length = 1,    width = 5,    height = 1,    tubes = true,    stud\_rescale = 1.05); |

**1x5 Plate Preview:**

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdk992Ms1BNgzh0cObDa_P2NEwSxLXkVmPc2ZLBvZOsJnSd72IWIKwaJZzrKl4QztJD2ewrTjeec9StDBwljzi2rv6SytqFhMxc7_PXrNlhL3kFIEFbSNjHiUzOKG_ynEPB_G0VEg?key=8ow8Sl_SKdfE-ERETZjIOWHj)

**3x1 Tile Invocation:**

|                                                                                                                  |
| ---------------------------------------------------------------------------------------------------------------- |
| block(    type = "plate",    length = 1,    width = 5,    height = 1,    tubes = true,    stud\_rescale = 1.05); |

**3x1 Tile Preview:**

![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXdsjZ9NjHIjxpkWP_hhU52R7NmhDpYlRxrOxSV2BwviSA16kZxgkABf3DGmd_PeEjxieBHpuBrb0zrNEVLzAaYynUrF1KH4EpP5trAQrIV0bz7mH5mvEDVWfm9LNFrGZiE3aaAbMw?key=8ow8Sl_SKdfE-ERETZjIOWHj)

**Printed (PLA) vs Offical LEGO**®:

****![](https://lh7-rt.googleusercontent.com/docsz/AD_4nXf7RahdjtEsAB5HB3YLtANnWyBETZ6Q1hroNrZR2SkdwNGGQYwGIaOFbTnn-Gov5UnhhaNVw09U4mMrokuUoNiLwuHVwq5RWxKbFpY1ttmlA82_F0thuBgph3qoZGnDTIb2PmMCxQ?key=8ow8Sl_SKdfE-ERETZjIOWHj)****


## **Lessons Learned**

Through design and testing, several lessons were learned:

**Dimensional Tuning:**

- Adjusting fit\_tolerance in 0.05 mm increments showed me that clearance between studs and tubes directly influences how tightly they snap together.

- A final tolerance of 0.1 mm balanced ease of assembly with secure fit, lower values or none led to too tight connections, higher values produced loose connections.

**Material Behavior:**

- PLA’s slight shrinkage and layer adhesion variability required stud\_rescale trials from 1.00 to 1.1; 1.05 delivered reliable results.

**Structural Trade‑offs:**

- Hollow tubes significantly increase vertical strength but will obstruct stud inserts.

**Print Orientation & Slicer Settings:**

- Orienting bricks flat with studs upward minimized bridging and improved tube roundness.

**Parametric Workflow Benefits:**

- Modularizing stud() and tube() allowed easy feature toggling and code reuse.

- Explicit variable naming such as scaled\_block\_height or total\_studs\_length improved readability during debugging.


## **Future Work**

Some features were planned but were not completed due to the lack of time from other classes:

- Implement slope modules (such as 45° or curved wedges) with correct stud alignment.

- Add round and Technic elements (axle holes, pin connectors) using parameterized boolean operations.


## **Credits/Acknowledgements**

[bartneck.de/2019/04/21/lego-brick-dimensions-and-measurements/](http://bartneck.de/2019/04/21/lego-brick-dimensions-and-measurements/)

<https://commons.wikimedia.org/wiki/File:Lego_dimensions.svg>
