//
//  TutorialSceneSix.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TutorialSceneSix.h"
#import "GameController.h"
#import "GameplayConstants.h"
#import "TriggerObject.h"
#import "CraftAndStructures.h"
#import "TextObject.h"
#import "UpgradeManager.h"

@implementation TutorialSceneSix

- (id)init {
    self = [super initWithTutorialIndex:5];
    if (self) {
        CGPoint blockLoc = CGPointMake(fullMapBounds.size.width * (3.0f / 4.0f) + (COLLISION_CELL_WIDTH / 2),
                                         fullMapBounds.size.height * (1.0f / 2.0f));
        CGPoint beetleLoc = CGPointMake((float)kPadScreenLandscapeWidth * (1.0f / 4.0f) - (COLLISION_CELL_WIDTH / 2),
                                     (float)kPadScreenLandscapeHeight * (1.0f / 2.0f));
        
        BlockStructureObject* block = [[BlockStructureObject alloc] initWithLocation:blockLoc isTraveling:NO];
        enemyBlock = block;
        [block setObjectAlliance:kAllianceEnemy];
        [self addTouchableObject:block withColliding:STRUCTURE_COLLISION_YESNO];
        [block release];
        
        NotificationObject* notiObj = [[NotificationObject alloc] initWithLocation:block.objectLocation withDuration:-1.0f];
        [notiObj attachToObject:block];
        [self addCollidableObject:notiObj];
        [notiObj release];
        
        BeetleCraftObject* newBeetle = [[BeetleCraftObject alloc] initWithLocation:beetleLoc isTraveling:NO];
        myCraft = newBeetle;
        [newBeetle setObjectAlliance:kAllianceFriendly];
        [self addTouchableObject:newBeetle withColliding:CRAFT_COLLISION_YESNO];
        [newBeetle release];
        
        [helpText setObjectText:@"All craft will automatically attack enemies within range. Select this Beetle craft and attack the enemy structure."];
        
        [fogManager clearAllFog];
    }
    return self;
}

- (BOOL)checkObjective {
    return (enemyBlock.destroyNow);
}

@end