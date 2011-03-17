//
//  TutorialSceneThree.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneThree.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"

@implementation TutorialSceneThree

- (id)init {
    self = [super initWithTutorialIndex:2];
    if (self) {
        CGPoint triggerLoc = CGPointMake((float)kPadScreenLandscapeWidth * (3.0f / 4.0f) + (COLLISION_CELL_WIDTH / 2),
                                         (float)kPadScreenLandscapeHeight * (3.0f / 4.0f));
        CGPoint antLoc = CGPointMake((float)kPadScreenLandscapeWidth * (1.0f / 4.0f) - (COLLISION_CELL_WIDTH / 2),
                                     (float)kPadScreenLandscapeHeight * (1.0f / 4.0f));
        antTrigger = [[TriggerObject alloc] initWithLocation:triggerLoc];
        antTrigger.numberOfObjectsNeeded = 1;
        antTrigger.objectIDNeeded = kObjectCraftAntID;
        AntCraftObject* newAnt = [[AntCraftObject alloc] initWithLocation:antLoc isTraveling:NO];
        myCraft = newAnt;
        [newAnt setObjectAlliance:kAllianceFriendly];
        [self addTouchableObject:newAnt withColliding:CRAFT_COLLISION_YESNO];
        [self addCollidableObject:antTrigger];
    }
    return self;
}

- (BOOL)checkObjective {
    return ([antTrigger isComplete] && myCraft.isBeingControlled);
}

@end
