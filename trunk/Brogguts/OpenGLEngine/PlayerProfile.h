//
//  PlayerProfile.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PROFILE_BROGGUT_START_COUNT 200
#define PROFILE_METAL_START_COUNT 100
#define BROGGUT_DISPLAY_CHANGE_RATE 4

@interface PlayerProfile : NSObject <NSCoding> {
	int playerSpaceYear;
	int broggutCount;
	int broggutDisplayNumber;
	int metalCount;
	int metalDisplayNumber;
	int playerExperience;
}

@property (nonatomic, assign) int playerSpaceYear;
@property (nonatomic, assign) int broggutCount;
@property (nonatomic, assign) int metalCount;
@property (nonatomic, assign) int playerExperience;

// Updates the display number of brogguts (what "broggutCount" returns)
- (void)updateProfile; 

- (void)addBrogguts:(int)brogs;
- (void)addMetal:(int)metal;

// Returns NO if the current broggut count is too low to subtract the passed in brogguts and DOES NOT subtract them
- (BOOL)subtractBrogguts:(int)brogs metal:(int)metal;

- (int)realBroggutCount;
- (int)realMetalCount;

@end
