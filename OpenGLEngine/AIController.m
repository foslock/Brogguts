//
//  AIController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "AIController.h"
#import "GameplayConstants.h"
#import "Global.h"
#import "CraftObject.h"
#import "BroggutScene.h"
#import "CollisionManager.h"
#import "CraftAndStructures.h"
#import "GameController.h"
#import "Image.h"
#import "CraftObject.h"

@implementation AIController
@synthesize enemyBroggutCount, enemyMetalCount, isPirateScene;

- (void)dealloc {
    [craftArray release];
    [structureArray release];
    [pirateCraft release];
    [super dealloc];
}

- (id)initWithScene:(BroggutScene*)scene withPirate:(BOOL)pirate {
    self = [super init];
    if (self) {
        myScene = scene;
        isPirateScene = pirate;
        craftArray = [[NSMutableArray alloc] init];
        structureArray = [[NSMutableArray alloc] init];
        pirateCraft = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [scene.touchableObjects count]; i++) {
            TouchableObject* obj = [scene.touchableObjects objectAtIndex:i];
            if ([obj isKindOfClass:[CraftObject class]]) {
                [craftArray addObject:obj];
            }
            if ([obj isKindOfClass:[StructureObject class]]) {
                [structureArray addObject:obj];
            }
        }
        
        globalAIState = kGlobalAIStateNeutral;
        currentAIDetails.globalAIstate = globalAIState;
        currentAIDetails.broggutIncomeRate = 0.0f;
        currentAIDetails.totalAttackPower = 0.0f;
        currentAIDetails.totalDefendPower = 0.0f;
        currentAIDetails.totalNumberOfShips = 0;
        currentAIDetails.totalNumberOfStructures = 0;
        detailsQueueIndex = AI_DETAILS_QUEUE_MAX_SIZE - 1;
        detailsQueueCount = 0;
        enemyBroggutCount = 0;
        enemyMetalCount = 0;
        stepAITimer = AI_STEP_TIMER_INTERVALS;
        
        AIStateDetails newGoal;
        newGoal.broggutIncomeRate = 100.0f;
        newGoal.totalAttackPower = 10.0f;
        newGoal.totalDefendPower = 10.0f;
        newGoal.totalNumberOfShips = 20;
        newGoal.totalNumberOfStructures = 0;
        [self pushGoalToQueue:newGoal];
        currentAIGoal = &newGoal;
    }
    return self;
}

- (void)updateArraysWithTouchableObjects:(NSArray*)array {
    [craftArray removeAllObjects];
    [structureArray removeAllObjects];
    for (int i = 0; i < [array count]; i++) {
        TouchableObject* obj = [array objectAtIndex:i];
        if ([obj isKindOfClass:[CraftObject class]]) {
            [craftArray addObject:obj];
        }
        if ([obj isKindOfClass:[StructureObject class]]) {
            [structureArray addObject:obj];
        }
    }
}

- (void)removeObjectsInArray:(NSArray*)array {
    for (CraftObject* craft in array) {
        [craftArray removeObject:craft];
    }
    
    for (StructureObject* structure in array) {
        [structureArray removeObject:structure];
    }
}

- (void)addBrogguts:(int)brogs {
	enemyBroggutCount += brogs;
}

- (void)addMetal:(int)metal {
	enemyMetalCount += metal;
}

- (BOOL)subtractBrogguts:(int)brogs metal:(int)metal {
	if (brogs > enemyBroggutCount || metal > enemyMetalCount) {
		return NO;
	} else {
		enemyMetalCount -= metal;
		enemyBroggutCount -= brogs;
		return YES;
	}	
}

// Returns a new craft info struct with the provided values
- (CraftAIInfo)craftInfoWithAttack:(float)attack withDefend:(float)defend withMining:(int)mining {
    CraftAIInfo newInfo;
    newInfo.computedAttackValue = attack;
    newInfo.computedDefendValue = defend;
    newInfo.averageCraftValue = (attack + defend) / 2.0f;
    newInfo.computedMiningValue = mining;
    return newInfo;
}

