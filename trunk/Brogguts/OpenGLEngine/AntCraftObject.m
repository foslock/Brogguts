//
//  AntCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/16/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "AntCraftObject.h"
#import "CollisionManager.h"
#import "BroggutScene.h"
#import "BroggutObject.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "ParticleSingleton.h"
#import "Image.h"
#import "SoundSingleton.h"
#import "UpgradeManager.h"

enum MiningStates {
	kMiningStateMining,
	kMiningStateApproaching,
	kMiningStateReturning,
	kMiningStateNone,
};

@implementation AntCraftObject
@synthesize miningLocation, miningAIValue;

- (void)dealloc {
	[super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftAntID withLocation:location isTraveling:traveling];
	if (self) {
        [self createLightLocationsWithCount:1];
        [self createTurretLocationsWithCount:1];
		attributePlayerCargoCapacity = kCraftAntCargoSpace;
		attributePlayerCurrentCargo = 0;
		attributeMiningCooldown = kCraftAntMiningCooldown;
        miningCooldownTimer = 0;
		miningState = kMiningStateNone;
        miningAIValue = 0.0f;
        [objectImage setScale:Scale2fMake(0.5f, 0.5f)];
	}
	return self;
}

- (CGPoint)miningLocation {
	return miningLocation;
}

- (void)tryMiningBroggutsWithCenter:(CGPoint)location wasCommanded:(BOOL)commanded {
	if (attributePlayerCurrentCargo >= attributePlayerCargoCapacity) {
		[self returnBroggutsHome];
		miningLocation = location;
		return;
	}
    NSMutableArray* pointArray = [[NSMutableArray alloc] initWithCapacity:9];
	if (![self startMiningBroggutWithLocation:location wasCommanded:commanded]) {
		// Middle broggut isn't minable
		for (int i = -1; i < 2; i++) {
			for (int j = -1; j < 2; j++) {
				if (i == 0 && j == 0) {
					continue;
				}
				CGPoint point = CGPointMake(location.x + (i * COLLISION_CELL_WIDTH), location.y + (j * COLLISION_CELL_HEIGHT));
                [pointArray addObject:[NSValue valueWithCGPoint:point]];
			}
		}
        // Shuffle it!
        NSMutableArray* copy = [pointArray mutableCopy];
        [pointArray removeAllObjects];
        while ([copy count] > 0)
        {
            int index = arc4random() % [copy count];
            id objectToMove = [copy objectAtIndex:index];
            [pointArray addObject:objectToMove];
            [copy removeObjectAtIndex:index];
        }
        for (int i = 0; i < [pointArray count]; i++) {
            CGPoint point = [[pointArray objectAtIndex:i] CGPointValue];
            if ([self startMiningBroggutWithLocation:point wasCommanded:commanded]) {
                [copy release];
                [pointArray release];
                return;
            }
        }
        [copy release];
	}
    [pointArray release];
}

- (BOOL)startMiningBroggutWithLocation:(CGPoint)location wasCommanded:(BOOL)commanded {
	MediumBroggut* broggut = [[self.currentScene collisionManager] broggutCellForLocation:location];
    if (broggut && broggut->broggutValue != -1) {
        if (broggut->broggutEdge != kMediumBroggutEdgeNone) {
            // NSLog(@"Started object (%i) mining broggut (%i) with value (%i)", uniqueObjectID, broggut->broggutID, broggut->broggutValue);
            CGPoint broggutLoc = [[self.currentScene collisionManager] getBroggutLocationForID:broggut->broggutID];
            miningBroggutID = broggut->broggutID;
            miningLocation = broggutLoc;
            NSArray* pathArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:broggutLoc], nil];
            [self followPath:pathArray isLooped:NO];
            miningState = kMiningStateApproaching;
            [self setMovingAIState:kMovingAIStateMining];
            return YES;
        } else {
            miningState = kMiningStateNone;
            [self setMovingAIState:kMovingAIStateStill];
            if (commanded) {
                [[SoundSingleton sharedSoundSingleton] playSoundWithKey:kSoundFileNames[kSoundFileShipDeny] location:objectLocation];
                [currentScene showHelpMessageWithMessageID:kHelpMessageMiningEdges];
            }
            return NO;
        }
	}
    return NO;
}

- (void)addCargo:(int)cargo {
	attributePlayerCurrentCargo = CLAMP(attributePlayerCurrentCargo + cargo, 0, attributePlayerCargoCapacity);
}

- (void)cashInBrogguts {
    [super cashInBrogguts];
    if (miningState == kMiningStateReturning) {
        [self tryMiningBroggutsWithCenter:miningLocation wasCommanded:NO];
    }
}

