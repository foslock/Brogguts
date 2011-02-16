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
		playerExperience = 0;
	}
	return self;
}

- (void)updateProfile {
	if (broggutDisplayNumber < broggutCount) {
		broggutDisplayNumber += BROGGUT_DISPLAY_CHANGE_RATE;
	}
	broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, broggutCount);
	
	if (broggutDisplayNumber > broggutCount) {
		broggutDisplayNumber -= BROGGUT_DISPLAY_CHANGE_RATE;
	}
	broggutDisplayNumber = CLAMP(broggutDisplayNumber, 0, broggutCount);
}

- (void)addBrogguts:(int)brogs {
	broggutCount += brogs;
}

- (void)subtractBrogguts:(int)brogs {
	broggutCount -= brogs;
}

- (int)broggutCount {
	return broggutDisplayNumber;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if (self = [super init])
	{
		[self setPlayerSpaceYear:	[coder decodeIntForKey:@"playerSpaceYear"]];
		[self setBroggutCount:		[coder decodeIntForKey:@"broggutCount"]];
		[self setMetalCount:		[coder decodeIntForKey:@"metalCount"]];
		[self setPlayerExperience:	[coder decodeIntForKey:@"playerExperience"]];
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
