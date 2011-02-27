//
//  MonarchCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MonarchCraftObject.h"
#import "Image.h"

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
	}
}

- (void)removeCraftFromSquad:(CraftObject *)craft {
	if (numberOfShipsInSquad > 0 && [squadCraft containsObject:craft]) {
		[craft setIsPartOfASquad:NO];
		[squadCraft removeObject:craft];
		numberOfShipsInSquad--;
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
		float radDir = DEGREES_TO_RADIANS(objectRotation);
		float xPos = location.x + (sinf(radDir) * SQUAD_CRAFT_DISTANCE);
		float yPos = location.y + (cosf(radDir) * SQUAD_CRAFT_DISTANCE);
		CGPoint position = CGPointMake(xPos, yPos);
		NSArray* newPath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:position]];
		[craft1 followPath:newPath isLooped:NO];
	}
}

@end
