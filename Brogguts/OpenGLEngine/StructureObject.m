//
//  StructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "StructureObject.h"
#import "Image.h"

@implementation StructureObject

- (void)initStructureWithID:(int)typeID {
	switch (typeID) {
		case kObjectStructureBaseStationID:
			attributeBroggutCost = kStructureBaseStationCostBrogguts;
			attributeMetalCost = kStructureBaseStationCostMetal;
			attributeHullCapacity = kStructureBaseStationHull;
			attributeHullCurrent = kStructureBaseStationHull;
			attributeMovingTime = kStructureBaseStationMovingTime;
			break;
		case kObjectStructureBlockID:
			attributeBroggutCost = kStructureBlockCostBrogguts;
			attributeMetalCost = kStructureBlockCostMetal;
			attributeHullCapacity = kStructureBlockHull;
			attributeHullCurrent = kStructureBlockHull;
			attributeMovingTime = kStructureBlockMovingTime;
			break;
		case kObjectStructureRefineryID:
			attributeBroggutCost = kStructureRefineryCostBrogguts;
			attributeMetalCost = kStructureRefineryCostMetal;
			attributeHullCapacity = kStructureRefineryHull;
			attributeHullCurrent = kStructureRefineryHull;
			attributeMovingTime = kStructureRefineryMovingTime;
			break;
		case kObjectStructureCraftUpgradesID:
			attributeBroggutCost = kStructureCraftUpgradesCostBrogguts;
			attributeMetalCost = kStructureCraftUpgradesCostMetal;
			attributeHullCapacity = kStructureCraftUpgradesHull;
			attributeHullCurrent = kStructureCraftUpgradesHull;
			attributeMovingTime = kStructureCraftUpgradesMovingTime;
			break;
		case kObjectStructureStructureUpgradesID:
			attributeBroggutCost = kStructureStructureUpgradesCostBrogguts;
			attributeMetalCost = kStructureStructureUpgradesCostMetal;
			attributeHullCapacity = kStructureStructureUpgradesHull;
			attributeHullCurrent = kStructureStructureUpgradesHull;
			attributeMovingTime = kStructureStructureUpgradesMovingTime;
			break;
		case kObjectStructureTurretID:
			attributeBroggutCost = kStructureTurretCostBrogguts;
			attributeMetalCost = kStructureTurretCostMetal;
			attributeHullCapacity = kStructureTurretHull;
			attributeHullCurrent = kStructureTurretHull;
			attributeMovingTime = kStructureTurretMovingTime;
			break;
		case kObjectStructureRadarID:
			attributeBroggutCost = kStructureRadarCostBrogguts;
			attributeMetalCost = kStructureRadarCostMetal;
			attributeHullCapacity = kStructureRadarHull;
			attributeHullCurrent = kStructureRadarHull;
			attributeMovingTime = kStructureRadarMovingTime;
			break;
		case kObjectStructureFixerID:
			attributeBroggutCost = kStructureFixerCostBrogguts;
			attributeMetalCost = kStructureFixerCostMetal;
			attributeHullCapacity = kStructureFixerHull;
			attributeHullCurrent = kStructureFixerHull;
			attributeMovingTime = kStructureFixerMovingTime;
			break;
		default:
			break;
	}
}

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	Image* image;
	switch (typeID) {
		case kObjectStructureBaseStationID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureBaseStationSprite filter:GL_LINEAR];
			break;
		case kObjectStructureBlockID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureBlockSprite filter:GL_LINEAR];
			break;
		case kObjectStructureRefineryID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureRefinerySprite filter:GL_LINEAR];
			break;
		case kObjectStructureCraftUpgradesID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureCraftUpgradesSprite filter:GL_LINEAR];
			break;
		case kObjectStructureStructureUpgradesID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureStructureUpgradesSprite filter:GL_LINEAR];
			break;
		case kObjectStructureTurretID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureTurretSprite filter:GL_LINEAR];
			break;
		case kObjectStructureRadarID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureRadarSprite filter:GL_LINEAR];
			break;
		case kObjectStructureFixerID:
			image = [[Image alloc] initWithImageNamed:kObjectStructureFixerSprite filter:GL_LINEAR];
			break;
		default:
			break;
	}
	self = [super initWithImage:image withLocation:location withObjectType:typeID];
	if (self) {
		staticObject = YES;
		isTouchable = NO;
		// Initialize the structure
		[self initStructureWithID:typeID];
	}
	return self;
}

- (void)touchesBeganAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesMovedToLocation:(CGPoint)toLocation from:(CGPoint)fromLocation {
	// OVERRIDE ME
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	// OVERRIDE ME
}

- (void)touchesDoubleTappedAtLocation:(CGPoint)location {
	// OVERRIDE ME
	NSLog(@"Object (%i) was double tapped!", uniqueObjectID);
}

@end
