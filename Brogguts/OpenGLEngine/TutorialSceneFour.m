//
//  TutorialSceneFour.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneFour.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"
#import "FingerObject.h"

@implementation TutorialSceneFour

- (void)dealloc {
    [antTrigger release];
    [super dealloc];
}

- (id)init {
    self = [super initWithTutorialIndex:3];
    if (self) {
        CGPoint triggerLoc = CGPointMake(fullMapBounds.size.width * (3.0f / 4.0f) + (COLLISION_CELL_WIDTH / 2),
                                         fullMapBounds.size.height * (1.0f / 2.0f));
        CGPoint antLoc = CGPointMake((float)kPadScreenLandscapeWidth * (1.0f / 4.0f) - (COLLISION_CELL_WIDTH / 2),
                                     (float)kPadScreenLandscapeHeight * (1.0f / 2.0f));
        antTrigger = [[TriggerObject alloc] initWithLocation:triggerLoc];
        antTrigger.numberOfObjectsNeeded = 1;
        antTrigger.objectIDNeeded = kObjectCraftAntID;
        notification = [[NotificationObject alloc] initWithLocation:antTrigger.objectLocation withDuration:-1.0f];
        [self addCollidableObject:notification];
        [notification release];
        AntCraftObject* newAnt = [[AntCraftObject alloc] initWithLocation:antLoc isTraveling:NO];
        myCraft = newAnt;
        [newAnt setObjectAlliance:kAllianceFriendly];
        [self addTouchableObject:newAnt withColliding:CRAFT_COLLISION_YESNO];
        [self addTouchableObject:antTrigger withColliding:NO];        
        [newAnt release];
        
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
        
        FingerObject* tempFingerThree = [[FingerObject alloc] initWithStartLocation:notification.objectLocation withEndLocation:notification.objectLocation repeats:YES];
        fingerThree = tempFingerThree;
        [self addCollidableObject:tempFingerThree];
        [tempFingerThree release];
        
        [helpText setObjectText:@"The screen will only scroll for selected ships. Select this one using two fingers and move it towards the right."];
    }
    return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
    [fingerThree setEndLocation:notification.objectLocation];
    [fingerThree setStartLocation:notification.objectLocation];
    [fingerThree setObjectLocation:notification.objectLocation];
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
    return ([antTrigger isComplete]);
}

@end