TS-600 t-slot vector rail eurorack hole drilling template/

Based on the datasheet here https://www.farnell.com/datasheets/1928824.pdf

Files in this directory:

1. `flat-ts600-template.dxf/.svg` - laser cut or 2d print this on any printer
2. `3d-ts600-template.stl` - 3d print this for a more durable repeated-use template
3. `eurorack-ts-600.scad` - can be customized to change the 3d heights of the template.
4. `rail-ts-600.dxf/.svg` - single drawing of a ts600 rail profile, if you just need that
5. `flat-ts600-only-holes-and-profiles.dxf/.svg` - two properly spaced ts600 profile outlines, with mounting drill-holes. Use this if you're directly laser cutting the holes. 


All top-level modules in the openscad file:

- `flat_template();` - 2d template for laser cutter / 2d printer
- `drill_template();` - 3d template for 3d printing
- `flat_template_with_only_rail_profiles();` - 2d template without the position holder, and including rail profiles. Use this for laser cutting the holes.
- `ts600()` - a single rail profile
- `mounting_holes(show_right=true, show_left=true)` - make circles that indicate where the mounting holes should be drilled relative to the ts600 profile
- `rounded_rectangle(x,y,roundness);` - make a 2d rounded rect, forkd from https://www.thingiverse.com/thing:213733

