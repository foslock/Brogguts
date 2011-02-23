//
//  ES1Renderer.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 1/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "ES1Renderer.h"
#import "GameController.h"
#import "BroggutScene.h"

@implementation ES1Renderer

// Create an OpenGL ES 1.1 context
- (id)init
{
    self = [super init];
    if (self)
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }

        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
    
		// Grab a reference to the game controller
        sharedGameController = [GameController sharedGameController];
		
		// As we are initializing this view then the OpenGL elements have not been initialized
		openGLInitialized = NO;
		
		// Observe orientation change notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	}

    return self;
}

- (void)render
{
    // Ask the game controller to render the current scene
    [sharedGameController renderCurrentScene];
    
    // Ask the context to present the renderbuffer to the screen
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{	
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
	
	if (!openGLInitialized) {
		openGLInitialized = YES;
		[self initOpenGL];
	}

    return YES;
}

- (void)dealloc
{
	// Remove our observation of the device orientation notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }

    if (colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }

    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];
    context = nil;

    [super dealloc];
}

@end

@implementation ES1Renderer (Private)

- (void) initOpenGL {
	NSLog(@"INFO - ES1Renderer: Initializing OpenGL");
    
	// Switch to GL_PROJECTION matrix mode and reset the current matrix with the identity matrix
	glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
	glOrthof(0, backingWidth, 0, backingHeight, -1, 1);
	
    // Set the viewport
    glViewport(0, 0, backingWidth, backingHeight);
    
    NSLog(@"INFO - ES1Renderer: Setting glOrthof to width=%d and height=%d", backingWidth,backingHeight);
    
	// Switch to GL_MODELVIEW so we can now draw our objects
	glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
	// Rotate the OpenGL model view to the right 90 degrees so that everything is rendered in landscape
	// mode
	UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIInterfaceOrientationLandscapeRight) {
		glTranslatef( kPadScreenLandscapeHeight / 2, kPadScreenLandscapeWidth / 2, 0);
		glRotatef(-90, 0, 0, 1);
		glTranslatef(- kPadScreenLandscapeWidth / 2, - kPadScreenLandscapeHeight / 2, 0);
	} else {
		glTranslatef( kPadScreenLandscapeHeight / 2, kPadScreenLandscapeWidth / 2, 0);
		glRotatef(90, 0, 0, 1);
		glTranslatef(- kPadScreenLandscapeWidth / 2, - kPadScreenLandscapeHeight / 2, 0);
	}
	
	// Setup the texture environment and blend functions.  
	// This controls how a texture is blended with other textures
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_ALPHA);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	// Set the colour to use when clearing the screen with glClear
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
	// We are not using the depth buffer in our 2D game so depth testing can be disabled.  If depth
	// testing was required then a depth buffer would need to be created as well as enabling the depth
	// test
	glDisable(GL_DEPTH_TEST);
    
    // Enable the OpenGL states we are going to be using when rendering
    glEnable(GL_BLEND);
	glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
}

- (void)orientationChanged:(NSNotification *)notification {
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationLandscapeRight) {
		sharedGameController.interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
		glLoadIdentity();
		glTranslatef( kPadScreenLandscapeHeight / 2, kPadScreenLandscapeWidth / 2, 0);
		glRotatef(90, 0, 0, 1);
		glTranslatef(- kPadScreenLandscapeWidth / 2, - kPadScreenLandscapeHeight / 2, 0);
	}
	
	if (orientation == UIDeviceOrientationLandscapeLeft) {
		sharedGameController.interfaceOrientation = UIInterfaceOrientationLandscapeRight;
		glLoadIdentity();
		glTranslatef( kPadScreenLandscapeHeight / 2, kPadScreenLandscapeWidth / 2, 0);
		glRotatef(-90, 0, 0, 1);
		glTranslatef(- kPadScreenLandscapeWidth / 2, - kPadScreenLandscapeHeight / 2, 0);
	}
}


@end
