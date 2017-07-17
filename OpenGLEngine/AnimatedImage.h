//
//  AnimatedImage.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/18/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

// This class automatically loops an animated set of frames

@interface AnimatedImage : NSObject {
    int currentSubImage;
    float animationCounter;
    float animationSpeed;
    int subImageCount;
    NSArray* subImageArray;
}

@property (nonatomic, assign) float animationSpeed;

- (BOOL)isAnimating;
- (BOOL)isAnimationComplete;
- (id)initWithFileName:(NSString*)filename withSubImageCount:(int)count;
- (void)updateAnimatedImageWithDelta:(float)aDelta;
- (void)renderCurrentSubImageAtPoint:(CGPoint)aPoint;
- (void)renderCurrentSubImageAtPoint:(CGPoint)aPoint withScale:(Scale2f)aScale withRotation:(float)aRot;
- (CGSize)imageSize;
- (void)setRenderLayer:(int)layer;
- (void)setScale:(Scale2f)scale;

@end
