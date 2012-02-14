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
#import "SkirmishMatchController.h"
#import "AchievementIdentifiers.h"
#import "PlayerProfile.h"

static GameCenterSingleton* sharedGCSingleton = nil;

@implementation GameCenterSingleton
@synthesize currentScene, currentMatch;
@synthesize otherPlayerID, localPlayerID, localPlayerAlias, otherPlayerAlias;
@synthesize matchStarted, sceneStarted, hostedFileName;
@synthesize localConfirmed, remoteConfirmed;

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

- (oneway void)release
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
    [achievementDictionary release];
    [localPlayerAlias release];
    [otherPlayerAlias release];
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
            
#ifdef RESET_ACHIEVEMENTS_ON_START
            // Purely for debugging
            [self resetAllAchievements];
#endif
            
			[self.view setBackgroundColor:[UIColor clearColor]];
			sharedGameController = [GameController sharedGameController];
            objectsReceivedArray = [[NSMutableDictionary alloc] init];
            achievementDictionary = [[NSMutableDictionary alloc] init];
			matchStarted = NO;
            sceneStarted = NO;
            localConfirmed = NO;
            remoteConfirmed = NO;
            otherPlayerArrayID = nil;
            localPlayerAlias = nil;
            otherPlayerAlias = nil;
            
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

// Always use messages to get the current scene!
- (BroggutScene*)currentScene {
    if (!currentScene) {
        currentScene = [[GameController sharedGameController] currentScene];
    }
    if (!currentScene) {
        currentScene = [[GameController sharedGameController] justMadeScene];
    }
    return currentScene;
}

- (void)authenticateLocalPlayer
{
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error == nil)
		{
            [self loadAchievements];
            self.localPlayerID = [[GKLocalPlayer localPlayer] playerID];
            self.localPlayerAlias = [[GKLocalPlayer localPlayer] alias];
			NSLog(@"Authentication was successful!");
            NSLog(@"I am Player: %@", localPlayerID);
			// Insert code here to handle a successful authentication.
            
            /*
             NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:GAME_CENTER_ACHIEVEMENT_UPDATE_FREQUENCY target:self selector:@selector(updateAllAchievementsAndLeaderboard) userInfo:nil repeats:YES];
             (void)timer;
             */
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
            NSLog(@"Error processing the names: %@", [error localizedDescription]);
            // Handle the error.
        }
        if (players != nil)
        {
            // Process the array of GKPlayer objects.
            for (GKPlayer* player in players) {
                NSString* playerID = [player playerID];
                if ([playerID caseInsensitiveCompare:localPlayerID] == NSOrderedSame) {
                    self.localPlayerAlias = [player alias];
                }
                if ([playerID caseInsensitiveCompare:otherPlayerID] == NSOrderedSame) {
                    self.otherPlayerAlias = [player alias];
                }
            }
            [matchController setPlayerText];
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
    [self setHostedFileName:filename];
    
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
	NSLog(@"Match finding failed: %@", [error localizedDescription]);
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Uh oh!" message:@"There were no games found!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    // Display the error to the user.
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    self.currentMatch = match; // Use a retaining property to retain the match.
	currentMatch.delegate = self;
    
    // Start the game using the match.
    if (!self.matchStarted && match.expectedPlayerCount == 0)
    {
        [self loadPlayerData:[match playerIDs]];
        [self openMatchController];
    }
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
	NSLog(@"Match changed state...");
    self.localPlayerID = [[GKLocalPlayer localPlayer] playerID];
    switch (state)
    {
        case GKPlayerStateConnected:
            // handle a new player connection.
			NSLog(@"Player connected: %@", playerID);
            if ([playerID caseInsensitiveCompare:localPlayerID] != NSOrderedSame) {
                self.otherPlayerID = playerID;
                otherPlayerArrayID = [[NSArray alloc] initWithObjects:otherPlayerID, nil];
            }
            if (!self.matchStarted && match.expectedPlayerCount == 0)
            {
                [self loadPlayerData:[match playerIDs]];
                [self openMatchController];
                // handle initial match negotiation.
            }
			break;
        case GKPlayerStateDisconnected:
			NSLog(@"Player left: %@", playerID);
            [currentMatch disconnect];
            [[self currentScene] otherPlayerDisconnected];
            // a player just disconnected.
			break;
    }
}

- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    NSLog(@"Transmission Failed with player: %@", playerID);
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (CGPoint)translatedPointForMultiplayer:(Vector2f)point {
    CGRect bounds = [[self currentScene] fullMapBounds];
    CGPoint newPoint = CGPointMake(bounds.size.width - point.x, point.y);
    return newPoint;
}

#pragma mark -- Update Achievements' status

