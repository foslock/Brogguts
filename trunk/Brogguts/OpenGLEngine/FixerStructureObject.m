//
//  FixerStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "FixerStructureObject.h"
#import "CraftAndStructures.h"
#import "GameplayConstants.h"
#import "Image.h"
#import "UpgradeManager.h"
#import "BroggutScene.h"
#import "GameController.h"

@implementation FixerStructureObject

- (void)dealloc {
	[closeFriendlyCraft release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureFixerID withLocation:location isTraveling:traveling];
	if (self) {
        self.objectScale = Scale2fMake(0.65f, 0.65f);
		repairCountdownTimer = 0;
        currentRepairCount = 0;
        for (int i = 0; i < REPAIR_MAX_CRAFT_COUNT; i++) {
            laserCountdownTimer[i] = 0;
        }
		isCheckedForRadialEffect = YES;
        isDrawingEffectRadius = YES;
        isOverviewDrawingEffectRadius = YES;
		isRepairingCraft = NO;
		closeFriendlyCraft = [[NSMutableArray alloc] initWithCapacity:REPAIR_MAX_CRAFT_COUNT];
		attributeRepairAmount = kStructureFixerRepairAmount;
        attributeRepairCooldown = kStructureFixerRepairCooldown;
		attributeRepairMaxCount = CLAMP(kStructureFixerFriendlyTargetLimit, 0, REPAIR_MAX_CRAFT_COUNT);
		attributeRepairRange = kStructureFixerRepairRange;
		effectRadius = attributeRepairRange;
	}
	return self;
}

- (void)objectEnteredEffectRadius:(TouchableObject *)other {
	[super objectEnteredEffectRadius:other];
	if (!isTraveling) {
		if ([other isKindOfClass:[CraftObject class]] && other.objectType != kObjectCraftSpiderDroneID) {
			if (other.objectAlliance == objectAlliance) {
                CraftObject* craft = (CraftObject*)other;
                if (![craft isHullFull]) {
                    if (![closeFriendlyCraft containsObject:other]) {
                        [closeFriendlyCraft addObject:other];
                    }
                }
			}
		}
	}
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        attributeRepairMaxCount = kStructureFixerFriendlyTargetLimitUpgrade;
    }
    
	if (!isTraveling) {
        for (int i = 0; i < [closeFriendlyCraft count]; i++) {
            CraftObject* craft = [closeFriendlyCraft objectAtIndex:i];
            if (GetDistanceBetweenPointsSquared(objectLocation, craft.objectLocation) > POW2(attributeRepairRange) || [craft isHullFull]) {
                [closeFriendlyCraft removeObject:craft];
            }
        }
        
        // Notch down the laser countdowns
        for (int i = 0; i < REPAIR_MAX_CRAFT_COUNT; i++) {
            if (laserCountdownTimer[i] > 0) {
                laserCountdownTimer[i] -= 1;
            }
        }
        
		// For the close craft array by the objects' current hull
		NSSortDescriptor* sorter = [[NSSortDescriptor alloc] initWithKey:@"attributeHullCurrent" ascending:YES];
		NSArray* sorterArray = [NSArray arrayWithObject:sorter];
		[closeFriendlyCraft sortUsingDescriptors:sorterArray];
		[sorter release];
		int shipCount = CLAMP([closeFriendlyCraft count], 0, attributeRepairMaxCount);
        currentRepairCount = shipCount;
        if (repairCountdownTimer <= 0) {
            for (int i = 0; i < shipCount; i++) {
                CraftObject* craft = [closeFriendlyCraft objectAtIndex:i];
                [craft repairCraft:attributeRepairAmount];
                if (laserCountdownTimer[i] <= 0) {
                    laserCountdownTimer[i] = REPAIR_LASER_FRAMES;
                }
            }
            repairCountdownTimer = attributeRepairCooldown;
        } else {
            repairCountdownTimer--;
        }
	}
	
	[super updateObjectLogicWithDelta:aDelta];
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    enablePrimitiveDraw();
    for (int i = 0; i < currentRepairCount; i++)  {
        CraftObject* craft = [closeFriendlyCraft objectAtIndex:i];
        [GameController setGlColorFriendly:0.8f];
        int remainder = laserCountdownTimer[i] % 20;
        float width = REPAIR_LASER_WIDTH * (float)remainder / 20.0f; 
        if (width > 0.0f) {
            glLineWidth(width);
            drawLine(objectLocation, craft.objectLocation, scroll);
            glLineWidth(1.0f);
        }
    }
    disablePrimitiveDraw();
}

@end
