//
//  CraftObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ControllableObject.h"

#define LIGHT_BLINK_FREQUENCY 200	 // Number of steps between the light's flashes
#define LIGHT_BLINK_BRIGHTNESS 0.8f	 // Brightness that the lights blink at
#define LIGHT_BLINK_FADE_SPEED 0.05f // Rate at which the blinking light fades out

@class MonarchCraftObject;
@class Image;

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
	
	// Special Ability vars
	BOOL isSpecialAbilityCooling;
	BOOL isSpecialAbilityActive;
	int specialAbilityCooldownTimer;
	
	// Monarch that leads the squad (nil if not in a squad)
	MonarchCraftObject* squadMonarch;
	
	// Turrets and blinking lights
	Image* blinkingLightImage;
	NSArray* turretPointsArray;
	NSArray* lightPointsArray;
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
}

@property (readonly) int attributePlayerCargoCapacity;

- (id)initWithTypeID:(int)typeID withLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)addCargo:(int)cargo;

// Called when the target is in range and the cooling systems are ready
- (void)attackTarget;

- (void)setPriorityEnemyTarget:(TouchableObject*)target;

- (BOOL)performSpecialAbilityAtLocation:(CGPoint)location; // Returns YES if the ability was performed

- (void)cashInBrogguts;

- (void)updateCraftLightLocations;
- (void)updateCraftTurretLocations;

- (void)followPath:(NSArray*)array isLooped:(BOOL)looped;
- (void)stopFollowingCurrentPath;
- (void)resumeFollowingCurrentPath;

@end
