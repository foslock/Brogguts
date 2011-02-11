//
//  EAGLView.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 1/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"

@class GameController;
@class ImageRenderSingleton;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
    id <ESRenderer> renderer;
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    id displayLink;
    NSTimer *animationTimer;
	GameController *sharedGameController;
    CFTimeInterval lastTime;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) id displayLink;
@property (nonatomic, assign) NSTimer *animationTimer;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

@end
