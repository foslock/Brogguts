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
#import "BroggupediaViewController.h"
#import "SavedGameChoiceController.h"

@implementation MainMenuController
@synthesize backgroundOne, backgroundTwo, backgroundThree;
@synthesize letterB;
@synthesize letterR;
@synthesize letterO;
@synthesize letterG1;
@synthesize letterG2;
@synthesize letterU;
@synthesize letterT;
@synthesize letterS;
@synthesize broggupediaButton;
@synthesize campaignButton;
@synthesize skirmishButton;
@synthesize basecampButton;
@synthesize settingsButton;
@synthesize infoButton;
@synthesize tutorialButton;

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
    [[GameController sharedGameController] fadeOutToSceneWithFilename:kTutorialSceneFileNames[0] sceneType:kSceneTypeTutorial withIndex:0 isNew:YES isLoading:NO];
}

- (IBAction)startCampaignLevels {
    NSString* path = [[GameController sharedGameController] documentsPathWithFilename:kSavedCampaignFileName];
    NSArray* savedArray = [NSArray arrayWithContentsOfFile:path];
    if ([savedArray count] != 0) {
        SavedGameChoiceController* controller = [[SavedGameChoiceController alloc] init];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:controller animated:YES];
        [controller release];
    } else {
        [[GameController sharedGameController] fadeOutToSceneWithFilename:kCampaignSceneFileNames[0] sceneType:kSceneTypeCampaign withIndex:0 isNew:YES isLoading:NO];
    }
}

- (IBAction)openBroggupedia {
    [[GameController sharedGameController] presentBroggupedia];
}

- (IBAction)loadOptionsViewController {
    OptionsMenuController* options = [[OptionsMenuController alloc] init];
    [self presentModalViewController:options animated:YES];
    [options release];
}

- (IBAction)loadProfileViewController {
    /*
    ProfileMenuController* profile = [[ProfileMenuController alloc] init];
    [self presentModalViewController:profile animated:YES];
    [profile release];
     */
    NSString* fileNameAlone = [kBaseCampFileName stringByDeletingPathExtension];
    [[GameController sharedGameController] fadeOutToSceneWithFilename:fileNameAlone sceneType:kSceneTypeBaseCamp withIndex:0 isNew:NO isLoading:YES];
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
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    
    [backgroundOne setCenter:center];
    [backgroundTwo setCenter:center];
    [backgroundThree setCenter:center];
    
    [backgroundOne setAlpha:0.25f];
    [backgroundTwo setAlpha:0.5f];
    [backgroundThree setAlpha:1.0f];
    
    [backgroundOne setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
    [backgroundTwo setTransform:CGAffineTransformMakeScale(1.2f, 1.2f)];
    [backgroundThree setTransform:CGAffineTransformMakeScale(1.35f, 1.35f)];
    
    [self updateBackgroundsWithTouchLocation:CGPointMake(center.x + 400, center.y + 400.0f)];
    
    float distance = kPadScreenLandscapeWidth;
    float randDir = arc4random() % 360;
    CGPoint randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                                    center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterB setCenter:randPoint];
    randDir = arc4random() % 360;
    randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                            center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterR setCenter:randPoint];
    randDir = arc4random() % 360;
    randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                            center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterO setCenter:randPoint];
    randDir = arc4random() % 360;
    randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                            center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterG1 setCenter:randPoint];
    randDir = arc4random() % 360;
    randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                            center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterG2 setCenter:randPoint];
    randDir = arc4random() % 360;
    randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                            center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterU setCenter:randPoint];
    randDir = arc4random() % 360;
    randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                            center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterT setCenter:randPoint];
    randDir = arc4random() % 360;
    randPoint = CGPointMake(center.x + (distance * cosf(DEGREES_TO_RADIANS(randDir))), 
                            center.y + (distance * sinf(DEGREES_TO_RADIANS(randDir))));
    [letterS setCenter:randPoint];
    float width = [letterB image].size.width;
    [UIView animateWithDuration:LETTER_MOVE_TIME delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [letterB setCenter:CGPointMake( center.x - (3.5 * width), center.y)];
        [letterR setCenter:CGPointMake( center.x - (2.5 * width), center.y)];
        [letterO setCenter:CGPointMake( center.x - (1.5 * width), center.y)];
        [letterG1 setCenter:CGPointMake(center.x - (0.5 * width), center.y)];
        [letterG2 setCenter:CGPointMake(center.x + (0.5 * width), center.y)];
        [letterU setCenter:CGPointMake( center.x + (1.5 * width), center.y)];
        [letterT setCenter:CGPointMake( center.x + (2.5 * width), center.y)];
        [letterS setCenter:CGPointMake( center.x + (3.5 * width), center.y)];
    } completion:nil];
}

- (void)updateBackgroundsWithTouchLocation:(CGPoint)location {
    CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    float dx = location.x - center.x;
    float dy = location.y - center.y;
    [backgroundOne setCenter:CGPointMake(center.x + (dx * 0.5f), center.y + (dy * 0.5f))];
    [backgroundTwo setCenter:CGPointMake(center.x + (dx * 0.25f), center.y + (dy * 0.25f))];
    [backgroundThree setCenter:CGPointMake(center.x + (dx * 0.1f), center.y + (dy * 0.1f))];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    [self updateBackgroundsWithTouchLocation:[touch locationInView:self.view]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    [self updateBackgroundsWithTouchLocation:[touch locationInView:self.view]];
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
