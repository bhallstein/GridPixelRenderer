//
//  ShaderStr.c
//  OpenGL3.2-Mac
//
//  Created by Ben on 25/09/2013.
//  Copyright (c) 2013 Ben. All rights reserved.
//

#include <stdio.h>
#include "ShaderStr.h"
#import <Foundation/Foundation.h>

ShaderStr loadShaderString(const char *pFileName) {
	NSString *fn = [NSString stringWithFormat:@"%s", pFileName];
	fn = [[NSBundle mainBundle] pathForResource:fn ofType:@"sh"];
	NSString *str = [NSString stringWithContentsOfFile:fn encoding:NSUTF8StringEncoding error:NULL];
	
	ShaderStr shaderStr;
	const char *tempCStr = [str cStringUsingEncoding:NSUTF8StringEncoding];
	shaderStr.s = (char*) malloc(sizeof(char) * str.length + 1);
	
	for (int i=0; i < str.length; ++i)
		shaderStr.s[i] = tempCStr[i];
	shaderStr.s[str.length] = '\0';
	
	return shaderStr;
}