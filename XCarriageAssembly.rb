require_relative 'fasteners'
require_relative 'sprockets'

require_relative 'DualBearingVWheelKit'
require_relative 'inventables/IdlerWheelKit'
require_relative 'MakerSlide'
require_relative 'MotorAndPulleyAssembly'
require_relative 'YCarriageAssembly'
require_relative 'VWheelAssembly'

extrusion :IdlerSprocketBracket do
    attr_reader mounting_hole: Point[-10.mm.cm, 12.mm.cm]
    attr_reader thickness:ACRYLIC_THICKNESS

    length thickness
    rectangle center:[0,0.5.cm], size:[4.cm, 3.cm]

    # Mounting hole
    circle center:mounting_hole, diameter:5.1.mm.cm

    # Bolt hole
    circle center:[0,0], diameter:5.1.mm
end

model :YRailAssembly do
    translate 1.5.cm - RAIL_LENGTH_Y/2, YCarriageAssembly.rail_offset, 0 do
        push MakerSlide, length:RAIL_LENGTH_Y, origin:[0, 0, 0], x:Y, y:Z
        translate [-NEMA17.body_width/2, 0, 0] do
            push YMotorAndSprocketAssembly, origin:[0, 0, 1.16.cm-YMotorAndSprocketAssembly.motor_body_length]
        end

        translate [RAIL_LENGTH_Y + 0.5.cm, 0, 1.cm] do
            push IdlerSprocketBracket, x:Y, y:-X
            translate z:IdlerSprocketBracket.thickness do
                # Mounting bolt
                translate x:-IdlerSprocketBracket.mounting_hole.y, y:IdlerSprocketBracket.mounting_hole.x do
                    push FlatWasher
                    push M5x12Bolt, origin:[0, 0, FlatWasher.length], x:X, y:-Y
                end

                # Idler sprocket assembly
                push FlatWasher
                translate z:FlatWasher.length do
                    push Sprocket_GT2_20_5mm
                    translate z:Sprocket_GT2_20_5mm.length do
                        push FlatWasher
                        push M5x30Bolt, origin:[0, 0, FlatWasher.length], x:X, y:-Y
                    end
                end
            end
            translate z:-FlatWasher.length do
                push FlatWasher
                push M5HexNut, origin:[0, 0, -M5HexNut.length]
            end
        end
    end

    push YCarriageAssembly, origin:[0, 0, 2.cm/2 + PrecisionShim.length + 0.75.cm/2 + 1.8.mm.cm]
end

extrusion :XCarriagePanel do
    attr_reader thickness: ACRYLIC_THICKNESS
    attr_reader belt_anchor_holes: repeat(center:[-2.cm, X_RAIL_BACK_Y+3.cm], step:[2.cm, 0], count:[2,1])
    attr_reader height: 6.5.cm
    attr_reader width: 9.cm
    attr_reader panel_origin: Point[-7.cm, 0]
    attr_reader wheel_offset: -1.cm
    attr_reader wheel_spacing: 10.cm
    attr_reader wheel_centers: repeat(center:[wheel_offset, (X_RAIL_BACK_Y+X_RAIL_FRONT_Y)/2],
                                      step:[wheel_spacing, X_RAIL_SPACING - MakerSlide.wheel_spacing],
                                      count:2)

    attr_reader wheel_hole_diameters: [5.mm, 5.mm, 7.mm, 7.mm]

    attr_reader bracket_center: Point[-1.6872.cm, 0]
    attr_reader bracket_holes: repeat(center:bracket_center, step:[6.75.mm.cm, 4.cm], count:[2,3])

    attr_reader y_motor_center: Point[1.cm, 10.615.cm]
    attr_reader y_motor_bolt_holes: repeat(center:y_motor_center, step:31.mm.cm, count:[2,2])

    length thickness

    polygon origin:panel_origin do
        up          height + 8.cm
        right_to    width + 3.cm
        down        height + 2.cm
        left        2.cm
        down        12.cm

        right       2.cm
        down        2.5.cm
        left        9.cm
        left        3.cm
        up          2.5.cm
    end

    # Orientation marker
    translate -4.cm, 9.cm do
        circle diameter:5.mm
        rectangle origin:[1.cm, 0], size:[1.cm, 1.mm]
        rectangle origin:[0, 1.cm], size:[1.mm, 1.cm]
    end

    # Stress-relief slot between the axis of the rear wheels and the mounts for the powder blade
    rectangle from:[-4.cm, -6.5.cm], to:[-5.cm, 6.5.cm]

    # Y-rail mounting holes
    repeat center:[1.cm, 0], step:[2.cm, 4.cm], count:[2, 4] do
        circle diameter:5.mm.cm
    end

    # Wheel bearing holes
    wheel_centers.zip(wheel_hole_diameters).each do |center, diameter|
        circle center:center, diameter:diameter
    end

    # Y-motor mounting holes
    y_motor_bolt_holes.each {|center| circle center:center, diameter:3.mm }

    # Angle block mounting holes
    bracket_holes.each do |center|
        circle center:center, diameter:2.mm.cm
    end

    # Mounting block tab holes
    translate bracket_center do
        repeat center:[-0.0375.cm, 0], step:[2.75.cm, 4.cm], count:[2,3] do
            rectangle center:[0,0], size:[1.cm, ACRYLIC_THICKNESS]
        end
    end

    # Belt anchor holes
    belt_anchor_holes.each {|center| circle center:center, diameter:5.mm }
