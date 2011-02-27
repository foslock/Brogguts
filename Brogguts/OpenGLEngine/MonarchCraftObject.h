//
//  MonarchCraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CraftObject.h"

#define MAX_CRAFT_IN_SQUAD 4
#define SQUAD_CRAFT_DISTANCE 128.0f

@interface MonarchCraftObject : CraftObject {
	NSMutableArray* squadCraft;
	BOOL isLeadingSquad;
	int numberOfShipsInSquad;
}

@property (readonly) BOOL isLeadingSquad;
@property (readonly) int numberOfShipsInSquad;

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)repositionCraftInSquadToLocation:(CGPoint)location;

- (void)addCraftToSquad:(CraftObject*)craft;

- (void)removeCraftFromSquad:(CraftObject*)craft;



@end
