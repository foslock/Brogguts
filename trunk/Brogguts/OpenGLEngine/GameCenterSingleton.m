//
//  GameCenterSingleton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/4/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "GameCenterSingleton.h"

static GameCenterSingleton* sharedGCSingleton = nil;

@implementation GameCenterSingleton
@synthesize currentMatch;
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
	[super dealloc];
}

// Handling Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

// Normal methods

- (id)init {
	self = [super init];
	if (self) {
		if ([self isGameCenterAvailable]) {
			[self authenticateLocalPlayer];
			[self.view setBackgroundColor:[UIColor clearColor]];
			sharedGameController = [GameController sharedGameController];
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

- (IBAction)findAllActivity
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

- (IBAction)hostMatch:(id)sender
{
    GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
    request.minPlayers = 2;
    request.maxPlayers = 2;
	
    GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
    mmvc.matchmakerDelegate = self;
	
    [self presentModalViewController:mmvc animated:YES];
}

- (IBAction)findProgrammaticMatch:(id)sender
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
    // implement any specific code in your application here.
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
	NSLog(@"Match finding failed!");
    [self dismissModalViewControllerAnimated:YES];
    // Display the error to the user.
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [self dismissModalViewControllerAnimated:YES];
    self.currentMatch = match; // Use a retaining property to retain the match.
							   // Start the game using the match.
	currentMatch.delegate = self;

	[self.view removeFromSuperview];
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
	NSLog(@"Match changed state...");
    switch (state)
    {
        case GKPlayerStateConnected:
            // handle a new player connection.
			NSLog(@"Player connected: %s", playerID);
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

// SENDING DATA

- (void)sendSimplePacket:(SimpleEntityPacket)packet {
	if (currentMatch && matchStarted) {
		NSError *error;
		packet.packetType = kPacketTypeSimpleEntity;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(SimpleEntityPacket)];
		[currentMatch sendData:data 
					 toPlayers:[NSArray arrayWithObject:otherPlayerID]
				  withDataMode:GKMatchSendDataUnreliable
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the simple packet");
			// handle the error
		}
	}
}

- (void)sendComplexPacket:(ComplexEntityPacket)packet {
	if (currentMatch && matchStarted) {
		NSError *error;
		packet.packetType = kPacketTypeComplexEntity;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(ComplexEntityPacket)];
		[currentMatch sendData:data 
					 toPlayers:[NSArray arrayWithObject:otherPlayerID]
				  withDataMode:GKMatchSendDataUnreliable
						 error:&error];
		if (error != nil)
		{
			NSLog(@"Can't send the complex packet!");
			// handle the error
		}
	}
}

// RECEIVING DATA

- (void)match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
	
    SimpleEntityPacket receivedSimplePacket = *(SimpleEntityPacket*)[data bytes];
	ComplexEntityPacket receivedComplexPacket = *(ComplexEntityPacket*)[data bytes];
	
    if (((SimpleEntityPacket)receivedSimplePacket).packetType == kPacketTypeSimpleEntity) {

		// handle a simple packet.
		return;
	}
	if (((ComplexEntityPacket)receivedComplexPacket).packetType == kPacketTypeComplexEntity) {
		// handle a simple packet.
		NSLog(@"Received a complex packet!");
		return;
	}
}	

@end
