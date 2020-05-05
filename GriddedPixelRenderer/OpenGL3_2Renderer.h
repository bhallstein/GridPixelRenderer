//
//  OpenGL3_2Renderer.h
//  OpenGL3.2-Mac
//
//  Created by Ben on 13/09/2013.
//  Copyright (c) 2013 Ben. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct Colour {
	float r, g, b, a;
} Colour;

@interface OpenGL3_2Renderer : NSObject

-(id) initWithWidth:(int)width height:(int)height;
-(void) render;
-(void) resize:(NSSize)size;
-(Colour*) texDataPointer;
-(void) update;

@end
