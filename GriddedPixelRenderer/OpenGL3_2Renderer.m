//
//  OpenGL3_2Renderer.m
//  OpenGL3.2-Mac
//
//  Created by Ben on 13/09/2013.
//  Copyright (c) 2013 Ben. All rights reserved.
//

#import "OpenGL3_2Renderer.h"
#import <OpenGL/gl3.h>
#import "ShaderStr.h"


enum {
	INDEX_OF_VERT_POSITION_ATTRIB,
	INDEX_OF_TEXCOORD_ATTRIB
};


@interface OpenGL3_2Renderer () {
	
	int w, h;
	Colour *texData;
	
	GLuint vaoName;
	GLuint programName;
	
	// VBO names
	GLuint vertexPosBufName;
	GLuint texcoordBufName;
	
	// Uniform names
	GLint colourUniformLoc;
	GLint samplerUniformLoc;
	
	NSSize backingSize;
	
	GLuint texName;
	
	int i;
}


@end


@implementation OpenGL3_2Renderer

-(id) initWithWidth:(int)width height:(int)height {
	NSLog(@"Init renderer...");
	
	if ((self = [super init])) {
		w = width, h = height;
		if (![self initOGL])
			return nil;
	}
	
	return self;
}
-(id) init {
	return [self initWithWidth:320 height:240];
}

-(Colour*) texDataPointer {
	return texData;
}


// Initialize OpenGL gubbins

