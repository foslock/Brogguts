//
//  MainMenuController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MainMenuController.h"
#import "GameController.h"
#import "TutorialScene.h"
#import "CampaignScene.h"
#import "OptionsMenuController.h"
#import "ProfileMenuController.h"
#import "SkirmishMenuController.h"
#import "BroggupediaObject.h"

@implementation MainMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (IBAction)startTutorialLevels {
    [[GameController sharedGameController] loadTutorialLevelsForIndex:0];
    [[GameController sharedGameController] transitionToSceneWithFileName:kTutorialSceneFileNames[0] sceneType:kSceneTypeTutorial isNew:NO];
}

- (IBAction)startCampaignLevels {
    [[GameController sharedGameController] loadCampaignLevelsForIndex:0];
    [[GameController sharedGameController] transitionToSceneWithFileName:kCampaignSceneFileNames[0] sceneType:kSceneTypeCampaign isNew:NO];
}

- (IBAction)openBroggupedia {
    BroggupediaObject* object = [[BroggupediaObject alloc] init];
    // UIModalPresentationStyle style = [self modalPresentationStyle];
    // [self setModalPresentationStyle:UIModalPresentationFormSheet];
    // [self setModalPresentationStyle:style];
    [object release];
}

- (IBAction)loadOptionsViewController {
    OptionsMenuController* options = [[OptionsMenuController alloc] init];
    [self presentModalViewController:options animated:YES];
    [options release];
}

- (IBAction)loadProfileViewController {
    ProfileMenuController* profile = [[ProfileMenuController alloc] init];
    [self presentModalViewController:profile animated:YES];
    [profile release];
}

- (IBAction)loadSkirmishViewController {
    SkirmishMenuController* skirmish = [[SkirmishMenuController alloc] init];
    [self presentModalViewController:skirmish animated:YES];
    [skirmish release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

@end
