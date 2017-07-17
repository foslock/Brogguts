//
//  SkirmishMatchController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 5/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SkirmishMatchController.h"
#import "GameCenterSingleton.h"
#import "GameController.h"
#import "OpenGLEngineAppDelegate.h"

@implementation SkirmishMatchController
@synthesize versusLabel, cancelButton, confirmButton, spinner, waitingLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sharedGCSingleton = [GameCenterSingleton sharedGCSingleton];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)cancelPressed:(id)sender {
    [sharedGCSingleton disconnectFromGame];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)confirmPressed:(id)sender {
    if (!sharedGCSingleton.localConfirmed) {
        [spinner setHidden:NO];
        [spinner startAnimating];
        [waitingLabel setHidden:NO];
        sharedGCSingleton.localConfirmed = YES;
        // Send the request packet
        MatchPacket packet;
        packet.packetType = kPacketTypeMatchPacket;
        packet.matchMarker = kMatchMarkerRequestStart;
        [[GameCenterSingleton sharedGCSingleton] sendMatchPacket:packet isRequired:YES];
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                 target:[GameController sharedGameController]
                                               selector:@selector(checkForRemotePlayer:)
                                               userInfo:nil
                                                repeats:YES];
        (void)timer;
    }
}

- (void)moveMatchToScene {
    [(OpenGLEngineAppDelegate*)[[UIApplication sharedApplication] delegate] startGLAnimation];
    [[GameController sharedGameController] fadeOutToSceneWithFilename:sharedGCSingleton.hostedFileName
                                                            sceneType:kSceneTypeSkirmish
                                                            withIndex:0
                                                                isNew:YES
                                                            isLoading:NO];
    [self dismissModalViewControllerAnimated:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setPlayerText];
    // Do any additional setup after loading the view from its nib.
}

- (void)setPlayerText {
    NSString* localName = [sharedGCSingleton localPlayerAlias];
    NSString* enemyName = [sharedGCSingleton otherPlayerAlias];
    if (!enemyName) {
        enemyName = [NSString stringWithFormat:@"?"];
    }
    if (!localName) {
        localName = [NSString stringWithFormat:@"?"];
    }
    [versusLabel setText:[NSString stringWithFormat:@"%@ vs. %@", localName, enemyName]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
