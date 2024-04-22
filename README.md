# Godot Flow Map Shader
Handy shader for visualizing vector fields and flow maps. 

This is intended more for debug purposes.

> [!NOTE]
> ORIGINAL SHADER by Gehtsiegarnixan https://www.shadertoy.com/view/dssyzf
> 
> MODIFIED by KeyboardMoss for Godot 4

# Usage Details
Shader input is a regular texture which is updated at regular intervals as needed.
- Each pixel represents a single vector and is scaled to match the plane surface.
- Red and Green channels store normalized vector directions, centered at <0.5,0.5> and ranging from 0.0 to 1.0
- Blue channel stores amplitude 0.0 to 1.0
- RGBA8 is sufficient but suffers from some precision silliness(+/-5deg).  Use [higher channel precision](https://docs.godotengine.org/en/stable/classes/class_image.html#enumerations) if exact directions are needed.
- Includes toggle to render only arrows.

# Demo
Project contains a simple vector field to shader flow.  

![Arrows pointing at an orbiting moon](./animation.gif)
