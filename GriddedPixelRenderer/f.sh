#version 140

uniform sampler2D uTex;

in vec2 outTexCoord;

out vec4 fragOutColour;

void main(void) {
	fragOutColour = texture(uTex, outTexCoord.st, 0.0);
}
