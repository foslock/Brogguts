//
//  FixerStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "FixerStructureObject.h"
#import "CraftAndStructures.h"

@implementation FixerStructureObject

- (void)dealloc {
	[closeFriendlyCraft release];
	[repairingCraft release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureFixerID withLocation:location isTraveling:traveling];
	if (self) {
		repairCountdownTimer = 0;
		isCheckedForRadialEffect = YES;
		isRepairingCraft = NO;
		closeFriendlyCraft = [[NSMutableArray alloc] initWithCapacity:REPAIR_MAX_CRAFT_COUNT];
		repairingCraft = [[NSMutableArray alloc] initWithCapacity:REPAIR_MAX_CRAFT_COUNT];
		attributeRepairAmount = kStructureFixerRepairRate;
		attributeRepairMaxCount = kStructureFixerFriendlyTargetLimit;
		attributeRepairRange = kStructureFixerRepairRange;
		effectRadius = attributeRepairRange;
	}
	return self;
}

- (void)objectEnteredEffectRadius:(TouchableObject *)other {
	[super objectEnteredEffectRadius:other];
	if (!isTraveling) {
		if ([other isKindOfClass:[CraftObject class]]) {
			if (other.objectAlliance == kAllianceFriendly) {
				if (![closeFriendlyCraft containsObject:other]) {
					[closeFriendlyCraft addObject:other];
				}
			}
		}
	}
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	if (!isTraveling) {
		// For the close craft array by the objects' current hull
		NSSortDescriptor* sorter = [[NSSortDescriptor alloc] initWithKey:@"attributeHullCurrent" ascending:YES];
		NSArray* sorterArray = [NSArray arrayWithObject:sorter];
		[closeFriendlyCraft sortUsingDescriptors:sorterArray];
		[sorter release];
		[repairingCraft removeAllObjects];
		int shipCount = CLAMP([closeFriendlyCraft count], 0, attributeRepairMaxCount);
		for (int i = 0; i < shipCount; i++) {
			CraftObject* craft = [closeFriendlyCraft objectAtIndex:i];
			if (GetDistanceBetweenPoints(objectLocation, craft.objectLocation) <= attributeRepairRange && 
				![craft isHullFull]) {
				[craft repairCraft:attributeRepairAmount];
				[repairingCraft addObject:craft];
			}
		}
	}
	
	[super updateObjectLogicWithDelta:aDelta];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	[super renderCenteredAtPoint:aPoint withScrollVector:vector];
	
	enablePrimitiveDraw();
	for (CraftObject* craft in repairingCraft) {
		glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
		glLineWidth(4.0f);
		drawLine(objectLocation, craft.objectLocation, vector);
		glLineWidth(1.0f);
	}
	disablePrimitiveDraw();
	
}

@end