// Returns the nearest craft to the provided location that has at least all of the values in the craftInfo. Returns nil if none.
- (CraftObject*)craftNearestLocation:(CGPoint)location withThreshold:(CraftAIInfo)craftInfo isSelected:(BOOL)selected {
    // Search through craft array
    CraftObject* closestCraft = nil;
    float minDistance = INT_MAX;
    for (int i = 0; i < [craftArray count]; i++) {
        CraftObject* thisCraft = [craftArray objectAtIndex:i];
        if (thisCraft.objectAlliance == kAllianceFriendly) continue;
        
        [thisCraft calculateCraftAIInfo];
        if (thisCraft.craftAIInfo.computedAttackValue < craftInfo.computedAttackValue) continue;
        if (thisCraft.craftAIInfo.computedDefendValue < craftInfo.computedDefendValue) continue;
        if (thisCraft.craftAIInfo.computedMiningValue != craftInfo.computedMiningValue) continue;
        if (!selected)
            if ([craftArray containsObject:thisCraft]) continue;
        if (selected)
            if (![craftArray containsObject:thisCraft]) continue;
        
        float dist = GetDistanceBetweenPoints(location, thisCraft.objectLocation);
        if (dist < minDistance) {
            closestCraft = thisCraft;
            minDistance = dist;
        }
    }
    return closestCraft;
}

// Puts all the craft near the location, that have at least the provided craftInfo, into the selected array
- (void)selectAllCraftAtLocation:(CGPoint)location withThreshold:(CraftAIInfo)craftInfo {
    float distanceThreshold = sqrtf(kPadScreenLandscapeHeight * kPadScreenLandscapeHeight +
                                    kPadScreenLandscapeWidth * kPadScreenLandscapeWidth) / 2.0f;
    [selectedCraftArray removeAllObjects];
    for (int i = 0; i < [craftArray count]; i++) {
        CraftObject* thisCraft = [craftArray objectAtIndex:i];
        if (thisCraft.objectAlliance == kAllianceFriendly) continue;
        
        [thisCraft calculateCraftAIInfo];
        if (thisCraft.craftAIInfo.computedAttackValue < craftInfo.computedAttackValue) continue;
        if (thisCraft.craftAIInfo.computedDefendValue < craftInfo.computedDefendValue) continue;
        if (thisCraft.craftAIInfo.computedMiningValue != craftInfo.computedMiningValue) continue;
        if ([craftArray containsObject:thisCraft]) {
            float dist = GetDistanceBetweenPoints(location, thisCraft.objectLocation);
            if (dist <= distanceThreshold) {
                [selectedCraftArray addObject:thisCraft];
            }
        }
    }
    
}

// Commands all of the ships with the given commands to the passed in location
- (void)commandSelectedCraftWithCommand:(int)craftAICommand toLocation:(CGPoint)location {
    for (CraftObject* craft in selectedCraftArray) {
        if (craft.objectAlliance == kAllianceFriendly) continue;
        switch (craftAICommand) {
            case kCraftAICommandAttack: {
                NSArray* path = [[myScene collisionManager] pathFrom:craft.objectLocation to:location allowPartial:NO isStraight:NO];
                [craft followPath:path isLooped:NO];
                if ([craft isKindOfClass:[AntCraftObject class]]) {
                    AntCraftObject* thisAnt = (AntCraftObject*)craft;
                    currentAIDetails.broggutIncomeRate -= thisAnt.miningAIValue;
                } else if ([craft isKindOfClass:[CamelCraftObject class]]) {
                    CamelCraftObject* thisCamel = (CamelCraftObject*)craft;
                    currentAIDetails.broggutIncomeRate -= thisCamel.miningAIValue;
                } 
            }
                break;
            case kCraftAICommandMove: {
                NSArray* path = [[myScene collisionManager] pathFrom:craft.objectLocation to:location allowPartial:NO isStraight:NO];
                [craft followPath:path isLooped:NO];
                if ([craft isKindOfClass:[AntCraftObject class]]) {
                    AntCraftObject* thisAnt = (AntCraftObject*)craft;
                    currentAIDetails.broggutIncomeRate -= thisAnt.miningAIValue;
                } else if ([craft isKindOfClass:[CamelCraftObject class]]) {
                    CamelCraftObject* thisCamel = (CamelCraftObject*)craft;
                    currentAIDetails.broggutIncomeRate -= thisCamel.miningAIValue;
                }
            }
                break;
            case kCraftAICommandMine: { // Deselects craft is successfully started mining
                if ([craft isKindOfClass:[AntCraftObject class]]) {
                    AntCraftObject* thisAnt = (AntCraftObject*)craft;
                    [thisAnt tryMiningBroggutsWithCenter:location wasCommanded:NO];
                    float dist = GetDistanceBetweenPoints(thisAnt.objectLocation, location);
                    currentAIDetails.broggutIncomeRate += (kCraftAntEngines / (float)kCraftAntMiningCooldown) / dist;
                    thisAnt.miningAIValue = (kCraftAntEngines / (float)kCraftAntMiningCooldown) / dist;
                } else if ([craft isKindOfClass:[CamelCraftObject class]]) {
                    CamelCraftObject* thisCamel = (CamelCraftObject*)craft;
                    [thisCamel tryMiningBroggutsWithCenter:location wasCommanded:NO];
                    float dist = GetDistanceBetweenPoints(thisCamel.objectLocation, location);
                    currentAIDetails.broggutIncomeRate += (kCraftCamelEngines / (float)kCraftCamelMiningCooldown) / dist;
                    thisCamel.miningAIValue = (kCraftCamelEngines / (float)kCraftCamelMiningCooldown) / dist;
                }
            }
                break;
            default:
                NSLog(@"Invalid command ID provided (%i)", craftAICommand);
                break;
        }
    }
}

