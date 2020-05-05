# Gridded Pixel Renderer

The important class is the OpenGL3_2Renderer one.

Initialize pixel grid:

    -(id) initWithWidth:(int) height:(int)


Get a pointer to the w x h array of ‘Colour’s which you can then modify:

    -(Colour*) texDataPointer

Reupload the texture:

    -(void) update

-- BH, 1st Oct 2013

