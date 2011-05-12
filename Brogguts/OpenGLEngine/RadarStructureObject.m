//
//  RadarStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "RadarStructureObject.h"
#import "Image.h"
#import "ImageRenderSingleton.h"
#import "RatCraftObject.h"

@implementation RadarStructureObject

- (void)dealloc {
    [radarDishImage release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureRadarID withLocation:location isTraveling:traveling];
	if (self) {
        [objectImage setScale:Scale2fMake(0.5f, 0.5f)];
		isCheckedForRadialEffect = YES;
        isDrawingEffectRadius = YES;
        effectRadius = kStructureRadarRadius;
        radarDishImage = [[Image alloc] initWithImageNamed:@"spriteradardish.png" filter:GL_LINEAR];
        [radarDishImage setScale:[objectImage scale]];
        [radarDishImage setRenderLayer:kLayerMiddleLayer];
	}
	return self;
}

- (void)objectEnteredEffectRadius:(TouchableObject *)other {
    if (other.objectType == kObjectCraftRatID) {
        RatCraftObject* rat = (RatCraftObject*)other;
        if (rat.objectAlliance != objectAlliance) {
            [rat setIsCloaked:NO];
        }
    }
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    [super renderCenteredAtPoint:aPoint withScrollVector:vector];
    [radarDishImage renderCenteredAtPoint:aPoint withScrollVector:vector];
}

@end
