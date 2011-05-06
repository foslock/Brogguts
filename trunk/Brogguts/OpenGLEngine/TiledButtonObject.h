//
//  TiledButtonObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/27/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

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
}

@property (readonly) BOOL isPushable;
@property (readonly) BOOL isPushed;
@property (readonly) BOOL wasJustReleased;

// This rect must have an EVEN width and height both above 48 pixels
- (id)initWithRect:(CGRect)buttonRect;

- (void)setDrawRect:(CGRect)rect;
- (void)setIsPushable:(BOOL)pushable;
- (void)setIsPushed:(BOOL)pushed;
- (void)setRenderLayer:(GLuint)renderLayer;

@end
