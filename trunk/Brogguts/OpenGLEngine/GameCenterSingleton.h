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

#define PACKET_QUEUE_CAPACITY 500

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
    
    // Queues for received packets
    // If the game has NOT started (gameStarted == NO), then these are used for OUTGOING data that will be sent when the match does start
    // If the game has started (gameStarted == YES), then these are used for all incoming messages to assure the correct order
    CreationPacket* creationPacketQueue;
    int creationQueueCount;
    SimpleEntityPacket* simplePacketQueue;
    int simpleQueueCount;
    ComplexEntityPacket* complexPacketQueue;
    int complexQueueCount;
    BroggutUpdatePacket* broggutPacketQueue;
    int broggutQueueCount;
    DestructionPacket* destructionPacketQueue;
    int destructionQueueCount;
    
	BOOL matchStarted;  // YES when the two clients have first initially made a connection (data sending is not reliable)
    BOOL gameStarted;   // YES when the two clients games can start (data can be reliably sent)
    BOOL queuedPacketsSent;
}

@property (nonatomic, assign) BroggutScene* currentScene;
@property (retain) GKMatch* currentMatch;
@property (copy) NSString* localPlayerID;
@property (copy) NSString* otherPlayerID;
@property (assign) BOOL matchStarted;
@property (nonatomic, assign) BOOL gameStarted;

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

- (void)processQueuedPackets;
- (void)sendQueuedPackets;

// Sending packets
- (void)sendMatchPacket:(MatchPacket)packet isRequired:(BOOL)required;
- (void)sendSimplePacket:(SimpleEntityPacket)packet isRequired:(BOOL)required;
- (void)sendComplexPacket:(ComplexEntityPacket)packet isRequired:(BOOL)required;
- (void)sendCreationPacket:(CreationPacket)packet isRequired:(BOOL)required;
- (void)sendDestructionPacket:(DestructionPacket)packet isRequired:(BOOL)required;
- (void)sendBroggutUpdatePacket:(BroggutUpdatePacket)packet isRequired:(BOOL)required;

// Processing packets
- (void)matchPacketReceived:(MatchPacket)packet;
- (void)creationPacketReceived:(CreationPacket)packet;
- (void)destructionPacketReceived:(DestructionPacket)packet;
- (void)broggutUpdatePacketReceived:(BroggutUpdatePacket)packet;
- (void)simplePacketReceived:(SimpleEntityPacket)packet;
- (void)complexPacketReceived:(ComplexEntityPacket)packet;

@end
