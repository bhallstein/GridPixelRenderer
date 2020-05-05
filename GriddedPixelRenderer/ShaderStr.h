//
//  ShaderStr.h
//  OpenGL3_2_Render_to_Tex
//
//  Created by Ben on 25/09/2013.
//  Copyright (c) 2013 Ben. All rights reserved.
//

#ifndef __OpenGL3_2_Render_to_Tex__ShaderStr__
#define __OpenGL3_2_Render_to_Tex__ShaderStr__

typedef struct ShaderStr {
	char *s;
} ShaderStr;

ShaderStr loadShaderString(const char *fileName);

#endif
