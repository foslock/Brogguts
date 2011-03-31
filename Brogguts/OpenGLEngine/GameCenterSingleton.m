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

static GameCenterSingleton* sharedGCSingleton = nil;

@implementation GameCenterSingleton
@synthesize currentScene, currentMatch;
@synthesize otherPlayerID, localPlayerID;
@synthesize matchStarted;

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
	[localPlayerID release];
	[otherPlayerID release];
	[currentMatch release];
    [hostedFileName release];
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
							   // Start the game using the match.
	currentMatch.delegate = self;

    [(OpenGLEngineAppDelegate*)[[UIApplication sharedApplication] delegate] startGLAnimation];
    [[GameController sharedGameController] transitionToSceneWithFileName:hostedFileName isTutorial:NO];
    [[[GameController sharedGameController] currentScene] setIsMultiplayerMatch:YES];
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
			self.otherPlayerID = playerID;
			break;
        case GKPlayerStateDisconnected:
			NSLog(@"Other player left, disconnecting...");
			[currentMatch disconnect];
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

// SENDING DATA

- (void)sendSimplePacket:(SimpleEntityPacket)packet isRequired:(BOOL)required {
	if (currentMatch && matchStarted) {
		NSError *error;
		packet.packetType = kPacketTypeSimpleEntity;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(SimpleEntityPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:[NSArray arrayWithObject:otherPlayerID]
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the simple packet");
			// handle the error
		}
	}
}

- (void)sendComplexPacket:(ComplexEntityPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
		NSError *error;
		packet.packetType = kPacketTypeComplexEntity;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(ComplexEntityPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:[NSArray arrayWithObject:otherPlayerID]
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the complex packet");
			// handle the error
		}
	}
}

- (void)sendCreationPacket:(CreationPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
		NSError *error;
		packet.packetType = kPacketTypeCreationPacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(CreationPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:[NSArray arrayWithObject:otherPlayerID]
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the creation packet");
			// handle the error
		}
	}
}

- (void)sendDestructionPacket:(DestructionPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
		NSError *error;
		packet.packetType = kPacketTypeDestructionPacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(DestructionPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:[NSArray arrayWithObject:otherPlayerID]
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the destruction packet");
			// handle the error
		}
	}
}

- (void)sendBroggutUpdatePacket:(BroggutUpdatePacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
		NSError *error;
		packet.packetType = kPacketTypeBroggutUpdatePacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(BroggutUpdatePacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
		[currentMatch sendData:data 
					 toPlayers:[NSArray arrayWithObject:otherPlayerID]
				  withDataMode:mode
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the broggut update packet");
			// handle the error
		}
	}
}

// RECEIVING DATA

- (void)match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
	const void* dataBytes = [data bytes];
    SimpleEntityPacket receivedSimplePacket = *(SimpleEntityPacket*)dataBytes;
	ComplexEntityPacket receivedComplexPacket = *(ComplexEntityPacket*)dataBytes;
    CreationPacket receivedCreationPacket = *(CreationPacket*)dataBytes;
    DestructionPacket receivedDestructionPacket = *(DestructionPacket*)dataBytes;
    BroggutUpdatePacket receivedBroggutPacket = *(BroggutUpdatePacket*)dataBytes;
	
    if ((receivedSimplePacket).packetType == kPacketTypeSimpleEntity) {
        [self simplePacketReceived:receivedSimplePacket];
		return;
	}
	if ((receivedComplexPacket).packetType == kPacketTypeComplexEntity) {
		[self complexPacketReceived:receivedComplexPacket];
		return;
	}
    if ((receivedCreationPacket).packetType == kPacketTypeCreationPacket) {
		[self creationPacketReceived:receivedCreationPacket];
		return;
	}
    if ((receivedDestructionPacket).packetType == kPacketTypeDestructionPacket) {
		[self destructionPacketReceived:receivedDestructionPacket];
		return;
	}
    if ((receivedBroggutPacket).packetType == kPacketTypeBroggutUpdatePacket) {
		[self broggutUpdatePacketReceived:receivedBroggutPacket];
		return;
	}
}

- (void)creationPacketReceived:(CreationPacket)packet {
    CGPoint location = [self translatedPointForMultiplayer:packet.position];
    NSNumber* index = [NSNumber numberWithInt:packet.objectID];
    TouchableObject* obj = [[AntCraftObject alloc] initWithLocation:location isTraveling:NO];
    obj.objectImage.flipHorizontally = YES;
    [currentScene addTouchableObject:obj withColliding:CRAFT_COLLISION_YESNO];
    [objectsReceivedArray setObject:obj forKey:index];
    NSLog(@"Creation packet received");
}

- (void)destructionPacketReceived:(DestructionPacket)packet {
    int objectID = packet.objectID;
    NSNumber* index = [NSNumber numberWithInt:objectID];
    TouchableObject* obj = [objectsReceivedArray objectForKey:index];
    [obj setDestroyNow:YES];
    [objectsReceivedArray removeObjectForKey:index];
    NSLog(@"Destruction packet received");
}

- (void)broggutUpdatePacketReceived:(BroggutUpdatePacket)packet {
    NSLog(@"Broggut update packet received");
}

- (void)simplePacketReceived:(SimpleEntityPacket)packet {
    NSNumber* index = [NSNumber numberWithInt:packet.objectID];
    TouchableObject* obj = [objectsReceivedArray objectForKey:index];
    if (obj) {
        obj.objectLocation = [self translatedPointForMultiplayer:packet.position];
    }
    NSLog(@"Simple packet received");
}

- (void)complexPacketReceived:(ComplexEntityPacket)packet {
    NSNumber* index = [NSNumber numberWithInt:packet.objectID];
    TouchableObject* obj = [objectsReceivedArray objectForKey:index];
    if (obj) {
        obj.objectLocation = [self translatedPointForMultiplayer:packet.position];
        obj.objectVelocity = packet.velocity;
        obj.objectRotation = packet.rotation;
    }
    NSLog(@"Complex packet received");
}

@end
