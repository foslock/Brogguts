//
//  TutorialSceneTwo.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneTwo.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "FingerObject.h"
#import "TextObject.h"
#import "TiledButtonObject.h"

@implementation TutorialSceneTwo

- (id)init {
    self = [super initWithTutorialIndex:1];
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
        [self addTouchableObject:antTrigger withColliding:NO];
        [newAnt release];
        
        FingerObject* fingerObj = [[FingerObject alloc] initWithStartLocation:antLoc withEndLocation:triggerLoc repeats:YES];
        finger = fingerObj;
        [fingerObj attachStartObject:newAnt];
        [fingerObj attachEndObject:antTrigger];
        [self addCollidableObject:fingerObj];
        [fingerObj release];
        
        [helpText setObjectText:@"To command an individual craft: tap, drag, release and it will travel to that location."];
        
        [fogManager clearAllFog];
    }
    return self;
}

- (BOOL)checkObjective {
    return [antTrigger isComplete];
}

- (void)updateSceneWithDelta:(float)aDelta {
    if (myCraft.isFollowingPath) {
        finger.isHidden = YES;
    }
    [super updateSceneWithDelta:aDelta];
}                                                                                   

@end