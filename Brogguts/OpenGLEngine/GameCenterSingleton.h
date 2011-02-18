//
//  GameCenterSingleton.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/4/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GameCenterStructs.h"
#import "GameController.h"

@interface GameCenterSingleton : UIViewController <GKMatchDelegate, GKMatchmakerViewControllerDelegate> {
	GameController* sharedGameController;
	GKLocalPlayer* localPlayer;
	NSString* localPlayerID;
	NSString* otherPlayerID;
	GKMatch* currentMatch;
	BOOL matchStarted;
}

@property (retain) GKMatch* currentMatch;
@property (copy) NSString* localPlayerID;
@property (copy) NSString* otherPlayerID;
@property (assign) BOOL matchStarted;

+ (GameCenterSingleton*)sharedGCSingleton;
- (void)authenticateLocalPlayer;
- (void)setInvitationHandler;
- (BOOL)isGameCenterAvailable;
- (void)retrieveFriends;
- (void)loadPlayerData:(NSArray*)identifiers;
- (IBAction)findAllActivity;
- (IBAction)hostMatch:(id)sender;
- (IBAction)findProgrammaticMatch:(id)sender;
- (void)match:(GKMatch*)match player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state;
- (void)sendSimplePacket:(SimpleEntityPacket)packet;
- (void)sendComplexPacket:(ComplexEntityPacket)packet;

@end
