//
//  CraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ControllableObject.h"
#import "AIController.h"

#define CRAFT_ATTACK_MOVING_TIME 50  // Frames between a craft moving to attack its target
#define CRAFT_HEALTH_PER_NOTCH 4
#define CRAFT_ALLIANCE_TINT_AMOUNT 0.15f

@class MonarchCraftObject;
@class Image;

typedef struct Point_Location {
    float x;
    float y;
} PointLocation;

typedef struct Point_Array {
    PointLocation* locations;
    int pointCount;
} PointArray;

@interface CraftObject : ControllableObject {
	// Path variables
	NSMutableArray* pathPointArray;		// Array containing the points that this craft should follow
	int pathPointNumber;				// Which index of the path array we should be accelerating towards
	BOOL isFollowingPath;				// True if the craft should follow its current path (if any)
	BOOL isPathLooped;					// Should the unit repeat the path when finished
	BOOL hasCurrentPathFinished;		// True if the previous given path is done
	
	// Attacking vars
	int attackCooldownTimer;
	CGPoint attackLaserTargetPosition;
    int attackMovingCooldownTimer;
	
	// Special Ability vars
	BOOL isSpecialAbilityCooling;
	BOOL isSpecialAbilityActive;
	int specialAbilityCooldownTimer;
	
	// If there is a monarch nearby that is making them resistent
    BOOL isUnderAura;
    Image* craftSheild;
    BOOL isShowingSheild;
    float sheildTimer;
	
	// Turrets and blinking lights
	Image* blinkingLightImage;
    Image* turretImage;
    float turretRotation;
	PointArray* turretPointsArray;
	PointArray* lightPointsArray;
	int lightBlinkTimer;
	float lightBlinkAlpha;
	
	// Variable attributes that all craft must implement
	int attributeBroggutCost;
	int attributeMetalCost;
	int attributeEngines;
	int attributeWeaponsDamage;
	int attributeAttackRange;
	int attributeAttackCooldown;
	int attributeSpecialCooldown;
	int attributeHullCapacity;
	int attributeHullCurrent;
	
	// Player cargo capacity
	int attributePlayerCurrentCargo;
	int attributePlayerCargoCapacity;
    
    // AI Controller stuff
    CraftAIInfo craftAIInfo;
    
    // Upgrade details
    BOOL isUpgradeEnabled;
    
    // If the dirty image is being shown
    BOOL isDirtyImage;
    BOOL craftDoesRotate;
}

@property (readonly) BOOL isFollowingPath;
@property (readonly) CraftAIInfo craftAIInfo;
@property (readonly) int attributePlayerCargoCapacity;
@property (readonly) int attributePlayerCurrentCargo;
@property (readonly) int attributeHullCurrent;
@property (readonly) int attributeHullCapacity;
@property (readonly) BOOL isUnderAura;
@property (readonly) BOOL craftDoesRotate;

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling;
- (void)createLightLocationsWithCount:(int)lightCount;
- (void)createTurretLocationsWithCount:(int)turretCount;

- (void)addCargo:(int)cargo;
- (CGPoint)miningLocation;

- (void)calculateCraftAIInfo;

// Called when the target is in range and the cooling systems are ready
- (void)attackTarget;

// Called when this craft is being repaired
- (void)repairCraft:(int)amount;
- (BOOL)isHullFull;
- (void)showCraftSheild;

// Use this to change the hull value
- (void)setCurrentHull:(int)newHull;

- (void)setIsUnderAura:(BOOL)yesno;

- (void)setPriorityEnemyTarget:(TouchableObject*)target;

- (BOOL)performSpecialAbilityAtLocation:(CGPoint)location; // Returns YES if the ability was performed

- (void)cashInBrogguts;

- (void)updateCraftLightLocations;
- (void)updateCraftTurretLocations;

- (void)followPath:(NSArray*)array isLooped:(BOOL)looped;
- (NSArray*)getSavablePath;
- (void)stopFollowingCurrentPath;
- (void)resumeFollowingCurrentPath;

@end
