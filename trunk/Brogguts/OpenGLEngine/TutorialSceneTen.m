//
//  TutorialSceneTen.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneTen.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"

@implementation TutorialSceneTen

- (void)dealloc {
    [mothTrigger release];
    [super dealloc];
}

- (id)init {
    self = [super initWithTutorialIndex:9];
    if (self) {
        isAllowingOverview = YES;
        CGPoint triggerLoc = [self middleOfEntireMap];
        mothTrigger = [[TriggerObject alloc] initWithLocation:triggerLoc];
        mothTrigger.numberOfObjectsNeeded = 16;
        mothTrigger.objectIDNeeded = kObjectCraftMothID;
        [self addCollidableObject:mothTrigger];
        
        for (int row = -1; row < 1; row++) {
            for (int col = -1; col < 1; col++) {
                CGPoint cornerOne = CGPointMake(fullMapBounds.size.width * (1.0f / 8.0f),
                                                fullMapBounds.size.height * (1.0f / 8.0f));
                
                CGPoint cornerTwo = CGPointMake(fullMapBounds.size.width * (7.0f / 8.0f),
                                                fullMapBounds.size.height * (1.0f / 8.0f));
                
                CGPoint cornerThree = CGPointMake(fullMapBounds.size.width * (7.0f / 8.0f),
                                                fullMapBounds.size.height * (7.0f / 8.0f));
                
                CGPoint cornerFour = CGPointMake(fullMapBounds.size.width * (1.0f / 8.0f),
                                                fullMapBounds.size.height * (7.0f / 8.0f));
                
                CGPoint mothOne = CGPointMake(cornerOne.x + (COLLISION_CELL_WIDTH * row),
                                              cornerOne.y + (COLLISION_CELL_HEIGHT * col));
                CGPoint mothTwo = CGPointMake(cornerTwo.x - (COLLISION_CELL_WIDTH * row),
                                              cornerTwo.y + (COLLISION_CELL_HEIGHT * col));
                CGPoint mothThree = CGPointMake(cornerThree.x + (COLLISION_CELL_WIDTH * row),
                                                cornerThree.y - (COLLISION_CELL_HEIGHT * col));
                CGPoint mothFour = CGPointMake(cornerFour.x - (COLLISION_CELL_WIDTH * row),
                                               cornerFour.y - (COLLISION_CELL_HEIGHT * col));
                
                MothCraftObject* mothCraftOne = [[MothCraftObject alloc] initWithLocation:mothOne isTraveling:NO];
                [mothCraftOne setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftOne withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftOne release];
                
                MothCraftObject* mothCraftTwo = [[MothCraftObject alloc] initWithLocation:mothTwo isTraveling:NO];
                [mothCraftTwo setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftTwo withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftTwo release];

                MothCraftObject* mothCraftThree = [[MothCraftObject alloc] initWithLocation:mothThree isTraveling:NO];
                [mothCraftThree setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftThree withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftThree release];

                MothCraftObject* mothCraftFour = [[MothCraftObject alloc] initWithLocation:mothFour isTraveling:NO];
                [mothCraftFour setObjectAlliance:kAllianceFriendly];
                [self addTouchableObject:mothCraftFour withColliding:CRAFT_COLLISION_YESNO];
                [mothCraftFour release];
            }
        }
    }
    return self;
}

- (BOOL)checkObjective {
    return [mothTrigger isComplete];
}

@end