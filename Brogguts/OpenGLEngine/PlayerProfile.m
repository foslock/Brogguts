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
	if (self = [super init])
	{
		playerSpaceYear = 0;
		broggutCount = 0;
		broggutDisplayNumber = 0;
		metalCount = 0;
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
	if (self = [super init])
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
