//
//  GameCenterSingleton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/4/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "GameCenterSingleton.h"
#import "GameController.h"
#import "BroggutScene.h"
#import "OpenGLEngineAppDelegate.h"
#import "TouchableObject.h"
#import "CraftAndStructures.h"
#import "Image.h"
#import "CollisionManager.h"
#import "GameplayConstants.h"
#import "CraftAndStructures.h"

static GameCenterSingleton* sharedGCSingleton = nil;

@implementation GameCenterSingleton
@synthesize currentScene, currentMatch;
@synthesize otherPlayerID, localPlayerID;
@synthesize matchStarted, gameStarted;

+ (GameCenterSingleton*)sharedGCSingleton
{
#ifdef MULTIPLAYER
	@synchronized (self) {
		if (sharedGCSingleton == nil) {
			[[self alloc] init];
		}
	}
	return sharedGCSingleton;
#else
	return nil;
#endif
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedGCSingleton == nil) {
			sharedGCSingleton = [super allocWithZone:zone];
			return sharedGCSingleton;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; // This is sooo not zero
}

- (void)dealloc {
    if (creationPacketQueue)
        free(creationPacketQueue);
    if (simplePacketQueue)
        free(simplePacketQueue);
    if (complexPacketQueue)
        free(complexPacketQueue);
    if (broggutPacketQueue)
        free(broggutPacketQueue);
    if (destructionPacketQueue)
        free(destructionPacketQueue);
    
	[localPlayerID release];
	[otherPlayerID release];
    [otherPlayerArrayID release];
	[currentMatch release];
    [hostedFileName release];
    [currentMatch disconnect];
	[super dealloc];
}

// Handling Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

// Normal methods

- (id)init {
	self = [super init];
	if (self) {
		if ([self isGameCenterAvailable]) {
			[self authenticateLocalPlayer];
			[self.view setBackgroundColor:[UIColor clearColor]];
			sharedGameController = [GameController sharedGameController];
            objectsReceivedArray = [[NSMutableDictionary alloc] init];
			matchStarted = NO;
            gameStarted = NO;
            queuedPacketsSent = NO;
            otherPlayerArrayID = nil;
            
            creationPacketQueue = calloc(PACKET_QUEUE_CAPACITY, sizeof(*creationPacketQueue));
            creationQueueCount = 0;
            simplePacketQueue = calloc(PACKET_QUEUE_CAPACITY, sizeof(*simplePacketQueue));
            simpleQueueCount = 0;
            complexPacketQueue = calloc(PACKET_QUEUE_CAPACITY, sizeof(*complexPacketQueue));
            complexQueueCount = 0;
            broggutPacketQueue = calloc(PACKET_QUEUE_CAPACITY, sizeof(*broggutPacketQueue));
            broggutQueueCount = 0;
            destructionPacketQueue = calloc(PACKET_QUEUE_CAPACITY, sizeof(*destructionPacketQueue));
            destructionQueueCount = 0;
            
		} else {
			NSLog(@"Game Center is not available on this platform.");
		}
	}
	return self;
}

- (BOOL)isGameCenterAvailable {
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
    return (gcClass && osVersionSupported);
}

- (void)authenticateLocalPlayer
{
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error == nil)
		{
            localPlayerID = [[GKLocalPlayer localPlayer] playerID];
			NSLog(@"Authentication was successful!");
			// Insert code here to handle a successful authentication.
		}
		else
		{
			NSLog(@"Error, authentication failed!");
			// Your application can process the error parameter to report the error to the player.
		}
	}];
}

- (void)setInvitationHandler {
	[GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
		// Insert application-specific code here to clean up any games in progress.
		if (acceptedInvite)
		{
			GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite] autorelease];
			mmvc.matchmakerDelegate = self;
			[self presentModalViewController:mmvc animated:YES];
		}
		else if (playersToInvite)
		{
			GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
			request.minPlayers = 2;
			request.maxPlayers = 2;
			request.playersToInvite = playersToInvite;
			
			GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
			mmvc.matchmakerDelegate = self;
			[self presentModalViewController:mmvc animated:YES];
		}
	};
}

- (void)retrieveFriends
{
    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
    if (lp.authenticated)
    {
        [lp loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
			if (error == nil)
			{
				// use the player identifiers to create player objects.
			}
			else
			{
				// report an error to the user.
			}
		}];
    }
}

