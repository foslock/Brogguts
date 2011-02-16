//
//  PlayerProfile.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/12/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BROGGUT_DISPLAY_CHANGE_RATE 2

@interface PlayerProfile : NSObject <NSCoding> {
	int playerSpaceYear;
	int broggutCount;
	int broggutDisplayNumber;
	int metalCount;
	int playerExperience;
}

- (void)updateProfile;
- (void)addBrogguts:(int)brogs;
- (void)subtractBrogguts:(int)brogs;

@property (nonatomic, assign) int playerSpaceYear;
@property (nonatomic, assign) int broggutCount;
@property (nonatomic, assign) int metalCount;
@property (nonatomic, assign) int playerExperience;

@end
