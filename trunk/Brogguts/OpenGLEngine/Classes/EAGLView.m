//
//  EAGLView.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 1/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "EAGLView.h"

#import "ES1Renderer.h"
#import "ES2Renderer.h"
#import "GameController.h"
#import "ImageRenderSingleton.h"

@interface EAGLView (Private)

// Called regularly by either a CADisplayLink or NSTimer.  Its responsible for
// updating the game logic and rendering a game scene
@property (nonatomic, getter=isAnimating) BOOL animating;
- (void)gameLoop;
@end

@implementation EAGLView

@synthesize animating, animationFrameInterval, displayLink, animationTimer;


// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)dealloc
{
    [renderer release];
    [displayLink release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Init EAGLView

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    self = [super initWithCoder:coder];
    if (self)
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
/*
        renderer = [[ES2Renderer alloc] init];

        if (!renderer)
        {*/
        
            renderer = [[ES1Renderer alloc] init];

            if (!renderer)
            {
                [self release];
                return nil;
            }
        
        /*}*/

        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;

        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
		
		sharedGameController = [GameController sharedGameController];
		sharedGameController.eaglView = self;
		self.multipleTouchEnabled = YES;
    }

    return self;
}

#pragma mark -
#pragma mark Main Game Loop

#define MAXIMUM_FRAME_RATE 120		// Must also be set in ParticleEmitter.m
#define MINIMUM_FRAME_RATE 15
#define UPDATE_INTERVAL (1.0 / MAXIMUM_FRAME_RATE)
#define MAX_CYCLES_PER_FRAME (MAXIMUM_FRAME_RATE / MINIMUM_FRAME_RATE)

- (void)gameLoop {
	
	static double lastFrameTime = 0.0f;
	static double cyclesLeftOver = 0.0f;
	double currentTime;
	double updateIterations;
	
	// Apple advises to use CACurrentMediaTime() as CFAbsoluteTimeGetCurrent() is synced with the mobile
	// network time and so could change causing hiccups.
	currentTime = CACurrentMediaTime(); 
	updateIterations = ((currentTime - lastFrameTime) + cyclesLeftOver);
	
	if(updateIterations > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
		updateIterations = (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL);
	
	while (updateIterations >= UPDATE_INTERVAL) {
		updateIterations -= UPDATE_INTERVAL;
		
		// Update the game logic passing in the fixed update interval as the delta
		[sharedGameController updateCurrentSceneWithDelta:UPDATE_INTERVAL];		
	}
	
	cyclesLeftOver = updateIterations;
	lastFrameTime = currentTime;
	
	// Render the scene
    [self drawView:nil];
}

- (void) drawView:(id)sender
{
    [renderer render];
}

- (void) layoutSubviews
{
	[renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self gameLoop];
}

#pragma mark -
#pragma mark Animation Control

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;

        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.

            self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(gameLoop)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];

        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            self.displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            self.animationTimer = nil;
        }

        animating = FALSE;
    }
}

#pragma mark -
#pragma mark Touches

// All touch events are passed to the current scene for processing.  The only local processing
// which is done is to capture taps that represent a request for the settings view.  This should
// be possible from any view so it is performed at the EAGLView level

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	// Pass touch events onto the current scene
	if (!sharedGameController.isFadingSceneIn && !sharedGameController.isFadingSceneOut)
		[[sharedGameController currentScene] touchesBegan:touches withEvent:event view:self];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	// Pass touch events onto the current scene
	if (!sharedGameController.isFadingSceneIn && !sharedGameController.isFadingSceneOut)
		[[sharedGameController currentScene] touchesMoved:touches withEvent:event view:self];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	// Pass touch events onto the current scene
	if (!sharedGameController.isFadingSceneIn && !sharedGameController.isFadingSceneOut)
		[[sharedGameController currentScene] touchesEnded:touches withEvent:event view:self];
}

- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
	// Pass touch events onto the current scene
	if (!sharedGameController.isFadingSceneIn && !sharedGameController.isFadingSceneOut)
		[[sharedGameController currentScene] touchesCancelled:touches withEvent:event view:self];
}


@end
