//
//  RefineryStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/18/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "RefineryStructureObject.h"
#import "AnimatedImage.h"
#import "Image.h"

@implementation RefineryStructureObject

- (void)dealloc {
    [animatedImage release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureRefineryID withLocation:location isTraveling:traveling];
	if (self) {
        animatedImage = [[AnimatedImage alloc] initWithFileName:kObjectStructureRefinerySprite withSubImageCount:4];
        [animatedImage setAnimationSpeed:0.1f];
		isCheckedForRadialEffect = NO;
		isTouchable = NO;
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    [animatedImage updateAnimatedImageWithDelta:aDelta];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    // [self renderCenteredAtPoint:aPoint withScrollVector:vector];
    [animatedImage renderCurrentSubImageAtPoint:CGPointMake(objectLocation.x - vector.x, objectLocation.y - vector.y)
                                      withScale:objectImage.scale
                                   withRotation:objectRotation];
}

@end
