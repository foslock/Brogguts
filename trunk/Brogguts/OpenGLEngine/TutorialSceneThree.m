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
#import "FingerObject.h"
#import "TextObject.h"

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
        [self addTouchableObject:antTrigger withColliding:NO];        
        
        FingerObject* tempFingerOne = [[FingerObject alloc] initWithStartLocation:CGPointMake(myCraft.objectLocation.x - COLLISION_CELL_WIDTH,
                                                                                              myCraft.objectLocation.y - COLLISION_CELL_HEIGHT)
                                                                  withEndLocation:CGPointMake(myCraft.objectLocation.x + COLLISION_CELL_WIDTH,
                                                                                              myCraft.objectLocation.y - COLLISION_CELL_HEIGHT)
                                                                          repeats:YES];
        fingerOne = tempFingerOne;
        [self addCollidableObject:tempFingerOne];
        [tempFingerOne release];
        
        FingerObject* tempFingerTwo = [[FingerObject alloc] initWithStartLocation:CGPointMake(myCraft.objectLocation.x - COLLISION_CELL_WIDTH,
                                                                                              myCraft.objectLocation.y + COLLISION_CELL_HEIGHT)
                                                                  withEndLocation:CGPointMake(myCraft.objectLocation.x + COLLISION_CELL_WIDTH,
                                                                                              myCraft.objectLocation.y + COLLISION_CELL_HEIGHT)
                                                                          repeats:YES];
        fingerTwo = tempFingerTwo;
        [self addCollidableObject:tempFingerTwo];
        [tempFingerTwo release];
        
        FingerObject* tempFingerThree = [[FingerObject alloc] initWithStartLocation:antTrigger.objectLocation withEndLocation:antTrigger.objectLocation repeats:YES];
        fingerThree = tempFingerThree;
        [self addCollidableObject:tempFingerThree];
        [tempFingerThree release];
        
        [helpText setObjectText:@"If you want to select a ship (or more) tap with two fingers and make any shape containing those ships. Selected ships will move towards a held touch."];
        
        [fogManager clearAllFog];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    if (!myCraft.isBeingControlled) {
        [fingerOne setStartLocation:CGPointMake(myCraft.objectLocation.x - COLLISION_CELL_WIDTH,
                                                myCraft.objectLocation.y - COLLISION_CELL_HEIGHT)];
        [fingerTwo setStartLocation:CGPointMake(myCraft.objectLocation.x - COLLISION_CELL_WIDTH,
                                                myCraft.objectLocation.y + COLLISION_CELL_HEIGHT)];
        [fingerOne setEndLocation:CGPointMake(myCraft.objectLocation.x + COLLISION_CELL_WIDTH,
                                              myCraft.objectLocation.y - COLLISION_CELL_HEIGHT)];
        [fingerTwo setEndLocation:CGPointMake(myCraft.objectLocation.x + COLLISION_CELL_WIDTH,
                                              myCraft.objectLocation.y + COLLISION_CELL_HEIGHT)];
        fingerOne.isHidden = NO;
        fingerTwo.isHidden = NO;
        fingerThree.isHidden = YES;
    } else {
        fingerThree.isHidden = NO;
        fingerOne.isHidden = YES;
        fingerTwo.isHidden = YES;
    }
    [super updateSceneWithDelta:aDelta];
}

- (BOOL)checkObjective {
    return ([antTrigger isComplete] && myCraft.isBeingControlled);
}

@end
