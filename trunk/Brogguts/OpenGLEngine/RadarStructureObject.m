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
#import "BroggutScene.h"
#import "UpgradeManager.h"

@implementation RadarStructureObject

- (void)dealloc {
    [radarDishImage release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureRadarID withLocation:location isTraveling:traveling];
	if (self) {
        self.objectScale = Scale2fMake(0.5f, 0.5f);
		isCheckedForRadialEffect = YES;
        isDrawingEffectRadius = YES;
        isOverviewDrawingEffectRadius = YES;
        effectRadius = kStructureRadarRadius;
        radarDishImage = [[Image alloc] initWithImageNamed:kObjectStructureRadarDishSprite filter:GL_LINEAR];
        [radarDishImage setScale:[objectImage scale]];
        [radarDishImage setRenderLayer:kLayerMiddleLayer];
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType] && objectAlliance == kAllianceFriendly) {
        attributeViewDistance = kStructureRadarViewDistanceUpgrade;
        effectRadius = kStructureRadarRadiusUpgrade;
    }
}

- (void)objectEnteredEffectRadius:(TouchableObject *)other {
    if (other.objectType == kObjectCraftRatID) {
        RatCraftObject* rat = (RatCraftObject*)other;
        if (rat.objectAlliance != objectAlliance) {
            [rat setIsCloaked:NO withRadar:self];
        }
    }
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    [super renderCenteredAtPoint:aPoint withScrollVector:vector];
    [radarDishImage renderCenteredAtPoint:aPoint withScrollVector:vector];
}

@end