- (void)loadPlayerData:(NSArray *)identifiers
{
    [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil)
        {
            // Handle the error.
        }
        if (players != nil)
        {
            // Process the array of GKPlayer objects.
        }
	}];
}

- (void)findAllActivity
{
    [[GKMatchmaker sharedMatchmaker] queryActivityWithCompletionHandler:^(NSInteger activity, NSError *error) {
        if (error)
        {
            // Process the error.
        }
        else
        {
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Activity"
                                                            message:[NSString stringWithFormat:@"There are %i players online",activity]
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
            // Use the activity value to display activity to the player.
        }
    }];
}

- (void)hostMatchWithHostedFileName:(NSString*)filename
{
    if (hostedFileName)
        [hostedFileName release];
    
    hostedFileName = [filename copy];
    
    [[((OpenGLEngineAppDelegate*)[[UIApplication sharedApplication] delegate]) window] addSubview:self.view];
    
    GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
    request.minPlayers = 2;
    request.maxPlayers = 2;
	
    GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
    mmvc.matchmakerDelegate = self;
	
    [self presentModalViewController:mmvc animated:YES];
}

- (void)findProgrammaticMatch
{
    GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
    request.minPlayers = 2;
    request.maxPlayers = 2;
	
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            // Process the error.
        }
        else if (match != nil)
        {
            self.currentMatch = match; // Use a retaining property to retain the match.
            // Start the match.
			currentMatch.delegate = self;
        }
    }];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
	NSLog(@"Match finding cancelled!");
    [self dismissModalViewControllerAnimated:YES];
    [self.view removeFromSuperview];
    // implement any specific code in your application here.
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
	NSLog(@"Match finding failed!");
    [self dismissModalViewControllerAnimated:YES];
    [self.view removeFromSuperview];
    // Display the error to the user.
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [self dismissModalViewControllerAnimated:YES];
    self.currentMatch = match; // Use a retaining property to retain the match.
	currentMatch.delegate = self;
    
    // Start the game using the match.
    [(OpenGLEngineAppDelegate*)[[UIApplication sharedApplication] delegate] startGLAnimation];
    [[GameController sharedGameController] transitionToSceneWithFileName:hostedFileName isTutorial:NO isNew:YES];
	[self.view removeFromSuperview];
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
	NSLog(@"Match changed state...");
    switch (state)
    {
        case GKPlayerStateConnected:
            // handle a new player connection.
			NSLog(@"Player connected: %@", playerID);
            if ([playerID caseInsensitiveCompare:localPlayerID] != NSOrderedSame) {
                self.otherPlayerID = playerID;
                otherPlayerArrayID = [[NSArray alloc] initWithObjects:otherPlayerID, nil];
            }
			break;
        case GKPlayerStateDisconnected:
			NSLog(@"Other player left, disconnecting...");
			[currentMatch disconnect];
            [currentScene otherPlayerDisconnected];
            // a player just disconnected.
			break;
    }
    if (!matchStarted && match.expectedPlayerCount == 0)
    {
		NSLog(@"Match has started!");
        matchStarted = YES;
        // handle initial match negotiation.
    }
}

- (CGPoint)translatedPointForMultiplayer:(Vector2f)point {
    CGRect bounds = [currentScene fullMapBounds];
    CGPoint newPoint = CGPointMake(bounds.size.width - point.x, point.y);
    return newPoint;
}

- (void)processQueuedPackets {
    // Go through each queue and make stuff!
    
    int counter = 0;
    while (counter < creationQueueCount) {
        CreationPacket thisPacket = creationPacketQueue[counter++];
        [self creationPacketReceived:thisPacket];
    }
    
    counter = 0;
    while (counter < destructionQueueCount) {
        DestructionPacket thisPacket = destructionPacketQueue[counter++];
        [self destructionPacketReceived:thisPacket];
    }
    
    counter = 0;
    while (counter < simpleQueueCount) {
        SimpleEntityPacket thisPacket = simplePacketQueue[counter++];
        [self simplePacketReceived:thisPacket];
    }
    
    counter = 0;
    while (counter < complexQueueCount) {
        ComplexEntityPacket thisPacket = complexPacketQueue[counter++];
        [self complexPacketReceived:thisPacket];
    }
    
    counter = 0;
    while (counter < broggutQueueCount) {
        BroggutUpdatePacket thisPacket = broggutPacketQueue[counter++];
        [self broggutUpdatePacketReceived:thisPacket];
    }
    
    // Reset all counts
    creationQueueCount = 0;
    simpleQueueCount = 0;
    complexQueueCount = 0;
    broggutQueueCount = 0;
    destructionQueueCount = 0;
}

