//
//  RefineryStructureObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 4/18/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "RefineryStructureObject.h"
#import "BroggutScene.h"
#import "AnimatedImage.h"
#import "Image.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "TextObject.h"
#import "UpgradeManager.h"
#import "RefinerySmokeObject.h"
#import "ImageRenderSingleton.h"

#define REFINERY_SMOKE_FREQUENCY 10
#define REFINERY_SMOKE_X_OFFSET 26.0f
#define REFINERY_SMOKE_Y_OFFSET 40.0f

@implementation RefineryStructureObject
@synthesize isRefining;

- (void)dealloc {
    [animatedImage release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureRefineryID withLocation:location isTraveling:traveling];
	if (self) {
        animatedImage = [[AnimatedImage alloc] initWithFileName:kObjectStructureRefinerySprite withSubImageCount:4];
        [animatedImage setAnimationSpeed:0.0f];
		isCheckedForRadialEffect = YES;
        hasBeenAdded = NO;
        isRefining = NO;
        refiningTimeTotal = kStructureRefineryBroggutConvertTime;
        refiningTimer = 0;
	}
	return self;
}

- (void)createRefinerySmoke {
    if (!isTraveling && !destroyNow) {
        RefinerySmokeObject* smoke = [[RefinerySmokeObject alloc] initWithLocation:CGPointMake(objectLocation.x + (REFINERY_SMOKE_X_OFFSET * [self objectScale].x),
                                                                                               objectLocation.y + (REFINERY_SMOKE_Y_OFFSET * [self objectScale].y))];
        [[self currentScene] addCollidableObject:smoke];
        [smoke release];
    }
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
    [super updateObjectLogicWithDelta:aDelta];
    
    if ([[[self currentScene] upgradeManager] isUpgradeCompleteWithID:objectType]) {
        refiningTimeTotal = kStructureRefineryBroggutConvertTimeUpgrade;
    }
    
    [animatedImage updateAnimatedImageWithDelta:aDelta];
    if (!hasBeenAdded && !isTraveling) {
        hasBeenAdded = YES;
        [[self currentScene] addRefinery:self];
    }
    
    if (refiningCounter > 0) {
        if (refiningTimer > 0) {
            refiningTimer--;
            if (refiningTimer % REFINERY_SMOKE_FREQUENCY == 0) {
                [self createRefinerySmoke];
            }
        } else {
            int metalCount = 0;
            if (refiningCounter > kStructureRefineryBroggutConversionRate) {
                metalCount = kStructureRefineryBroggutConversionRate;
            } else {
                metalCount = refiningCounter;
            }
            refiningTimer = refiningTimeTotal;
            refiningCounter -= metalCount;
            [[[GameController sharedGameController] currentProfile] addMetal:metalCount];
            NSString* metalString = [NSString stringWithFormat:@"+%i Metal", metalCount];
            float width = [[self currentScene] getWidthForFontID:kFontBlairID withString:metalString];
            TextObject* metalText = [[TextObject alloc] initWithFontID:kFontBlairID 
                                                                  Text:metalString
                                                          withLocation:CGPointMake(objectLocation.x - width / 2, objectLocation.y)
                                                          withDuration:2.0f];
            [metalText setObjectVelocity:Vector2fMake(0.0f, 0.3f)];
            [metalText setFontColor:Color4fMake(0.4f, 0.5f, 1.0f, 1.0f)];
            [metalText setRenderLayer:kLayerTopLayer];
            [[self currentScene] addTextObject:metalText];
            [self createRefinerySmoke];
            [metalText release];
        }
    } else {
        refiningCounter = 0;
        [self setIsRefining:NO];
    }
}

- (void)setIsRefining:(BOOL)refining {
    isRefining = refining;
    if (refining) {
        [animatedImage setAnimationSpeed:0.1f];
    } else {
        [animatedImage setAnimationSpeed:0.0f];
    }
}

- (void)addRefiningCount:(int)counter {
    refiningCounter += counter;
    refiningTimer = refiningTimeTotal;
    [self setIsRefining:YES];
}

- (int)currentPotentialMetal {
    if (isRefining)
        return refiningCounter;
    else
        return 0;
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    // [self renderCenteredAtPoint:aPoint withScrollVector:vector];
    [animatedImage renderCurrentSubImageAtPoint:CGPointMake(objectLocation.x - vector.x, objectLocation.y - vector.y)
                                      withScale:self.objectScale
                                   withRotation:objectRotation];
}

@end
