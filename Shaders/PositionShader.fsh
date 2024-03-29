varying mediump vec2 textureCoordinate;
precision mediump float;

uniform sampler2D videoFrame;
uniform vec4 inputColor;
uniform float threshold;
uniform float myFloater;


vec3 normalizeColor(vec3 color)
{
    return color / max(dot(color, vec3(1.0/3.0)), 0.3);
}

vec4 maskPixel(vec4 pixelColor, vec4 maskColor)
{
    float  d;
	vec4   calculatedColor;

    // Compute distance between current pixel color and reference color
    d = distance(normalizeColor(pixelColor.rgb), normalizeColor(maskColor.rgb));
    
    // If color difference is larger than threshold, return black.
    calculatedColor =  (d > threshold)  ?  vec4(0.0)  :  vec4(1.0);

	//Multiply color by texture
	return calculatedColor;
}

vec4 coordinateMask(vec4 maskColor, vec2 coordinate)
{
    // Return this vector weighted by the mask value
    return maskColor * vec4(coordinate, vec2(1.0));
}

void main()
{
	float d;
	vec4 pixelColor, maskedColor, coordinateColor;

	pixelColor = texture2D(videoFrame, textureCoordinate);
	maskedColor = maskPixel(pixelColor, inputColor);
	coordinateColor = coordinateMask(maskedColor, textureCoordinate);

	gl_FragColor = coordinateColor;
}
