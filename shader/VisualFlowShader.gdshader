/*
ORIGINAL SHADER : https://www.shadertoy.com/view/dssyzf
// The MIT License
// Copyright © 2023 Gehtsiegarnixan
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

MODIFIED BY KeyboardMoss for godot
Input texture contains pixels from 0.0 to 1.0.  'flowTex' may be used to modify this.
R : Vertical 0.0 (down), 1.0 (up).
G : Horizontal 0.0 (left), 1.0 (right).
B : Amplitude 0.0 (invisible), 1.0 (longest).

During testing found RGBA8 caused noticeable precision loss (5deg+/-). 
*/
shader_type spatial;
render_mode unshaded;
uniform sampler2D albedo_texture : source_color,filter_nearest,repeat_disable;

uniform vec2 debug_uv_offset = vec2(0,0);
uniform float blur_amount: hint_range(0.0, 1024.0) = 250.0;
uniform float line_thickness: hint_range(0.0, 0.1) = 0.05;
uniform float min_arrow_length: hint_range(0.0, 0.5) = 0.05;
uniform float max_arrow_length: hint_range(0.5, 1.0) = 0.9;
uniform bool render_background = false;

// Rotate coordinates in vector direction
vec2 rotateUV(vec2 uv, vec2 direction) {
    // Calculate the rotation matrix
    mat2 rotationMatrix = mat2( vec2(direction.y, direction.x),
                                vec2(-direction.x, direction.y) );
    // Rotate the UV coordinates
    return rotationMatrix * uv;
}

#define SMALLESTFLOAT (1.0 / float(0xffffffffU))

// Generates a grid of arrows that point in the direction
float quiverPlot(vec2 uv, vec2 direction, float gridSize, float amplitude) {
    float tipSteepness = 1.5;      // Controls the angle of the arrow tip

    // Calculate the square of the length of the vector
	float lenSq = dot(direction, direction);

    // Check if the squared length is greater than a tiny threshold
    if (lenSq > SMALLESTFLOAT && amplitude > 0.05) {

        // break UV coordinates into grid sections
        uv = fract(uv * gridSize) - 0.5 ;

        // caculate the direction vector length
        float vectorLen = sqrt(lenSq);

        // Scale uv by vector size
        float size = mix(min_arrow_length, max_arrow_length, clamp(amplitude, 0.,1.));
        uv /= size;

        // Rotate UV coordinates based on the normalized direction vector
        uv = rotateUV(uv, direction / vectorLen);

        // absolute position
        float absV = abs(uv.x);

        // Calculate center line of the arrow shape
        float lineOffset = tipSteepness * line_thickness; // offset so lines doesn't go over the tip
        float line = max(absV, abs(uv.y + lineOffset) - 0.5 + lineOffset);

        // Caculation of the Arror Tip
        float tip = max(abs((uv.y / tipSteepness) + absV - (0.5 / tipSteepness) + line_thickness), -uv.y + 0.1);

        // Combine line and tip to create the arrow shape
        float arrowDist = min(tip, line) - line_thickness;

		ivec2 texsize = textureSize(albedo_texture,0);
        float blur = (gridSize * 1.0)/(size * blur_amount);

        return smoothstep(blur, -blur, arrowDist) ; // cheap AA

    } else {
        // if the direction length is 0. then no arrows
        return 0.0;
    }
}

// loads noise texture and turns it into flowmap
vec2 flowTex(vec2 uv, vec3 tex) {
    float mask = clamp(2.2-pow(length(uv),2.0), 0, 1.0);
    return (tex.xy-.5)*2. * mask; // constant bias scale for -1 to 1 range
}

void fragment() {
	ivec2 size = textureSize(albedo_texture,0);
	vec4 tex = texture(albedo_texture,UV);

	vec2 flowMap = flowTex(UV, tex.xyz);

    // number of subdivisions for the sampling of the flowmap
    float gridSize = float(size.x);
    float arrows = quiverPlot(UV, flowMap, gridSize, tex.z);

    // Shift flowmap into visible range
    vec4 viewFlowMap = vec4(flowMap.xy*0.5+0.5,0.5,1.0);

	vec4 finalColor = tex - arrows*vec4(1,1,1,0);
	finalColor.w = arrows;
	if (render_background){
		finalColor.w = 1.0;
	}

	ALBEDO = finalColor.xyz;
	ALPHA = finalColor.w;
}

