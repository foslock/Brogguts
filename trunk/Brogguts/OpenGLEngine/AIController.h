//
//  AIController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/6/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchableObject.h"

@class CraftObject;
@class BroggutScene;

enum kGlobalAIState { // These states are mutually exlusive, two can not exist at the same time
    kGlobalAIStateNeutral,          // When the AI is issuing no commands (ships will continue their business as usual)
    kGlobalAIStateMining,           // When the AI is focusing only on raising the broggut income rate
    kGlobalAIStatePreparingAttack,  // When the AI is preparing a squad of ships to attack the player with
    kGlobalAIStateAttacking,        // When the AI is commanding it's squad of ships to attack the player
    kGlobalAIStateDefending,        // When the AI is being attacked or taking a defensive strategy
};

enum kCraftAICommand {
    kCraftAICommandAttack,      // Craft will move and immediately target any other ships that enter their range, and follow them
    kCraftAICommandMove,        // Craft will move and attack anything they fly by, but will stay on their course
    kCraftAICommandMine,        // Craft will try to mine medium brogguts at the given location, will not move if not mining ships
};

typedef struct Craft_AI_Info {
    float computedAttackValue;    // The "rating" of the craft in terms of attack (range from 0.0f -> 1.0f)
    float computedDefendValue;    // " " defending the base (range from 0.0f -> 1.0f)
    int computedMiningValue;      // " " mining.  (range from 0 -> 1)
    float averageCraftValue;      // The average "value" of the craft (averaged from others, range from 0.0f -> 1.0f)
} CraftAIInfo;

typedef struct AI_State_Details {
    int globalAIstate;              // The state that will be enforced at the start of this goal
    float broggutIncomeRate;        // Target income of brogguts to complete this goal
    float totalAttackPower;         // Target total attack power of owned ships
    float totalDefendPower;         // Target total defense power of owned ships
    int totalNumberOfShips;         // Target number of total ships
    int totalNumberOfStructures;    // " " structures
} AIStateDetails;

#define AI_DETAILS_QUEUE_MAX_SIZE 100
#define AI_STEP_TIMER_INTERVALS 50

@interface AIController : NSObject {
    BroggutScene* myScene;          // The scene that is being controlled
    BOOL isPirateScene;             // BOOL, whether or not the AI has a base or not
    
	NSMutableArray* craftArray;     // Array of all the craft on the map (not just enemy craft)
    NSMutableArray* structureArray; // Array of all the structures on the map (not just enemy structures)
    
    NSMutableArray* selectedCraftArray; // Array of the currently selected craft
    
    int globalAIState;                  // The general state of the AI machine
    AIStateDetails currentAIDetails;    // The current details of the AI machine
    AIStateDetails* currentAIGoal;      // The current goal of the AI machine
    AIStateDetails detailsQueue[AI_DETAILS_QUEUE_MAX_SIZE];   // The queue holding all of the goals
    int detailsQueueIndex;
    int detailsQueueCount;
    
    CGPoint enemyBaseLocation;      // Main location of the base for the AI
    CGPoint friendlyBaseLocation;   // Main location for the base of the player
    
    int stepAITimer;                // Timer that runs the AI's commands
    
    int enemyBroggutCount;          // Broggut count for the enemy AI
    int enemyMetalCount;            // Metal count for the enemy AI
}

@property (nonatomic, assign) int enemyBroggutCount;
@property (nonatomic, assign) int enemyMetalCount;

// Init with an array of craft and structures
- (id)initWithTouchableObjects:(NSArray*)objects withPirate:(BOOL)pirate;

// Update the controller with the touchable objects from broggut scene 
- (void)updateArraysWithTouchableObjects:(NSArray*)array;

- (void)addBrogguts:(int)brogs;
- (void)addMetal:(int)metal;

// Returns NO if the current broggut count is too low to subtract the passed in brogguts and DOES NOT subtract them
- (BOOL)subtractBrogguts:(int)brogs metal:(int)metal;

// Returns a new craft info struct with the provided values
- (CraftAIInfo)craftInfoWithAttack:(float)attack withDefend:(float)defend withMining:(int)mining;

// Returns the nearest craft to the provided location that has at least all of the values in the craftInfo. Returns nil if none.
- (CraftObject*)craftNearestLocation:(CGPoint)location withThreshold:(CraftAIInfo)craftInfo isSelected:(BOOL)selected;

// Puts all the craft near the location, that have at least the provided craftInfo, into the selected array
- (void)selectAllCraftAtLocation:(CGPoint)location withThreshold:(CraftAIInfo)craftInfo;

// Commands all of the ships with the given commands to the passed in location
- (void)commandSelectedCraftWithCommand:(int)craftAICommand toLocation:(CGPoint)location;

// Computes the current details of the AI machine
- (void)computeCurrentAIDetails;

// Updates the controller, performing commands/goal operations
- (void)updateAIController;

// Removes the first goal in the queue and initiates the next one
- (void)popGoalOffQueue;

// Adds the goal to the details queue
- (void)pushGoalToQueue:(AIStateDetails)details;


@end