- (void)computeCurrentAIDetails {
    currentAIDetails.globalAIstate = globalAIState;
    
    // Zero all calculated values
    currentAIDetails.totalAttackPower = 0.0f;
    currentAIDetails.totalDefendPower = 0.0f;
    currentAIDetails.totalNumberOfShips = 0;
    currentAIDetails.totalNumberOfStructures = 0;
    
    for (CraftObject* craft in craftArray) {
        if (craft.objectAlliance == kAllianceEnemy) {
            [craft calculateCraftAIInfo];
            currentAIDetails.totalAttackPower += craft.craftAIInfo.computedAttackValue;
            currentAIDetails.totalDefendPower += craft.craftAIInfo.computedDefendValue;
            currentAIDetails.totalNumberOfShips++;
        }
    }
    for (StructureObject* structure in structureArray) {
        if (structure.objectAlliance == kAllianceEnemy) {
            currentAIDetails.totalNumberOfStructures++;
        }
    }
}

// Updates the controller, performing commands/goal operations
- (void)updateAIController {    
    // Only run the update once the timer hits
    if (stepAITimer <= 0) {
        // NSLog(@"AI is updated");
        stepAITimer = AI_STEP_TIMER_INTERVALS;
        
        // Update pirate craft array
        if (isPirateScene && myScene) {
            [pirateCraft removeAllObjects];
            for (int i = 0; i < [myScene.touchableObjects count]; i++) {
                TouchableObject* obj = [myScene.touchableObjects objectAtIndex:i];
                if ([obj isKindOfClass:[CraftObject class]]) {
                    CraftObject* craft = (CraftObject*)obj;
                    if ([craft isKindOfClass:[SpiderCraftObject class]]) {
                        continue;
                    }
                    if (craft.objectAlliance == kAllianceEnemy) {
                        if (craft.attackingAIState == kAttackingAIStateNeutral &&
                            craft.movingAIState != kMovingAIStateMining) {
                            [pirateCraft addObject:craft];
                        }
                    }
                }
            }
            
            if ([pirateCraft count] != 0) {
                // Get the three bands of player's structure's
                // Go through each band and attack the farthest structure
                // Split into two groups on the outermost band
                int bandCount = 4;
                NSMutableArray* bands = [NSMutableArray arrayWithCapacity:bandCount];
                for (int i = 0; i < bandCount; i++) {
                    NSMutableArray* band = [NSMutableArray array];
                    [bands addObject:band];
                }
                int bandWidthMax = MAX(myScene.fullMapBounds.size.width * (3.0f / 4.0f),
                                       myScene.fullMapBounds.size.height * (3.0f / 4.0f));
                int bandWidth = bandWidthMax / bandCount;
                
                // Make the bands
                int totalStructureCount = 0;
                for (int b = 0; b < bandCount; b++) { // start at inner/first band
                    NSMutableArray* band = [bands objectAtIndex:b];
                    for (int s = 0; s < [myScene.touchableObjects count]; s++) {
                        TouchableObject* obj = [myScene.touchableObjects objectAtIndex:s];
                        if ([obj isKindOfClass:[StructureObject class]]) {
                            StructureObject* structure = (StructureObject*)obj;
                            if (structure.objectAlliance == kAllianceFriendly) {
                                int thisDist = GetDistanceBetweenPoints(structure.objectLocation, myScene.homeBaseLocation);
                                if (b == thisDist / bandWidth) {
                                    [band addObject:structure];
                                    totalStructureCount++;
                                }
                            }
                        }
                    }
                }
                
                NSMutableArray* structureTargets = [NSMutableArray arrayWithCapacity:bandCount];
                if (totalStructureCount > 0) {
                    // Contains structures that should be attacked
                    int currentBandIndex = 0;
                    for (int i = 0; i < bandCount; i++){
                        int bandIndex = (bandCount - 1) - i;
                        
                        NSMutableArray* band = [bands objectAtIndex:bandIndex];
                        int structureCount = [band count];
                        if (structureCount != 0) {
                            currentBandIndex = bandIndex;
                            int numberToAdd = CLAMP(bandIndex + 1, 0, structureCount);
                            for (int j = 0; j < numberToAdd; j++) {
                                [structureTargets addObject:[band objectAtIndex:j]];
                            }
                            break; // Only attack this first structure
                        }
                    }
                } else {
                    // No structures in the current bands, so just attack a random building.
                    for (int s = 0; s < [myScene.touchableObjects count]; s++) {
                        TouchableObject* obj = [myScene.touchableObjects objectAtIndex:s];
                        if ([obj isKindOfClass:[StructureObject class]]) {
                            StructureObject* structure = (StructureObject*)obj;
                            if (structure.objectAlliance == kAllianceFriendly && !structure.destroyNow) {
                                [structureTargets addObject:structure];
                                break;
                            }
                        }
                    }
                }
                
                if ([structureTargets count] > 0) {
                    int bandCounter = 0;
                    for (int i = 0; i < [pirateCraft count]; i++) {
                        CraftObject* craft = [pirateCraft objectAtIndex:i];
                        StructureObject* targetS = [structureTargets objectAtIndex:bandCounter];
                        bandCounter++;
                        if (bandCounter >= [structureTargets count]) {
                            bandCounter = 0;
                        }
                        int structSize = CLAMP(targetS.objectImage.imageSize.width * (3.0f / 4.0f), 1, craft.attributeAttackRange);
                        CGPoint targetPoint = CGPointMake(targetS.objectLocation.x - (structSize / 2) + (arc4random() % structSize),
                                                          targetS.objectLocation.y - (structSize / 2) + (arc4random() % structSize));
                        NSArray* path = [myScene.collisionManager pathFrom:craft.objectLocation to:targetPoint allowPartial:YES isStraight:YES];
                        [craft followPath:path isLooped:NO];
                    }
                }
            }
        }
        
        /*
         // Update current state details
         [self computeCurrentAIDetails];
         
         // Check if current details meet the current goal
         if (currentAIDetails.broggutIncomeRate >= currentAIGoal->broggutIncomeRate &&
         currentAIDetails.totalAttackPower >= currentAIGoal->totalAttackPower &&
         currentAIDetails.totalDefendPower >= currentAIGoal->totalDefendPower &&
         currentAIDetails.totalNumberOfShips >= currentAIGoal->totalNumberOfShips &&
         currentAIDetails.totalNumberOfStructures >= currentAIGoal->totalNumberOfStructures) {
         [self popGoalOffQueue];
         }
         
         if (globalAIState != kGlobalAIStateAttacking &&
         globalAIState != kGlobalAIStateDefending) {
         // Check the broggut rate
         if (currentAIDetails.broggutIncomeRate < currentAIGoal->broggutIncomeRate) {
         // Do something to raise the broggut income rate
         
         return;
         }
         
         // Check the attack power
         if (currentAIDetails.totalAttackPower < currentAIGoal->totalAttackPower) {
         
         return;
         }
         
         // Check the defense power
         if (currentAIDetails.totalDefendPower < currentAIGoal->totalDefendPower) {
         
         return;
         }
         
         // Check the total number of ships
         if (currentAIDetails.totalNumberOfShips < currentAIGoal->totalNumberOfShips) {
         
         return;
         }
         
         // Check the total number of structures
         if (currentAIDetails.totalNumberOfStructures < currentAIGoal->totalNumberOfStructures) {
         
         return;
         }
         } else {
         if (globalAIState == kGlobalAIStateAttacking) {
         // Command ships under an ATTACKING state
         
         } else if (globalAIState == kGlobalAIStateDefending) {
         // Command ships under a DEFENDING state
         
         }
         }
         */
        
    } else {
        stepAITimer--;
    }
}

// Removes the first goal in the queue and initiates the next one
- (void)popGoalOffQueue {
    if (detailsQueueCount > 0 && detailsQueueIndex > 0) {
        currentAIGoal = &detailsQueue[detailsQueueIndex];
        detailsQueueIndex--;
    }
}

// Adds the goal to the details queue
- (void)pushGoalToQueue:(AIStateDetails)details {
    if (detailsQueueCount < (AI_DETAILS_QUEUE_MAX_SIZE - 1) ) {
        int index = (AI_DETAILS_QUEUE_MAX_SIZE - 1) - detailsQueueCount;
        detailsQueue[index] = details;
        detailsQueueCount++;
    }
}


@end