- (void)updateBroggutCountAchievements:(int)brogguts {
    { // 100
        float broggutGoal = 100;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID100Brogguts percentComplete:percentage];
    }
    { // 1000
        float broggutGoal = 1000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID1000Brogguts percentComplete:percentage];
    }
    { // 5000
        float broggutGoal = 5000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID5000Brogguts percentComplete:percentage];
    }
    { // 10,000
        float broggutGoal = 10000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID10000Brogguts percentComplete:percentage];
    }
    { // 25,000
        float broggutGoal = 25000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID25000Brogguts percentComplete:percentage];
    }
    { // 31,415
        float broggutGoal = 31415;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        if (currentCount > 31410) {
            [self reportAchievementIdentifier:(NSString*)kAchievementID31415Brogguts percentComplete:percentage];
        }
    }
    { // 50,000
        float broggutGoal = 50000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID50000Brogguts percentComplete:percentage];
    }
    { // 100,000
        float broggutGoal = 100000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID100000Brogguts percentComplete:percentage];
    }
    { // 500,000
        float broggutGoal = 500000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID500000Brogguts percentComplete:percentage];
    }
    { // 1,000,000
        float broggutGoal = 1000000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID1000000Brogguts percentComplete:percentage];
    }
    { // 10,000,000
        float broggutGoal = 10000000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID10000000Brogguts percentComplete:percentage];
    }
    { // 100,000,000
        float broggutGoal = 100000000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID100000000Brogguts percentComplete:percentage];
    }
    { // 500,000,000
        float broggutGoal = 500000000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID500000000Brogguts percentComplete:percentage];
    }
    { // 1,000,000,000
        float broggutGoal = 1000000000;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID1000000000Brogguts percentComplete:percentage];
    }
    { // 1,000,000,100
        float broggutGoal = 1000000100;
        float currentCount = brogguts;
        float percentage = CLAMP(currentCount / broggutGoal, 0.0f, 1.0f) * 100.0f;
        if (currentCount > 1000000000) {
            [self reportAchievementIdentifier:(NSString*)kAchievementID1000000100Brogguts percentComplete:percentage];
        }
    }
}

- (void)updateCraftBuiltAchievements:(int)craft {
    { // 25
        float craftGoal = 25;
        float currentCount = craft;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID25Craft percentComplete:percentage];
    }
    { // 50
        float craftGoal = 50;
        float currentCount = craft;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID50Craft percentComplete:percentage];
    }
    { // 100
        float craftGoal = 100;
        float currentCount = craft;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID100Craft percentComplete:percentage];
    }
    { // 200
        float craftGoal = 200;
        float currentCount = craft;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementID200Craft percentComplete:percentage];
    }
}

- (void)updateCompleteAllMissionsAchievement:(int)missionsWon {
    { // 15
        float craftGoal = 15;
        float currentCount = missionsWon;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementIDWinAllMissions percentComplete:percentage];
    }
}

- (void)updateBaseCampKillsAchievement:(int)kills {
    { // Base camp kills
        float craftGoal = 100; // Need to get the total enemies that started in the BaseCamp
        float currentCount = kills;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementIDWinBaseCamp percentComplete:percentage];
    }
}

- (void)updateCraftUnlockAchievement:(int)unlockedCraft {
    { // 8 Total craft
        float craftGoal = 8; // Need to get the total enemies that started in the BaseCamp
        float currentCount = unlockedCraft;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementIDUnlockCraft percentComplete:percentage];
    }
}

- (void)updateStructuresUnlockAchievement:(int)unlockedStructures {
    { // 8 Total structures
        float craftGoal = 8; // Need to get the total enemies that started in the BaseCamp
        float currentCount = unlockedStructures;
        float percentage = CLAMP(currentCount / craftGoal, 0.0f, 1.0f) * 100.0f;
        [self reportAchievementIdentifier:(NSString*)kAchievementIDUnlockStructures percentComplete:percentage];
    }
}

- (void)updateAllAchievementsAndLeaderboard {
    if (localPlayerAlias) { // If logged in, submit data
        BroggutScene* scene = [self currentScene];
        PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
        if (scene && profile) {
            // Update acheivements
            [self updateBroggutCountAchievements:[profile totalBroggutCount]];
            [self updateCraftBuiltAchievements:scene.numberOfCurrentShips];
            // Others are updated async which is OK
            
            // Update leaderboard
            [self reportScore:[profile totalBroggutCount] forCategory:@"brogguts_leaderboard"];
        }
    }
}

- (void)loadAchievements {
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement* achievement in achievements)
                 [achievementDictionary setObject: achievement forKey: achievement.identifier];
         }
     }];
}

- (GKAchievement*)getAchievementForIdentifier:(NSString*)identifier {
    GKAchievement *achievement = [achievementDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        [achievementDictionary setObject:achievement forKey:achievement.identifier];
    }
    return [[achievement retain] autorelease];
}

- (void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent {
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement)
    {
        if ([achievement respondsToSelector:@selector(showsCompletionBanner)]) {
            if (percent > achievement.percentComplete && percent >= 100.0f) {
                achievement.showsCompletionBanner = YES;
            } else {
                achievement.showsCompletionBanner = NO;
            }
        }
        
        achievement.percentComplete = percent;
        
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 // Retain the achievement object and try again later (not shown).
             }
         }];
    }
}

