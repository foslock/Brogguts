//
//  MonarchCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MonarchCraftObject.h"
#import "Image.h"
#import "BroggutScene.h"

@implementation MonarchCraftObject
@synthesize isLeadingSquad, numberOfShipsInSquad;

- (void)dealloc {
	[squadCraft release];
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftMonarchID withLocation:location isTraveling:traveling];
	if (self) {
		isLeadingSquad = NO;
		numberOfShipsInSquad = 0;
		squadCraft = [[NSMutableArray alloc] initWithCapacity:MAX_CRAFT_IN_SQUAD];
	}
	return self;
}

- (Circle)touchableBounds { // Could be Bigger than bounding circle, so that it's not hard to tap on it
	Circle tempBoundingCircle;
	tempBoundingCircle.x = objectLocation.x;
	tempBoundingCircle.y = objectLocation.y;
	if (isLeadingSquad)
		tempBoundingCircle.radius = SQUAD_CRAFT_DISTANCE; // Large
	else
		tempBoundingCircle.radius = objectImage.imageSize.width / 2; // Same as the bounding circle for now
	return tempBoundingCircle;
}

- (BOOL)performSpecialAbilityAtLocation:(CGPoint)location {
	if ([super performSpecialAbilityAtLocation:location]) {
		TouchableObject* enemy = [self.currentScene attemptToAttackCraftAtLocation:location];
		if (enemy) {
			for (CraftObject* craft in squadCraft) {
				[craft setPriorityEnemyTarget:enemy];
				[craft blinkSelectionCircle];
			}
		}
		return YES;
	}
	return NO;
}

- (void)drawHoverSelectionWithScroll:(Vector2f)scroll {
	if (isCurrentlyHoveredOver) {
		// Draw "selection circle"
		if (objectAlliance == kAllianceFriendly) {
			glColor4f(0.0f, 1.0f, 0.0f, 0.8f);
		} else {
			glColor4f(1.0f, 0.0f, 0.0f, 0.8f);
		}
		if (isLeadingSquad)
			drawDashedCircle(self.touchableBounds, CIRCLE_SEGMENTS_COUNT, scroll);
		else
			drawDashedCircle(self.boundingCircle, CIRCLE_SEGMENTS_COUNT, scroll);
	}
}

- (void)accelerateTowardsLocation:(CGPoint)location {
	[self repositionCraftInSquadToLocation:objectLocation];
	[super accelerateTowardsLocation:location];
}

- (void)followPath:(NSArray *)array isLooped:(BOOL)looped {
	NSValue* value = [array lastObject];
	[self repositionCraftInSquadToLocation:[value CGPointValue]];
	[super followPath:array isLooped:looped];
}

- (void)addCraftToSquad:(CraftObject *)craft {
	if (numberOfShipsInSquad < MAX_CRAFT_IN_SQUAD && ![squadCraft containsObject:craft]) {
		[craft setIsPartOfASquad:YES];
		[squadCraft addObject:craft];
		numberOfShipsInSquad++;
		isLeadingSquad = YES;
		[self repositionCraftInSquadToLocation:objectLocation];
	}
}

- (void)removeCraftFromSquad:(CraftObject *)craft {
	if (numberOfShipsInSquad > 0 && [squadCraft containsObject:craft]) {
		[craft setIsPartOfASquad:NO];
		[squadCraft removeObject:craft];
		numberOfShipsInSquad--;
		[self repositionCraftInSquadToLocation:objectLocation];
	}
	if (numberOfShipsInSquad == 0) {
		isLeadingSquad = NO;
	}
}

