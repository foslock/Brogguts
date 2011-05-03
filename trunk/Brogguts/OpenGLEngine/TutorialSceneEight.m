//
//  TutorialSceneEight.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneEight.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"

@implementation TutorialSceneEight

- (id)init {
    self = [super initWithTutorialIndex:7];
    if (self) {
        CGPoint enemyLocOne = CGPointMake(fullMapBounds.size.width * (3.0f / 4.0f) + (COLLISION_CELL_WIDTH / 2),
                                       fullMapBounds.size.height * (1.0f / 2.0f) + (COLLISION_CELL_HEIGHT / 2));
        
        CGPoint enemyLocTwo = CGPointMake(fullMapBounds.size.width * (3.0f / 4.0f) + (COLLISION_CELL_WIDTH / 2),
                                       fullMapBounds.size.height * (1.0f / 2.0f) - (COLLISION_CELL_HEIGHT / 2));
        
        CGPoint beetleLoc = CGPointMake(fullMapBounds.size.width * (1.0f / 4.0f) - (COLLISION_CELL_WIDTH / 2),
                                     fullMapBounds.size.height * (1.0f / 2.0f));
        
        BeetleCraftObject* enemyBeetleOne = [[BeetleCraftObject alloc] initWithLocation:enemyLocOne isTraveling:NO];
        enemyCraftOne = enemyBeetleOne;
        [enemyBeetleOne setObjectAlliance:kAllianceEnemy];
        [self addTouchableObject:enemyBeetleOne withColliding:STRUCTURE_COLLISION_YESNO];
        [enemyBeetleOne release];
        
        BeetleCraftObject* enemyBeetleTwo = [[BeetleCraftObject alloc] initWithLocation:enemyLocTwo isTraveling:NO];
        enemyCraftTwo = enemyBeetleTwo;
        [enemyBeetleTwo setObjectAlliance:kAllianceEnemy];
        [self addTouchableObject:enemyBeetleTwo withColliding:STRUCTURE_COLLISION_YESNO];
        [enemyBeetleTwo release];
        
        NotificationObject* notiObj = [[NotificationObject alloc] initWithLocation:enemyBeetleOne.objectLocation withDuration:-1.0f];
        [notiObj attachToObject:enemyBeetleOne];
        [self addCollidableObject:notiObj];
        [notiObj release];
        
        BeetleCraftObject* newBeetle = [[BeetleCraftObject alloc] initWithLocation:beetleLoc isTraveling:NO];
        myCraft = newBeetle;
        [newBeetle setObjectAlliance:kAllianceFriendly];
        [self setCameraLocation:newBeetle.objectLocation];
        [self setMiddleOfVisibleScreenToCamera];
        [self addTouchableObject:newBeetle withColliding:CRAFT_COLLISION_YESNO];
        [newBeetle release];
        
        [helpText setObjectText:@"If there are enough enemy craft nearby, they will gang up on you and chase you instead. Attack these two enemy Beetles."];
    }
    return self;
}

- (BOOL)checkObjective {
    return (myCraft.destroyNow);
}

@end