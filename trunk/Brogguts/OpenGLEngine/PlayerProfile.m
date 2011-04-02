//
//  PlayerProfile.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "PlayerProfile.h"


@implementation PlayerProfile
@synthesize playerSpaceYear;
@synthesize broggutCount;
@synthesize metalCount;
@synthesize playerExperience;

- (id)init {
    self = [super init];
	if (self)
	{
		playerSpaceYear = 0;
		broggutCount = PROFILE_BROGGUT_START_COUNT;
		broggutDisplayNumber = 0;
		metalCount = PROFILE_METAL_START_COUNT;
		metalDisplayNumber = 0;
		playerExperience = 0;
        isInSkirmish = NO;
	}
	return self;
}

- (void)updateProfile {
    if (!isInSkirmish) {
        if (broggutDisplayNumber < broggutCount) {
            broggutDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, broggutCount);
        }
        if (broggutDisplayNumber > broggutCount) {
            broggutDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, PROFILE_BROGGUT_MAX_COUNT);
        }
        if (metalDisplayNumber < metalCount) {
            metalDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, metalCount);
        }
        if (metalDisplayNumber > metalCount) {
            metalDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, PROFILE_METAL_MAX_COUNT);
        }
    } else {
        if (broggutDisplayNumber < skirmishBroggutCount) {
            broggutDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, skirmishBroggutCount);
        }
        if (broggutDisplayNumber > skirmishBroggutCount) {
            broggutDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, PROFILE_BROGGUT_MAX_COUNT);
        }
        if (metalDisplayNumber < skirmishMetalCount) {
            metalDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, skirmishMetalCount);
        }
        if (metalDisplayNumber > skirmishMetalCount) {
            metalDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
            metalDisplayNumber = CLAMP(metalDisplayNumber, 0, PROFILE_METAL_MAX_COUNT);
        }
    }
}

- (void)addBrogguts:(int)brogs {
    if (!isInSkirmish) {
        broggutCount += brogs;
        broggutCount = CLAMP(broggutCount, 0, PROFILE_BROGGUT_MAX_COUNT);
    } else {
        skirmishBroggutCount += brogs;
        skirmishBroggutCount = CLAMP(skirmishBroggutCount, 0, PROFILE_BROGGUT_MAX_COUNT);
    }
}

- (void)addMetal:(int)metal {
    if (!isInSkirmish) {
        metalCount += metal;
        metalCount = CLAMP(metalCount, 0, PROFILE_METAL_MAX_COUNT);
    } else {
        skirmishMetalCount += metal;
        skirmishMetalCount = CLAMP(skirmishMetalCount, 0, PROFILE_METAL_MAX_COUNT);
    }
}

- (BOOL)subtractBrogguts:(int)brogs metal:(int)metal {
    if (!isInSkirmish) {
        if (brogs > broggutCount || metal > metalCount) {
            return NO;
        } else {
            metalCount -= metal;
            broggutCount -= brogs;
            return YES;
        }
    } else {
        if (brogs > skirmishBroggutCount || metal > skirmishMetalCount) {
            return NO;
        } else {
            skirmishMetalCount -= metal;
            skirmishBroggutCount -= brogs;
            return YES;
        }
    }
}

- (int)broggutCount {
	return broggutDisplayNumber;
}

- (int)realBroggutCount {
    if (!isInSkirmish) {
        return broggutCount;
    } else {
        return skirmishBroggutCount;
    }
}

- (int)metalCount {
	return metalDisplayNumber;
}

- (int)realMetalCount {
    if (!isInSkirmish) {
        return metalCount;
    } else {
        return skirmishMetalCount;
    }
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
	if (self)
	{
		[self setPlayerSpaceYear:	[coder decodeIntForKey:@"playerSpaceYear"]];
		[self setBroggutCount:		CLAMP([coder decodeIntForKey:@"broggutCount"], 0, PROFILE_BROGGUT_MAX_COUNT)];
		[self setMetalCount:		CLAMP([coder decodeIntForKey:@"metalCount"], 0, PROFILE_METAL_MAX_COUNT)];
		[self setPlayerExperience:	[coder decodeIntForKey:@"playerExperience"]];
		broggutDisplayNumber = broggutCount;
		metalDisplayNumber = metalCount;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeInt:playerSpaceYear	forKey:@"playerSpaceYear"];
	[coder encodeInt:broggutCount		forKey:@"broggutCount"];
	[coder encodeInt:metalCount			forKey:@"metalCount"];
	[coder encodeInt:playerExperience	forKey:@"playerExperience"];
}

- (void)updateSpaceYear {
    // Perform a calculation (log based) on the total broggut count to get the space year
}

- (void)startSkirmish {
    if (!isInSkirmish) {
        isInSkirmish = YES;
        skirmishBroggutCount = 0;
        skirmishMetalCount = 0;
        broggutDisplayNumber = skirmishBroggutCount;
		metalDisplayNumber = skirmishMetalCount;
    }
}

- (void)endSkirmishSuccessfully:(BOOL)success {
    if (isInSkirmish) {
        isInSkirmish = NO;
        broggutDisplayNumber = broggutCount;
		metalDisplayNumber = metalCount;
        if (success) {
            [self addBrogguts:(int)((float)skirmishBroggutCount * PERCENT_BROGGUTS_CREDITED_FOR_SKIRMISH)];
        }
    }
}

@end