end

POWDER_BLADE_ANGLE = 30.degrees.radians  # Measured from vertical
POWDER_BLADE_VERTICAL = 26.55.mm.cm
POWDER_BLADE_LENGTH = POWDER_BLADE_VERTICAL / Math.cos(POWDER_BLADE_ANGLE)

WIPER_SIZE = Size[BUILD_VOLUME.y, POWDER_BLADE_LENGTH]
extrusion :PowderBlade do
    attr_reader height: WIPER_SIZE.y
    attr_reader width: WIPER_SIZE.x
    attr_reader holes: repeat(center:[0, 1.225.mm.cm], step:[4.cm, 8.6603.mm.cm], count:[3,2])
    attr_reader thickness: ACRYLIC_THICKNESS

    length thickness

    rectangle center:[0,0], size:WIPER_SIZE

    # Mounting block atachment holes
    holes.each {|center| circle center:center, diameter:2.mm }

    # Slots for the mounting block tabs
    slot_length = 0.5.cm + 0.8.mm.cm
    repeat center:[0, WIPER_SIZE.y/2 - slot_length/2], step:[4.cm,0], count:3 do
        rectangle center:[0,0], size:[ACRYLIC_THICKNESS, slot_length]
    end
end

extrusion :PowderBladeAnglePanel do
    attr_reader thickness: ACRYLIC_THICKNESS
    length thickness

    attr_reader blade_angle: POWDER_BLADE_ANGLE
    attr_reader bolt_spacing: 8.mm
    attr_reader height: 2.cm
    attr_reader tab_height: 0.6.cm
    attr_reader tab_length: 1.cm
    attr_reader width: 3.75.cm

    attr_reader mounting_panel_thickness: ACRYLIC_THICKNESS
    attr_reader bolt_length: 10.mm

    attr_reader nut_depth: 3.mm

    HexNut = M2ThinHexNut

    polygon do
        # The top half of the tab
        up          0.5.cm
        right       0.5.cm

        repeat to:[last.x + (height - last.y)*Math.tan(blade_angle), height], count:2 do |step|
            forward 3.mm.cm

            right   3.mm.cm
            forward -(HexNut.width - 2.mm)/2
            right   HexNut.length
            forward HexNut.width
            left    HexNut.length
            forward -(HexNut.width - 2.mm)/2
            left    3.mm.cm
        end

        chamber_side = 1.25.cm
        right       width - last.x - chamber_side
        move        chamber_side, -chamber_side
        down_to     0
        down        tab_height
        left        tab_length
        up          tab_height
        left        0.4.cm

        repeat to:[tab_length,0], count:2 do |step|
            right       nut_depth
            forward     -(HexNut.width - 2.mm)/2
            right       HexNut.length
            forward     HexNut.width
            left        HexNut.length
            forward     -(HexNut.width - 2.mm)/2
            left        nut_depth
        end

        down        tab_height
        left        tab_length
        up          tab_height
    end
end

model :PowderBladeAssembly do
    attr_reader mounting_block_spacing: 8.cm

    translate -0.21132.cm, -PowderBladeAnglePanel.thickness/2, 0 do
        push PowderBladeAnglePanel, origin:[0, -mounting_block_spacing/2, 0], x:X, y:-Z
        push PowderBladeAnglePanel, x:X, y:-Z
        push PowderBladeAnglePanel, origin:[0, mounting_block_spacing/2, 0], x:X, y:-Z
    end

    group x:[Math.cos(PowderBladeAnglePanel.blade_angle), 0, Math.sin(PowderBladeAnglePanel.blade_angle)], y:Y do
        group x:Y, y:Z do
            translate [0, -PowderBlade.height/2, -PowderBlade.length] do
                push PowderBlade

                PowderBlade.holes.each do |center|
                    push M2x10Bolt, origin:Point[*center, 0]
                    push M2ThinHexNut, origin:[*center, PowderBlade.thickness + 3.mm]
                end
            end
        end
    end
end

model :XCarriageAssembly do
    push YRailAssembly, origin: [0, 0, XCarriagePanel.thickness + 10.mm], x:-Y, y:X

    translate YCarriageAssembly.rail_offset, 0, 0 do
        translate -1.cm, 0, 0 do
            push XCarriagePanel

            XCarriagePanel.belt_anchor_holes.each do |center|
                translate x:center.x, y:center.y do
                    translate z:XCarriagePanel.thickness do
                        push FlatWasher
                        push M5HexNut, origin:[0,0,FlatWasher.length]
                    end
                    translate z:-FlatWasher.length do
                        push FlatWasher
                        push M5x20Bolt
                    end
                end
            end

            XCarriagePanel.wheel_centers.each do |x, y|
                push VWheelAssembly, origin:[x,y,0]
            end

            XCarriagePanel.bracket_holes.each do |center|
                push M2x10Bolt, origin:[*center, XCarriagePanel.thickness], x:X, y:-Y
                push M2ThinHexNut, origin:[*center, -3.mm - M2ThinHexNut.length]
            end
        end

        push PowderBladeAssembly, origin:[-4.38838.cm, 0, XCarriagePanel.thickness - 6.mm]
    end
end
