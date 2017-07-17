//
//  TutorialSceneSeven.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneSeven.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"

@implementation TutorialSceneSeven

- (id)init {
    self = [super initWithTutorialIndex:6];
    if (self) {
        CGPoint enemyLoc = CGPointMake(fullMapBounds.size.width * (3.0f / 4.0f) + (COLLISION_CELL_WIDTH / 2),
                                       fullMapBounds.size.height * (1.0f / 2.0f));
        CGPoint beetleLoc = CGPointMake((float)kPadScreenLandscapeWidth * (1.0f / 4.0f) - (COLLISION_CELL_WIDTH / 2),
                                     (float)kPadScreenLandscapeHeight * (1.0f / 2.0f));
        
        AntCraftObject* enemyAnt = [[AntCraftObject alloc] initWithLocation:enemyLoc isTraveling:NO];
        enemyCraft = enemyAnt;
        [enemyAnt setObjectAlliance:kAllianceEnemy];
        [self addTouchableObject:enemyAnt withColliding:CRAFT_COLLISION_YESNO];
        [enemyAnt release];
        
        NotificationObject* notiObj = [[NotificationObject alloc] initWithLocation:enemyAnt.objectLocation withDuration:-1.0f];
        [notiObj attachToObject:enemyAnt];
        [self addCollidableObject:notiObj];
        [notiObj release];
        
        BeetleCraftObject* newBeetle = [[BeetleCraftObject alloc] initWithLocation:beetleLoc isTraveling:NO];
        myCraft = newBeetle;
        [newBeetle setObjectAlliance:kAllianceFriendly];
        [self addTouchableObject:newBeetle withColliding:CRAFT_COLLISION_YESNO];
        [newBeetle release];
        
        [helpText setObjectText:@"A weaker enemy craft will try to escape if it is attacked. Kill the enemy Ant."];
        
        [fogManager clearAllFog];
    }
    return self;
}

- (BOOL)checkObjective {
    return (enemyCraft.destroyNow && !doesExplosionExist);
}

@end