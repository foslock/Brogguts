//
//  MainMenuController.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MainMenuController.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "TutorialScene.h"
#import "CampaignScene.h"
#import "OptionsMenuController.h"
#import "SkirmishMenuController.h"
#import "BroggupediaViewController.h"
#import "SavedGameChoiceController.h"
#import "InfoMenuController.h"
#import "MenuHelpController.h"
#import "MapChoiceController.h"
#import "SoundSingleton.h"

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
@synthesize tutorialButton, broggutCountButton, spaceYearButton;
@synthesize broggutCount, spaceYearCount;

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
    [[SoundSingleton sharedSoundSingleton] removeSoundWithKey:kSoundFileNames[kSoundFileMenuButtonPress]];
    [starsArray release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)playButtonSound:(id)sender {
    [[SoundSingleton sharedSoundSingleton] playSoundWithKey:kSoundFileNames[kSoundFileMenuButtonPress]];
}

- (IBAction)startTutorialLevels {
    [[GameController sharedGameController] fadeOutToSceneWithFilename:kTutorialSceneFileNames[0] sceneType:kSceneTypeTutorial withIndex:0 isNew:YES isLoading:NO];
}

- (IBAction)startCampaignLevels {
    NSString* path = [[GameController sharedGameController] documentsPathWithFilename:kSavedCampaignFileName];
    NSArray* savedArray = [NSArray arrayWithContentsOfFile:path];
    int playerExperience = [[[GameController sharedGameController] currentProfile] playerExperience];
    if ([savedArray count] != 0 || playerExperience != 0) {
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

- (IBAction)loadInfoViewController; {
    InfoMenuController* info = [[InfoMenuController alloc] init];
    [self presentModalViewController:info animated:YES];
    [info release];
}

- (IBAction)loadProfileViewController {
    NSString* fileNameAlone = [kBaseCampFileName stringByDeletingPathExtension];
    [[GameController sharedGameController] fadeOutToSceneWithFilename:fileNameAlone sceneType:kSceneTypeBaseCamp withIndex:0 isNew:YES isLoading:YES];
}

- (IBAction)loadSkirmishViewController {
    MapChoiceController* mapchoice = [[MapChoiceController alloc] init];
    [mapchoice setOnlineMatch:YES];
    mapchoice.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:mapchoice animated:YES];
    [mapchoice release];
}

- (IBAction)spaceYearButtonPressed {
    MenuHelpController* spaceYear = [[MenuHelpController alloc] initWithNibName:@"SpaceYearController" bundle:nil];
    [spaceYear setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:spaceYear animated:YES];
    [spaceYear release];
}

- (IBAction)broggutCountButtonPressed {
    MenuHelpController* broggutController = [[MenuHelpController alloc] initWithNibName:@"BroggutCountController" bundle:nil];
    [broggutController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:broggutController animated:YES];
    [broggutController release];
}

- (void)animateStars {
    float randomTime = 1.0f + RANDOM_0_TO_1();
    [UIView animateWithDuration:randomTime delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        for (int i = 0; i < [starsArray count]; i++) {
            UIImageView* tempStar = [starsArray objectAtIndex:i];
            float randomAlpha = RANDOM_0_TO_1();
            [tempStar setAlpha:randomAlpha];
        }
    }completion:^(BOOL finished){
        // 
    }];
}

- (void)animateLetters {
    CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    float width = [letterB image].size.width;
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveLinear animations:^{
        float randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        float randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterB setCenter:CGPointMake( center.x - (3.5 * width) + randX, center.y + randY)];
        randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterR setCenter:CGPointMake( center.x - (2.5 * width) + randX, center.y + randY)];
        randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterO setCenter:CGPointMake( center.x - (1.5 * width) + randX, center.y + randY)];
        randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterG1 setCenter:CGPointMake(center.x - (0.5 * width) + randX, center.y + randY)];
        randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterG2 setCenter:CGPointMake(center.x + (0.5 * width) + randX, center.y + randY)];
        randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterU setCenter:CGPointMake( center.x + (1.5 * width) + randX, center.y + randY)];
        randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterT setCenter:CGPointMake( center.x + (2.5 * width) + randX, center.y + randY)];
        randX = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        randY = RANDOM_MINUS_1_TO_1() * LETTER_JITTER_DISTANCE;
        [letterS setCenter:CGPointMake( center.x + (3.5 * width) + randX, center.y + randY)];
    }completion:^(BOOL finished) {
        // if (finished)
            // [self animateLetters];
    }];
}

- (void)updateCountLabels {
    // Update the space year and broggut count labels
    int spaceYear = [[[GameController sharedGameController] currentProfile] playerSpaceYear];
    int brogguts = [[[GameController sharedGameController] currentProfile] totalBroggutCount];
    [broggutCount setText:[NSString stringWithFormat:@"Broggut Count: %i", brogguts]];
    [spaceYearCount setText:[NSString stringWithFormat:@"Space Year: %i A.C.", spaceYear]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    starsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < MAIN_MENU_STAR_COUNT; i++) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"defaultTexture" ofType:@"png"];
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
        UIImageView* tempStar = [[UIImageView alloc] initWithImage:image];
        float randomX = RANDOM_0_TO_1() * kPadScreenLandscapeWidth;
        float randomY = RANDOM_0_TO_1() * kPadScreenLandscapeHeight;
        float randomScale = 0.05f + (RANDOM_0_TO_1() * 0.15f);
        [tempStar setTransform:CGAffineTransformMakeScale(randomScale, randomScale)];
        [tempStar setCenter:CGPointMake(randomX, randomY)];
        [self.view addSubview:tempStar];
        [starsArray addObject:tempStar];
        [image release];
        [tempStar release];
    }
    [self animateStars];
    
    lettersArray = [[NSMutableArray alloc] init];
    [lettersArray addObject:letterB];
    [lettersArray addObject:letterR];
    [lettersArray addObject:letterO];
    [lettersArray addObject:letterG1];
    [lettersArray addObject:letterG2];
    [lettersArray addObject:letterU];
    [lettersArray addObject:letterT];
    [lettersArray addObject:letterS];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[GameController sharedGameController] savePlayerProfile];
     
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
    } completion:^(BOOL finished){
        // if (finished)
        //    [self animateLetters];
    }];
    [self updateCountLabels];
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
