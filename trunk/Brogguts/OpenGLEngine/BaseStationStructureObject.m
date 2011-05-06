//
//  BaseStationStructure.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BaseStationStructureObject.h"
#import "CraftAndStructures.h"
#import "Global.h"
#import "Image.h"
#import "ImageRenderSingleton.h"

@implementation BaseStationStructureObject

- (void)dealloc {
    [blinkingLightImage release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureBaseStationID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
		isTouchable = NO;
        blinkingLightImage = [[Image alloc] initWithImageNamed:@"defaultTexture.png" filter:GL_LINEAR];
        [blinkingLightImage setScale:Scale2fMake(0.25f, 0.25f)];
        [blinkingLightImage setRenderLayer:kLayerTopLayer];
        rotationCounter = 0.0f;
        blinkCounter = 0.0f;
        lightPositionCounter = 0.0f;
	}
	return self;
}

- (BOOL)attackedByEnemy:(TouchableObject *)enemy withDamage:(int)damage {
    [self blinkSelectionCircle];
    return [super attackedByEnemy:enemy withDamage:damage];
}

- (void)objectEnteredEffectRadius:(TouchableObject*)other {
	// For mining ships, turn in brogguts
	if (objectAlliance == other.objectAlliance) {
		if ([other isKindOfClass:[CraftObject class]]) {
			CraftObject* otherCraft = (CraftObject*)other;
			[otherCraft cashInBrogguts];
		}
	}
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if (blinkCounter > 0.0f) {
        blinkCounter -= aDelta;
    }
    if (blinkCounter <= 0.0f) {
        blinkCounter = 0.0f;
    }
    
    if (rotationCounter < BASE_STATION_LIGHT_DELAY) {
        rotationCounter += aDelta;
    }
    if (rotationCounter >= BASE_STATION_LIGHT_DELAY) {
        rotationCounter = 0.0f;
        blinkCounter = BASE_STATION_LIGHT_BLINK;
        if (lightPositionCounter < 360.0f) {
            lightPositionCounter += BASE_STATION_LIGHT_MOVE_DEGREES;
        }
        if (lightPositionCounter >= 360.0f) {
            lightPositionCounter = 0.0f;
        }
    }
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    if (blinkCounter > 0.0f) {
        if (objectAlliance == kAllianceFriendly) {
            [blinkingLightImage setColor:Color4fMake(0.0f, 0.75f, 0.1f, blinkCounter / BASE_STATION_LIGHT_BLINK)]; 
        } else if (objectAlliance == kAllianceEnemy) {
            [blinkingLightImage setColor:Color4fMake(1.0f, 0.0f, 0.0f, blinkCounter / BASE_STATION_LIGHT_BLINK)];
        }        
        
        float xPos1 = objectLocation.x + (BASE_STATION_LIGHT_OUTER_DISTANCE * cosf(DEGREES_TO_RADIANS(lightPositionCounter)));
        float yPos1 = objectLocation.y + (BASE_STATION_LIGHT_OUTER_DISTANCE * sinf(DEGREES_TO_RADIANS(lightPositionCounter)));
        CGPoint point1 = CGPointMake(xPos1, yPos1);
        [blinkingLightImage renderCenteredAtPoint:point1 withScrollVector:scroll];
        
        float xPos2 = objectLocation.x + (BASE_STATION_LIGHT_INNER_DISTANCE * cosf(DEGREES_TO_RADIANS(360.0f - lightPositionCounter)));
        float yPos2 = objectLocation.y + (BASE_STATION_LIGHT_INNER_DISTANCE * sinf(DEGREES_TO_RADIANS(360.0f - lightPositionCounter)));
        CGPoint point2 = CGPointMake(xPos2, yPos2);
        [blinkingLightImage renderCenteredAtPoint:point2 withScrollVector:scroll];
    }
}

@end