- (void)sendQueuedPackets {
    if (queuedPacketsSent) {
        return; // Only call this once at the beginning of the match
    } else {
        queuedPacketsSent = YES;
    }
    // Go through each queue and send the packets waiting!
    
    int counter = 0;
    while (counter < creationQueueCount) {
        CreationPacket thisPacket = creationPacketQueue[counter++];
        [self sendCreationPacket:thisPacket isRequired:YES];
    }
    
    counter = 0;
    while (counter < destructionQueueCount) {
        DestructionPacket thisPacket = destructionPacketQueue[counter++];
        [self sendDestructionPacket:thisPacket isRequired:YES];
    }
    
    counter = 0;
    while (counter < simpleQueueCount) {
        SimpleEntityPacket thisPacket = simplePacketQueue[counter++];
        [self sendSimplePacket:thisPacket isRequired:NO];
    }
    
    counter = 0;
    while (counter < complexQueueCount) {
        ComplexEntityPacket thisPacket = complexPacketQueue[counter++];
        [self sendComplexPacket:thisPacket isRequired:NO];
    }
    
    counter = 0;
    while (counter < broggutQueueCount) {
        BroggutUpdatePacket thisPacket = broggutPacketQueue[counter++];
        [self sendBroggutUpdatePacket:thisPacket isRequired:YES];
    }
    
    // Reset all counts
    creationQueueCount = 0;
    simpleQueueCount = 0;
    complexQueueCount = 0;
    broggutQueueCount = 0;
    destructionQueueCount = 0;
}

- (void)disconnectFromGame {
    [currentMatch disconnect];
    currentMatch = nil;
    currentScene = nil;
    otherPlayerID = nil;
    otherPlayerArrayID = nil;
    matchStarted = NO;
    gameStarted = NO;
    queuedPacketsSent = NO;
    creationQueueCount = 0;
    simpleQueueCount = 0;
    complexQueueCount = 0;
    broggutQueueCount = 0;
    destructionQueueCount = 0;
}

// SENDING DATA

- (void)sendMatchPacket:(MatchPacket)packet isRequired:(BOOL)required {
	if (currentMatch && matchStarted) {
		NSError *error = nil;
		packet.packetType = kPacketTypeMatchPacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(MatchPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:otherPlayerArrayID
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the match packet");
			// handle the error
		}
	}
}

- (void)sendSimplePacket:(SimpleEntityPacket)packet isRequired:(BOOL)required {
	if (currentMatch && matchStarted && gameStarted) {
		NSError *error = nil;
		packet.packetType = kPacketTypeSimpleEntity;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(SimpleEntityPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:otherPlayerArrayID
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the simple packet");
			// handle the error
		}
	} else if (currentMatch && !gameStarted && !queuedPacketsSent) {
        // If the game is still loading for the other player
        packet.packetType = kPacketTypeSimpleEntity;
        if (simpleQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            SimpleEntityPacket* packetPointer = &simplePacketQueue[simpleQueueCount++];
            (*packetPointer) = packet;
        } else {
            NSLog(@"Simple packet queue is full!");
        }
    }
}

- (void)sendComplexPacket:(ComplexEntityPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted && gameStarted) {
		NSError *error = nil;
		packet.packetType = kPacketTypeComplexEntity;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(ComplexEntityPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:otherPlayerArrayID
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the complex packet");
			// handle the error
		}
	} else if (currentMatch && !gameStarted && !queuedPacketsSent) {
        // If the game is still loading for the other player
        packet.packetType = kPacketTypeComplexEntity;
        if (complexQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            ComplexEntityPacket* packetPointer = &complexPacketQueue[complexQueueCount++];
            (*packetPointer) = packet;
        } else {
            NSLog(@"Complex packet queue is full!");
        }
    }
}

