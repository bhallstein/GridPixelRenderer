#version 140

in vec2 inVPos;
in vec2 inTexCoord;

out vec2 outTexCoord;

void main(void) {
	gl_Position = vec4(inVPos, 1.0, 1.0);
	outTexCoord = inTexCoord;
}