- (void)resetAllAchievements {
    // Clear all locally saved achievement objects.
    [achievementDictionary removeAllObjects];
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil) {
             // handle errors
         }
     }];
}

- (void)reportScore:(int64_t)score forCategory:(NSString*)category {
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // handle the reporting error
        }
    }];
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

- (void)openMatchController {
    [self dismissModalViewControllerAnimated:NO];
    matchController = [[SkirmishMatchController alloc] initWithNibName:@"SkirmishMatchController" bundle:nil];
    [matchController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:matchController animated:NO];
    self.matchStarted = YES;
}

- (void)moveMatchToScene {
    sceneStarted = YES;
    [matchController moveMatchToScene];
    [self.view removeFromSuperview];
}

- (void)disconnectFromGame {
    [currentMatch disconnect];
    [self.view removeFromSuperview];
    [matchController release];
    matchController = nil;
    currentMatch = nil;
    currentScene = nil;
    otherPlayerID = nil;
    otherPlayerArrayID = nil;
    matchStarted = NO;
    sceneStarted = NO;
    localConfirmed = NO;
    remoteConfirmed = NO;
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
	if (currentMatch && matchStarted) {
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
	}
}

- (void)sendComplexPacket:(ComplexEntityPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
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
	}
}

- (void)sendCreationPacket:(CreationPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
		NSError *error = nil;
		packet.packetType = kPacketTypeCreationPacket;
		NSData *data = [NSData dataWithBytes:&packet length:sizeof(CreationPacket)];
        GKMatchSendDataMode mode = GKMatchSendDataReliable;
        if (!required) {
            mode = GKMatchSendDataUnreliable;
        }
        for (NSString* playerID in otherPlayerArrayID) {
            NSLog(@"Sending to player: %@", playerID);
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
	}
}

- (void)sendDestructionPacket:(DestructionPacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
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
	}
}

- (void)sendBroggutUpdatePacket:(BroggutUpdatePacket)packet isRequired:(BOOL)required  {
	if (currentMatch && matchStarted) {
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
        [self matchPacketReceived:receivedMatchPacket];
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
            remoteConfirmed = YES;
        }
            break;
        case kMatchMarkerConfirmStart: {
            remoteConfirmed = YES;
        }
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
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectCraftMothID: {
            MothCraftObject* newCraft = [[MothCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectCraftBeetleID: {
            BeetleCraftObject* newCraft = [[BeetleCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectCraftMonarchID: {
            MonarchCraftObject* newCraft = [[MonarchCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectCraftCamelID: {
            CamelCraftObject* newCraft = [[CamelCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectCraftRatID: {
            RatCraftObject* newCraft = [[RatCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectCraftSpiderID: {
            SpiderCraftObject* newCraft = [[SpiderCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectCraftEagleID: {
            EagleCraftObject* newCraft = [[EagleCraftObject alloc] initWithLocation:location isTraveling:NO];
            [newCraft setRemoteLocation:location];
            [newCraft setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newCraft withColliding:CRAFT_COLLISION_YESNO];
            newCraft.objectImage.flipHorizontally = YES;
            newCraft.isRemoteObject = YES;
            [objectsReceivedArray setObject:newCraft forKey:index];
            [newCraft release];
            break;
        }
        case kObjectStructureBaseStationID: {
            BaseStationStructureObject* newStructure = [[BaseStationStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [[self currentScene] setEnemyBaseLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
            break;
        }
        case kObjectStructureBlockID: {
            BlockStructureObject* newStructure = [[BlockStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
            break;
        }
        case kObjectStructureTurretID: {
            TurretStructureObject* newStructure = [[TurretStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
            break;
        }
        case kObjectStructureRadarID: {
            RadarStructureObject* newStructure = [[RadarStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
            break;
        }
        case kObjectStructureFixerID: {
            FixerStructureObject* newStructure = [[FixerStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
            break;
        }
        case kObjectStructureRefineryID: {
            RefineryStructureObject* newStructure = [[RefineryStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
            break;
        }
        case kObjectStructureCraftUpgradesID: {
            CraftUpgradesStructureObject* newStructure = [[CraftUpgradesStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
            break;
        }
        case kObjectStructureStructureUpgradesID: {
            StructureUpgradesStructureObject* newStructure = [[StructureUpgradesStructureObject alloc] initWithLocation:location isTraveling:NO];
            [newStructure setRemoteLocation:location];
            [newStructure setObjectAlliance:kAllianceEnemy];
            [[self currentScene] addTouchableObject:newStructure withColliding:STRUCTURE_COLLISION_YESNO];
            newStructure.objectImage.flipHorizontally = YES;
            newStructure.isRemoteObject = YES;
            [objectsReceivedArray setObject:newStructure forKey:index];
            [newStructure release];
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
    MediumBroggut* broggut = [[[self currentScene] collisionManager] broggutCellForLocation:newPoint];
    [[[self currentScene] collisionManager] setBroggutValue:packet.newValue withID:broggut->broggutID isRemote:YES];
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