- (void)sendCreationPacket:(CreationPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted && gameStarted) {
		NSError *error = nil;
		packet.packetType = kPacketTypeCreationPacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(CreationPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:otherPlayerArrayID
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the creation packet: %@", error);
			// handle the error
		}
	} else if (currentMatch && !gameStarted && !queuedPacketsSent) {
        // If the game is still loading for the other player
        packet.packetType = kPacketTypeCreationPacket;
        if (creationQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            CreationPacket* packetPointer = &creationPacketQueue[creationQueueCount++];
            (*packetPointer) = packet;
        } else {
            NSLog(@"Creation packet queue is full!");
        }
    }
}

- (void)sendDestructionPacket:(DestructionPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted && gameStarted) {
		NSError *error = nil;
		packet.packetType = kPacketTypeDestructionPacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(DestructionPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:otherPlayerArrayID
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the destruction packet");
			// handle the error
		}
	} else if (currentMatch && !gameStarted && !queuedPacketsSent) {
        // If the game is still loading for the other player
        packet.packetType = kPacketTypeDestructionPacket;
        if (destructionQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            DestructionPacket* packetPointer = &destructionPacketQueue[destructionQueueCount++];
            (*packetPointer) = packet;
        } else {
            NSLog(@"Destruction packet queue is full!");
        }
    }
}

- (void)sendBroggutUpdatePacket:(BroggutUpdatePacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted && gameStarted) {
		NSError *error = nil;
		packet.packetType = kPacketTypeBroggutUpdatePacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(BroggutUpdatePacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:otherPlayerArrayID
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the broggut update packet");
			// handle the error
		}
	} else if (currentMatch && !gameStarted && !queuedPacketsSent) {
        // If the game is still loading for the other player
        packet.packetType = kPacketTypeBroggutUpdatePacket;
        if (broggutQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            BroggutUpdatePacket* packetPointer = &broggutPacketQueue[broggutQueueCount++];
            (*packetPointer) = packet;
        } else {
            NSLog(@"Broggut packet queue is full!");
        }
    }
}

// RECEIVING DATA

- (void)match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
	const void* dataBytes = [data bytes];
    MatchPacket receivedMatchPacket = *(MatchPacket*)dataBytes;
    SimpleEntityPacket receivedSimplePacket = *(SimpleEntityPacket*)dataBytes;
	ComplexEntityPacket receivedComplexPacket = *(ComplexEntityPacket*)dataBytes;
    CreationPacket receivedCreationPacket = *(CreationPacket*)dataBytes;
    DestructionPacket receivedDestructionPacket = *(DestructionPacket*)dataBytes;
    BroggutUpdatePacket receivedBroggutPacket = *(BroggutUpdatePacket*)dataBytes;
    
	if ((receivedMatchPacket).packetType == kPacketTypeMatchPacket) {
        // Got a match initiation packet
        [self matchPacketReceived:receivedMatchPacket];
		return;
	}
    if ((receivedSimplePacket).packetType == kPacketTypeSimpleEntity) {
        // Get current queue location
        if (simpleQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            SimpleEntityPacket* packetPointer = &simplePacketQueue[simpleQueueCount++];
            (*packetPointer) = receivedSimplePacket;
        } else {
            NSLog(@"Simple packet queue is full!");
        }
		return;
	}
	if ((receivedComplexPacket).packetType == kPacketTypeComplexEntity) {
        if (complexQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            ComplexEntityPacket* packetPointer = &complexPacketQueue[complexQueueCount++];
            (*packetPointer) = receivedComplexPacket;
        } else {
            NSLog(@"Complex packet queue is full!");
        }
		return;
	}
    if ((receivedCreationPacket).packetType == kPacketTypeCreationPacket) {
        if (creationQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            CreationPacket* packetPointer = &creationPacketQueue[creationQueueCount++];
            (*packetPointer) = receivedCreationPacket;
        } else {
            NSLog(@"Creation packet queue is full!");
        }
		return;
	}
    if ((receivedDestructionPacket).packetType == kPacketTypeDestructionPacket) {
        if (destructionQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            DestructionPacket* packetPointer = &destructionPacketQueue[destructionQueueCount++];
            (*packetPointer) = receivedDestructionPacket;
        } else {
            NSLog(@"Destruction packet queue is full!");
        }
		return;
	}
    if ((receivedBroggutPacket).packetType == kPacketTypeBroggutUpdatePacket) {
        if (broggutQueueCount < PACKET_QUEUE_CAPACITY - 1) {
            BroggutUpdatePacket* packetPointer = &broggutPacketQueue[broggutQueueCount++];
            (*packetPointer) = receivedBroggutPacket;
        } else {
            NSLog(@"Broggut update packet queue is full!");
        }
		return;
	}
}

