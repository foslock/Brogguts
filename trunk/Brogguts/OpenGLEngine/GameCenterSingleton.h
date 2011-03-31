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

@class GameController;
@class BroggutScene;

@interface GameCenterSingleton : UIViewController <GKMatchDelegate, GKMatchmakerViewControllerDelegate> {
	GameController* sharedGameController;
    BroggutScene* currentScene;
    NSMutableDictionary* objectsReceivedArray;
	GKLocalPlayer* localPlayer;
	NSString* localPlayerID;
	NSString* otherPlayerID;
    NSString* hostedFileName; 
	GKMatch* currentMatch;
	BOOL matchStarted;
}

@property (nonatomic, assign) BroggutScene* currentScene;
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
- (void)findAllActivity;
- (void)hostMatchWithHostedFileName:(NSString*)filename;
- (void)findProgrammaticMatch;
- (void)match:(GKMatch*)match player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state;
- (CGPoint)translatedPointForMultiplayer:(Vector2f)point;

// Sending packets
- (void)sendSimplePacket:(SimpleEntityPacket)packet isRequired:(BOOL)required;
- (void)sendComplexPacket:(ComplexEntityPacket)packet isRequired:(BOOL)required;
- (void)sendCreationPacket:(CreationPacket)packet isRequired:(BOOL)required;
- (void)sendDestructionPacket:(DestructionPacket)packet isRequired:(BOOL)required;
- (void)sendBroggutUpdatePacket:(BroggutUpdatePacket)packet isRequired:(BOOL)required;

// Processing packets
- (void)creationPacketReceived:(CreationPacket)packet;
- (void)destructionPacketReceived:(DestructionPacket)packet;
- (void)broggutUpdatePacketReceived:(BroggutUpdatePacket)packet;
- (void)simplePacketReceived:(SimpleEntityPacket)packet;
- (void)complexPacketReceived:(ComplexEntityPacket)packet;

@end
