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
	}
	return self;
}

- (void)updateProfile {
	if (broggutDisplayNumber < broggutCount) {
		broggutDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
		broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, broggutCount);
	}
	if (broggutDisplayNumber > broggutCount) {
		broggutDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
		broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, INT_MAX);
	}
	if (metalDisplayNumber < metalCount) {
		metalDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
		metalDisplayNumber = CLAMP(metalDisplayNumber, 0, metalCount);
	}
	if (metalDisplayNumber > metalCount) {
		metalDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
		metalDisplayNumber = CLAMP(metalDisplayNumber, 0, INT_MAX);
	}
}

- (void)addBrogguts:(int)brogs {
	broggutCount += brogs;
}

- (void)addMetal:(int)metal {
	metalCount += metal;
}

- (BOOL)subtractBrogguts:(int)brogs metal:(int)metal {
	if (brogs > broggutCount || metal > metalCount) {
		return NO;
	} else {
		metalCount -= metal;
		broggutCount -= brogs;
		return YES;
	}	
}

- (int)broggutCount {
	return broggutDisplayNumber;
}

- (int)realBroggutCount {
	return broggutCount;
}

- (int)metalCount {
	return metalDisplayNumber;
}

- (int)realMetalCount {
	return metalCount;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
	if (self)
	{
		[self setPlayerSpaceYear:	[coder decodeIntForKey:@"playerSpaceYear"]];
		[self setBroggutCount:		[coder decodeIntForKey:@"broggutCount"]];
		[self setMetalCount:		[coder decodeIntForKey:@"metalCount"]];
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

@end