- (void)returnBroggutsHome {
    if (objectAlliance == kAllianceFriendly) {
        CGPoint home = [self.currentScene homeBaseLocation];
        float dist = 256.0f;
        float angle = GetAngleInDegreesFromPoints(home, objectLocation);
        NSArray* homePath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(home.x + dist * cosf(DEGREES_TO_RADIANS(angle)),
                                                                                           home.y + dist * sinf(DEGREES_TO_RADIANS(angle)))]];
        [self followPath:homePath isLooped:NO];
    } else if (objectAlliance == kAllianceEnemy) {
        CGPoint home = [self.currentScene enemyBaseLocation];
        float dist = 256.0f;
        float angle = GetAngleInDegreesFromPoints(home, objectLocation);
        NSArray* homePath = [NSArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(home.x + dist * cosf(DEGREES_TO_RADIANS(angle)),
                                                                                           home.y + dist * sinf(DEGREES_TO_RADIANS(angle)))]];
        [self followPath:homePath isLooped:NO];
    }
	[self setMovingAIState:kMovingAIStateMining];
	miningState = kMiningStateReturning;
    [[[self currentScene] collisionManager] updateAllMediumBroggutsEdges];
    [[[self currentScene] collisionManager] updateMediumBroggutAtLocation:miningLocation];
}

- (void)followPath:(NSArray *)array isLooped:(BOOL)looped {
	miningState = kMiningStateNone;
	[super followPath:array isLooped:looped];
}

- (void)stopFollowingCurrentPath {
	miningState = kMiningStateNone;
	[super stopFollowingCurrentPath];
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	[super updateObjectLogicWithDelta:aDelta];
    
    // Check for upgrade
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        attributeMiningCooldown = kCraftAntMiningCooldownUpgrade;
    }
    
	// Mine from broggut when close and in mining state
	if (hasCurrentPathFinished && miningState == kMiningStateApproaching) {
		// Just arrived at the broggut location
		miningState = kMiningStateMining;
	}
	
	// When arrived at broggut, start mining
	if (hasCurrentPathFinished && miningState == kMiningStateMining) {
		[self setMovingAIState:kMovingAIStateMining];
		// Harvest some brogguts!
		MediumBroggut* broggut = [[self.currentScene collisionManager] broggutCellForLocation:miningLocation];
		if (broggut->broggutValue > 0) {
			// There are still brogguts left...
            if (miningCooldownTimer <= 0) {
                int broggutChangeAmount = CLAMP(1, 0, broggut->broggutValue);
                miningCooldownTimer = attributeMiningCooldown;
                attributePlayerCurrentCargo += broggutChangeAmount;
                attributePlayerCurrentCargo = CLAMP(attributePlayerCurrentCargo, 0, attributePlayerCargoCapacity);
                int currentValue = broggut->broggutValue - broggutChangeAmount;
                [[self.currentScene collisionManager] setBroggutValue:currentValue withID:broggut->broggutID isRemote:NO];
                [self.currentScene playMiningSoundAtLocation:miningLocation];
            } else {
                miningCooldownTimer--;
            }
		}
		// Check if the broggut is out
		if (broggut->broggutValue <= 0) {
			// The broggut is dead and should be destroyed...
			[[self.currentScene collisionManager] removeMediumBroggutWithID:broggut->broggutID];
			// Return home
			[self returnBroggutsHome];
		}
		// Check if cargo has full brogguts
		if (attributePlayerCurrentCargo == attributePlayerCargoCapacity) {
			// Ship is full, bring her home
			[self returnBroggutsHome];
		}
	}
}

- (void)renderUnderObjectWithScroll:(Vector2f)scroll {
    [super renderUnderObjectWithScroll:scroll];
    enablePrimitiveDraw();
    
	if (miningState == kMiningStateMining) {
        if (![currentScene isMissionOver]) {
            glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
            float randX = RANDOM_MINUS_1_TO_1() * ( (COLLISION_CELL_WIDTH) / 4);
            float randY = RANDOM_MINUS_1_TO_1() * ( (COLLISION_CELL_HEIGHT) / 4);
            glLineWidth(3.0f);
            drawLine(objectLocation, CGPointMake(miningLocation.x + randX, miningLocation.y + randY), scroll);
            glLineWidth(1.0f);
        }
	}
    
    disablePrimitiveDraw();
    if (isBeingDragged) {
		[[self.currentScene collisionManager] drawValidityRectForLocation:dragLocation forMining:YES];
	}
    
}

- (void)touchesEndedAtLocation:(CGPoint)location {
	if (isBeingDragged) {
		if ([self startMiningBroggutWithLocation:location wasCommanded:YES]) {
            if (isBeingControlled) {
                [[self currentScene] removeControlledCraft:self];
                [self setIsBeingControlled:NO];
            }
        } else {
            [[SoundSingleton sharedSoundSingleton] playSoundWithKey:kSoundFileNames[kSoundFileShipDeny]];
        }
	}
	[super touchesEndedAtLocation:location];
}

@end
