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

@implementation AIController
@synthesize enemyBroggutCount, enemyMetalCount;

- (void)dealloc {
    [craftArray release];
    [structureArray release];
    [super dealloc];
}

- (id)initWithTouchableObjects:(NSArray*)objects withPirate:(BOOL)pirate{
    self = [super init];
    if (self) {
        myScene = [[GameController sharedGameController] currentScene];
        isPirateScene = pirate;
        craftArray = [[NSMutableArray alloc] init];
        structureArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [objects count]; i++) {
            TouchableObject* obj = [objects objectAtIndex:i];
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
        // UPDATE THE AI
        
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
