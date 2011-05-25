//
//  TiledButtonObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

#define BUTTON_DISABLED_COLOR Color4fMake(0.35f, 0.35f, 0.35f, 1.0f)
#define BUTTON_ENABLED_COLOR Color4fMake(1.0f, 1.0f, 1.0f, 1.0f)
#define BUTTON_PRESSED_COLOR Color4fMake(0.8f, 0.8f, 0.8f, 1.0f)

@class Image;

@interface TiledButtonObject : TouchableObject {
    CGRect drawRect;
    NSMutableArray* images;
    
    // Top Row
    Image* topLeft;
    Image* topMiddle;       // Scaled
    Image* topRight;
    
    // Middle Row
    Image* middleLeft;      // Scaled
    Image* middleMiddle;    // Scaled
    Image* middleRight;     // Scaled
    
    // Bottom Row
    Image* bottomLeft;
    Image* bottomMiddle;    // Scaled
    Image* bottomRight;
    
    BOOL isPushable;
    BOOL isPushed;
    BOOL wasJustReleased;
    BOOL isDisabled;
    
    Color4f inactiveColor;
    Color4f pressedColor;
}

@property (readonly) BOOL isPushable;
@property (readonly) BOOL isPushed;
@property (readonly) BOOL wasJustReleased;
@property (nonatomic, assign) BOOL isDisabled;
@property (readonly) CGRect drawRect;

// This rect must have an EVEN width and height both above 48 pixels
- (id)initWithRect:(CGRect)buttonRect;

- (void)setDrawRect:(CGRect)rect;
- (void)setIsPushable:(BOOL)pushable;
- (void)setIsPushed:(BOOL)pushed;
- (void)setRenderLayer:(GLuint)renderLayer;

@end