-(bool) initOGL {
	
	// 1. Create a VAO to hold state
	
	glGenVertexArrays(1, &vaoName);
	glBindVertexArray(vaoName);
	

	// 2. Create VBOs for vertices and texcoord data

	// Vertices
	GLfloat vertices[] = {
		-1.0, -1.0,		// bottom left
		 1.0,  1.0,		// top right
		-1.0,  1.0,		// top left
		-1.0, -1.0,		// bottom left
		 1.0, -1.0,		// bottom right
		 1.0,  1.0		// top right
	};

	glGenBuffers(1, &vertexPosBufName);
	glBindBuffer(GL_ARRAY_BUFFER, vertexPosBufName);
	glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 12, vertices, GL_STATIC_DRAW);
	
	glEnableVertexAttribArray(INDEX_OF_VERT_POSITION_ATTRIB);
	glVertexAttribPointer(INDEX_OF_VERT_POSITION_ATTRIB,		// index
						  2,									// size (components per vertex)
						  GL_FLOAT,							// type
						  false,								// normalized
						  0,									// stride
						  0);								// offset/pointer
	
	// Texcoords
	GLfloat texcoords[] = {
		0.0, 1.0,		// bind each corner of tex to the corresponding corner
		1.0, 0.0,		// of rect
		0.0, 0.0,
		0.0, 1.0,
		1.0, 1.0,
		1.0, 0.0
	};
	
	glGenBuffers(1, &texcoordBufName);
	glBindBuffer(GL_ARRAY_BUFFER, texcoordBufName);
	glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 12, texcoords, GL_STATIC_DRAW);
	
	glEnableVertexAttribArray(INDEX_OF_TEXCOORD_ATTRIB);
	glVertexAttribPointer(INDEX_OF_TEXCOORD_ATTRIB,
						  2,
						  GL_FLOAT,
						  false,
						  0,
						  0);
	
	
	// 3. Create texture & upload initial
	
	texData = (Colour*) malloc(sizeof(Colour) * w * h);
	for (int n=0; n < w*h; ++n)
		texData[n] = (Colour) { 0.0, 0.0, 0.0, 1.0 };
	
	glGenTextures(1, &texName);
	glBindTexture(GL_TEXTURE_2D, texName);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	
	glTexImage2D(
				 GL_TEXTURE_2D,
				 0,
				 GL_RGBA,
				 w, h, 0, GL_RGBA, GL_FLOAT, texData
				 );
	
	
	// 4. Initialize shaders
	
	ShaderStr vShStr = loadShaderString("v");
	ShaderStr fShStr = loadShaderString("f");
	
	GLint logLength, compileStatus, linkStatus;
	
	programName = glCreateProgram();
	glBindAttribLocation(programName, INDEX_OF_VERT_POSITION_ATTRIB, "inVPos");
	glBindAttribLocation(programName, INDEX_OF_TEXCOORD_ATTRIB, "inTexCoord");
	
	// Compile and link shaders into program
	{
		// Compile vertex shader
		GLuint vSh = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vSh, 1, (const GLchar **) &vShStr.s, NULL);
		glCompileShader(vSh);
		
		// Check compiled
		glGetShaderiv(vSh, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0) {
			GLchar *log = (GLchar*) malloc(logLength);
			glGetShaderInfoLog(vSh, logLength, &logLength, log);
			NSLog(@"Vertex shader compile log:%s\n", log);
			free(log);
		}
		glGetShaderiv(vSh, GL_COMPILE_STATUS, &compileStatus);
		if (compileStatus == 0) {
			NSLog(@"Failed to compile vertex shader:\n%s\n", vShStr.s);
			return false;
		}
		
		// Compile fragment shader
		GLuint fSh = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fSh, 1, (const GLchar **) &fShStr.s, NULL);
		glCompileShader(fSh);
		
		// Check compiled
		glGetShaderiv(fSh, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0) {
			GLchar *log = (GLchar*) malloc(logLength);
			glGetShaderInfoLog(fSh, logLength, &logLength, log);
			NSLog(@"Fragment shader compile log:%s\n", log);
			free(log);
		}
		glGetShaderiv(fSh, GL_COMPILE_STATUS, &compileStatus);
		if (compileStatus == 0) {
			NSLog(@"Failed to compile fragment shader:\n%s\n", fShStr.s);
			return false;
		}
		
		free(vShStr.s);
		free(fShStr.s);
		
		// Link program
		glAttachShader(programName, vSh);
		glAttachShader(programName, fSh);
		glLinkProgram(programName);
		
		// Check linked OK
		glGetProgramiv(programName, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0) {
			GLchar *log = (GLchar*)malloc(logLength);
			glGetProgramInfoLog(programName, logLength, &logLength, log);
			NSLog(@"Program link log:\n%s\n", log);
			free(log);
		}
		
		glGetProgramiv(programName, GL_LINK_STATUS, &linkStatus);
		if (linkStatus == 0) {
			NSLog(@"Failed to link program");
			return false;
		}
		
		glValidateProgram(programName);
		glGetProgramiv(programName, GL_INFO_LOG_LENGTH, &logLength);
		if (logLength > 0) {
			GLchar *log = (GLchar*)malloc(logLength);
			glGetProgramInfoLog(programName, logLength, &logLength, log);
			NSLog(@"Program validate log:\n%s\n", log);
			free(log);
		}
		
		glGetProgramiv(programName, GL_VALIDATE_STATUS, &linkStatus);
		if (linkStatus== 0) {
			NSLog(@"Failed to validate program");
			return false;
		}
	}
	
	glUseProgram(programName);
	
	// Set the sampler uniform to texture unit 0
	samplerUniformLoc = glGetUniformLocation(programName, "uTex");
	if (samplerUniformLoc == -1) {
		NSLog(@"sampler uniform \"uTex\" not found in shader program");
		return false;
	}
	
	glUniform1i(samplerUniformLoc, 0);
	
	
	// 5. Set non-changing OpenGL state
	
	glClearColor(0.5, 0.0, 0.0, 1.0);
	
	
	return true;
}

-(void) update {
	glBindTexture(GL_TEXTURE_2D, texName);
	glTexImage2D(
				 GL_TEXTURE_2D,
				 0,
				 GL_RGBA,
				 w, h, 0,
				 GL_RGBA,
				 GL_FLOAT,
				 texData
				 );
}


// Rendering

-(void) render {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glViewport(0, 0, backingSize.width, backingSize.height);
	
	glUseProgram(programName);
	glBindVertexArray(vaoName);
	glBindTexture(GL_TEXTURE_2D, texName);
	glDrawArrays(GL_TRIANGLES, 0, 12);
}


-(void) resize:(NSSize)size {
	backingSize = size;
}


// Deallocation

-(void) delVBOs {
	glDeleteBuffers(1, &vertexPosBufName);
}

-(void) delVAO {
	glDeleteVertexArrays(1, &vaoName);
}

-(void) dealloc {
	NSLog(@"renderer dealloc");
	
	// Delete VBOs, VAO, program(s), textures
	glBindVertexArray(vaoName);
	[self delVBOs];
	[self delVAO];
	glDeleteProgram(programName);
	
	if (texData) free(texData);
	glDeleteTextures(1, &texName);
	
}
@end



