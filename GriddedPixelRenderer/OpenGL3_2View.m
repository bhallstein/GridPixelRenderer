//
//  OpenGL3_2View.m
//  OpenGL3.2-Mac
//
//  Created by Ben on 13/09/2013.
//  Copyright (c) 2013 Ben. All rights reserved.
//

#import "OpenGL3_2View.h"
#import "OpenGL3_2Renderer.h"

@interface OpenGL3_2View ()

@property (nonatomic) OpenGL3_2Renderer *renderer;

@end


@implementation OpenGL3_2View

//@synthesize renderer;

-(void) awakeFromNib {
	NSOpenGLPixelFormatAttribute attrs[] = {
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
		0
	};
	NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
	if (!pf)
		NSLog(@"Could not create OpenGL pixel format");
	
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
	if (!context)
		NSLog(@"Could not create OpenGL context");
	
	// Crash if a legacy function is called
	CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
	
	// Allow retina backings
	[self setWantsBestResolutionOpenGLSurface:YES];
	
    [self setPixelFormat:pf];
    [self setOpenGLContext:context];
}


-(void) prepareOpenGL {
	NSLog(@"OGLView: prepareOpenGL (%@)", self);
	
	[super prepareOpenGL];
	
	[self.openGLContext makeCurrentContext];
	
	// Enable vsync
	GLint swapInt = 1;
	[self.openGLContext setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
	
	self.renderer = [[OpenGL3_2Renderer alloc] initWithWidth:640 height:480];
	
	// Create timer
	
	// Sub to NSWindowWillClose notification
	
}

- (void) windowWillClose:(NSNotification*)notification {
	// Destroy timer
}

- (void)drawRect:(NSRect)dirtyRect {
	NSLog(@"OGLView: drawRect");
	[self.renderer render];
	[self.openGLContext flushBuffer];
}

-(void) reshape {
	NSLog(@"OGLView: reshape");
	[super reshape];
	[self.renderer resize:self.bounds.size];
}

-(void) dealloc {
	NSLog(@"OGLView dealloc");
	
	// Destroy displaylink
	// Unsub from window close notification?
}

@end


