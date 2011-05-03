//
//  ExplosionObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/18/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "ExplosionObject.h"
#import "AnimatedImage.h"
#import "Image.h"
#import "ImageRenderSingleton.h"

@implementation ExplosionObject

- (void)dealloc {
    [animatedImage release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location withSize:(int)size {
    self = [super initWithImage:nil withLocation:location withObjectType:kObjectExplosionObjectID];
    if (self) {
        switch (size) {
            case kExplosionSizeSmall: {
                animatedImage = [[AnimatedImage alloc] initWithFileName:kObjectExplosionSmallSprite withSubImageCount:8];
            }
                break;
            case kExplosionSizeMedium: {
                // animatedImage = [[AnimatedImage alloc] initWithFileName:kObjectExplosionMediumSprite withSubImageCount:6];
            }
                break;
            case kExplosionSizeLarge: {
                animatedImage = [[AnimatedImage alloc] initWithFileName:kObjectExplosionLargeSprite withSubImageCount:8];
            }
                break;
            default:
                break;
        }
        self.objectRotation = RANDOM_0_TO_1() * 360.0f;
        [animatedImage setAnimationSpeed:0.15f + (RANDOM_0_TO_1() * 0.05f)];
        [animatedImage setRenderLayer:kLayerBottomLayer];
    }
    return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if ([animatedImage isAnimationComplete]) {
        self.destroyNow = YES;
    }
    
    [animatedImage updateAnimatedImageWithDelta:aDelta];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    [animatedImage renderCurrentSubImageAtPoint:CGPointMake(objectLocation.x - vector.x, objectLocation.y - vector.y)
                                      withScale:Scale2fMake(1.0f, 1.0f)
                                   withRotation:objectRotation];
}


@end