- (void)repositionCraftInSquadToLocation:(CGPoint)location {
	if (numberOfShipsInSquad == 0) {
		isLeadingSquad = NO;
		return;
	}
	if (numberOfShipsInSquad == 1) {
		
		CraftObject* craft1 = [squadCraft objectAtIndex:0];
		if (craft1.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir = DEGREES_TO_RADIANS(objectRotation + 90);
			float xPos = location.x + (cosf(radDir) * SQUAD_CRAFT_DISTANCE);
			float yPos = location.y + (sinf(radDir) * SQUAD_CRAFT_DISTANCE);
			CGPoint position = CGPointMake(xPos, yPos);
			NSArray* newPath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position]];
			[craft1 followPath:newPath isLooped:NO];
		}
		
	} else if (numberOfShipsInSquad == 2) {
		
		CraftObject* craft1 = [squadCraft objectAtIndex:0];
		if (craft1.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir1 = DEGREES_TO_RADIANS(objectRotation + 90);
			float xPos1 = location.x + (cosf(radDir1) * SQUAD_CRAFT_DISTANCE);
			float yPos1 = location.y + (sinf(radDir1) * SQUAD_CRAFT_DISTANCE);
			CGPoint position1 = CGPointMake(xPos1, yPos1);
			NSArray* newPath1 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position1]];
			[craft1 followPath:newPath1 isLooped:NO];
		}
		
		CraftObject* craft2 = [squadCraft objectAtIndex:1];
		if (craft2.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir2 = DEGREES_TO_RADIANS(objectRotation + 270);
			float xPos2 = location.x + (cosf(radDir2) * SQUAD_CRAFT_DISTANCE);
			float yPos2 = location.y + (sinf(radDir2) * SQUAD_CRAFT_DISTANCE);
			CGPoint position2 = CGPointMake(xPos2, yPos2);
			NSArray* newPath2 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position2]];
			[craft2 followPath:newPath2 isLooped:NO];
		}
		
	} else if (numberOfShipsInSquad == 3) {
		
		CraftObject* craft1 = [squadCraft objectAtIndex:0];
		if (craft1.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir1 = DEGREES_TO_RADIANS(objectRotation);
			float xPos1 = location.x + (cosf(radDir1) * SQUAD_CRAFT_DISTANCE);
			float yPos1 = location.y + (sinf(radDir1) * SQUAD_CRAFT_DISTANCE);
			CGPoint position1 = CGPointMake(xPos1, yPos1);
			NSArray* newPath1 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position1]];
			[craft1 followPath:newPath1 isLooped:NO];
		}
		
		CraftObject* craft2 = [squadCraft objectAtIndex:1];
		if (craft2.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir2 = DEGREES_TO_RADIANS(objectRotation + 120);
			float xPos2 = location.x + (cosf(radDir2) * SQUAD_CRAFT_DISTANCE);
			float yPos2 = location.y + (sinf(radDir2) * SQUAD_CRAFT_DISTANCE);
			CGPoint position2 = CGPointMake(xPos2, yPos2);
			NSArray* newPath2 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position2]];
			[craft2 followPath:newPath2 isLooped:NO];
		}
		
		CraftObject* craft3 = [squadCraft objectAtIndex:2];
		if (craft3.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir3 = DEGREES_TO_RADIANS(objectRotation + 240);
			float xPos3 = location.x + (cosf(radDir3) * SQUAD_CRAFT_DISTANCE);
			float yPos3 = location.y + (sinf(radDir3) * SQUAD_CRAFT_DISTANCE);
			CGPoint position3 = CGPointMake(xPos3, yPos3);
			NSArray* newPath3 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position3]];
			[craft3 followPath:newPath3 isLooped:NO];
		}
		
	} else if (numberOfShipsInSquad == 4) {
		
		CraftObject* craft1 = [squadCraft objectAtIndex:0];
		if (craft1.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir1 = DEGREES_TO_RADIANS(objectRotation + 45);
			float xPos1 = location.x + (cosf(radDir1) * SQUAD_CRAFT_DISTANCE);
			float yPos1 = location.y + (sinf(radDir1) * SQUAD_CRAFT_DISTANCE);
			CGPoint position1 = CGPointMake(xPos1, yPos1);
			NSArray* newPath1 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position1]];
			[craft1 followPath:newPath1 isLooped:NO];
		}
		
		CraftObject* craft2 = [squadCraft objectAtIndex:1];
		if (craft2.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir2 = DEGREES_TO_RADIANS(objectRotation + 135);
			float xPos2 = location.x + (cosf(radDir2) * SQUAD_CRAFT_DISTANCE);
			float yPos2 = location.y + (sinf(radDir2) * SQUAD_CRAFT_DISTANCE);
			CGPoint position2 = CGPointMake(xPos2, yPos2);
			NSArray* newPath2 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position2]];
			[craft2 followPath:newPath2 isLooped:NO];
		}
		
		CraftObject* craft3 = [squadCraft objectAtIndex:2];
		if (craft3.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir3 = DEGREES_TO_RADIANS(objectRotation + 225);
			float xPos3 = location.x + (cosf(radDir3) * SQUAD_CRAFT_DISTANCE);
			float yPos3 = location.y + (sinf(radDir3) * SQUAD_CRAFT_DISTANCE);
			CGPoint position3 = CGPointMake(xPos3, yPos3);
			NSArray* newPath3 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position3]];
			[craft3 followPath:newPath3 isLooped:NO];
		}
		
		CraftObject* craft4 = [squadCraft objectAtIndex:3];
		if (craft4.friendlyAIState != kFriendlyAIStateAttacking) {
			float radDir4 = DEGREES_TO_RADIANS(objectRotation + 315);
			float xPos4 = location.x + (cosf(radDir4) * SQUAD_CRAFT_DISTANCE);
			float yPos4 = location.y + (sinf(radDir4) * SQUAD_CRAFT_DISTANCE);
			CGPoint position4 = CGPointMake(xPos4, yPos4);
			NSArray* newPath4 = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position4]];
			[craft4 followPath:newPath4 isLooped:NO];
		}
		
	}
}

- (void)objectWasDestroyed {
	for (CraftObject* craft in squadCraft) {
		[self removeCraftFromSquad:craft];
	}
	[super objectWasDestroyed];
}

@end