- (void)matchPacketReceived:(MatchPacket)packet {
    switch (packet.matchMarker) {
        case kMatchMarkerRequestStart: {
            MatchPacket packet;
            packet.matchMarker = kMatchMarkerConfirmStart;
            [self sendMatchPacket:packet isRequired:YES];
        }
            break;
        case kMatchMarkerConfirmStart:
            gameStarted = YES;
            [self sendQueuedPackets];
            break;   
        default:
            break;
    }
}

- (void)creationPacketReceived:(CreationPacket)packet {
    NSLog(@"Creation Packet received");
    CGPoint location = [self translatedPointForMultiplayer:packet.position];
    NSNumber* index = [NSNumber numberWithInt:packet.objectID];
    
    switch (packet.objectTypeID) {
        case kObjectCraftAntID: {
            AntCraftObject* newCraft = [[AntCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectCraftMothID: {
            MothCraftObject* newCraft = [[MothCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectCraftBeetleID: {
            BeetleCraftObject* newCraft = [[BeetleCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectCraftMonarchID: {
            MonarchCraftObject* newCraft = [[MonarchCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectCraftCamelID: {
            CamelCraftObject* newCraft = [[CamelCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectCraftRatID: {
            RatCraftObject* newCraft = [[RatCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectCraftSpiderID: {
            SpiderCraftObject* newCraft = [[SpiderCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectCraftEagleID: {
            EagleCraftObject* newCraft = [[EagleCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            break;
        }
        case kObjectStructureBaseStationID: {
            BaseStationStructureObject* newStructure = [[BaseStationStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [currentScene setEnemyBaseLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            break;
        }
        case kObjectStructureBlockID: {
            BlockStructureObject* newStructure = [[BlockStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            break;
        }
        case kObjectStructureTurretID: {
            TurretStructureObject* newStructure = [[TurretStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            break;
        }
        case kObjectStructureRadarID: {
            RadarStructureObject* newStructure = [[RadarStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            break;
        }
        case kObjectStructureFixerID: {
            FixerStructureObject* newStructure = [[FixerStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [currentScene addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            break;
        }
        case kObjectStructureRefineryID: {
            
            break;
        }
        case kObjectStructureCraftUpgradesID: {
            
            break;
        }
        case kObjectStructureStructureUpgradesID: {
            
            break;
        }
        default:
            NSLog(@"Tried to create craft or structure with invalid type ID (%i)", packet.objectTypeID);
            break;
    }
}

- (void)destructionPacketReceived:(DestructionPacket)packet {
    int objectID = packet.objectID;
    NSNumber* index = [NSNumber numberWithInt:objectID];
    TouchableObject* obj = [objectsReceivedArray objectForKey:index];
    [obj setDestroyNow:YES];
    [objectsReceivedArray removeObjectForKey:index];
}

- (void)broggutUpdatePacketReceived:(BroggutUpdatePacket)packet {
    CGPoint newPoint = [self translatedPointForMultiplayer:Vector2fMake(packet.broggutLocation.x, packet.broggutLocation.y)];
    MediumBroggut* broggut = [[currentScene collisionManager] broggutCellForLocation:newPoint];
    [[currentScene collisionManager] setBroggutValue:packet.newValue withID:broggut->broggutID isRemote:YES];
}

- (void)simplePacketReceived:(SimpleEntityPacket)packet {
    NSNumber* index = [NSNumber numberWithInt:packet.objectID];
    TouchableObject* obj = [objectsReceivedArray objectForKey:index];
    if (obj) {
        obj.objectLocation = [self translatedPointForMultiplayer:packet.position];
    }
}

- (void)complexPacketReceived:(ComplexEntityPacket)packet {
    NSNumber* index = [NSNumber numberWithInt:packet.objectID];
    TouchableObject* obj = [objectsReceivedArray objectForKey:index];
    if (obj) {
        obj.remoteLocation = [self translatedPointForMultiplayer:packet.position];
        // obj.objectVelocity = packet.velocity;
        obj.objectRotation = packet.rotation;
    }
}

@end
