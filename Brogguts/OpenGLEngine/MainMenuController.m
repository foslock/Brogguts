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
#import "GameCenterSingleton.h"

@implementation MainMenuController
@synthesize backgroundImage;
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
@synthesize recommendationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        fadeCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kPadScreenLandscapeWidth, kPadScreenLandscapeHeight)];
        [fadeCoverView setUserInteractionEnabled:YES];
        [fadeCoverView setExclusiveTouch:YES];
        [fadeCoverView setAlpha:0.0f];
        [fadeCoverView setBackgroundColor:[UIColor blackColor]];
        starsArray = [[NSMutableArray alloc] init];
        lettersArray = [[NSMutableArray alloc] init];
        hasStartedTutorial = NO;
        isShowingRecommendation = NO;
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:@"hasStartedTutorial"]) {
            hasStartedTutorial = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    [[SoundSingleton sharedSoundSingleton] removeSoundWithKey:kSoundFileNames[kSoundFileMenuButtonPress]];
    [starsArray release];
    [lettersArray release];
    [fadeCoverView release];
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
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"hasStartedTutorial"];
    [defaults synchronize];
    hasStartedTutorial = YES;
    int beginningTutoralIndex = 0; // 0 is default
    [recommendationView setAlpha:0.0f];
    [fadeCoverView setAlpha:0.0f];
    [[GameController sharedGameController]
     fadeOutToSceneWithFilename:kTutorialSceneFileNames[beginningTutoralIndex]
     sceneType:kSceneTypeTutorial
     withIndex:beginningTutoralIndex
     isNew:YES
     isLoading:NO];
}

- (IBAction)startCampaignLevels {
    if (hasStartedTutorial) {
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
    } else {
        // Hasn't started tutorial yet
        if (!isShowingRecommendation) {
            isShowingRecommendation = YES;
            [UIView animateWithDuration:1.0f animations:^{
                [recommendationView setAlpha:1.0f];
                [fadeCoverView setAlpha:0.75f];
            }];
        }
    }
}

- (IBAction)showAchievementController {
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if (achievements != nil)
    {
        achievements.achievementDelegate = self;
        [self presentModalViewController: achievements animated: YES];
    }
    [achievements release];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showLeaderboardController {
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES];
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
    // SKIRMISHES ARE COMING SOON!
    /*
     MapChoiceController* mapchoice = [[MapChoiceController alloc] init];
     [mapchoice setOnlineMatch:YES];
     mapchoice.modalPresentationStyle = UIModalPresentationFormSheet;
     [self presentModalViewController:mapchoice animated:YES];
     [mapchoice release];
     */
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (isShowingRecommendation) {
        isShowingRecommendation = NO;
        [UIView animateWithDuration:1.0f animations:^{
            [recommendationView setAlpha:0.0f];
            [fadeCoverView setAlpha:0.0f];
        }];
    }
}

- (void)updateCountLabels {
    // Update the space year and broggut count labels
    int spaceYear = [[[GameController sharedGameController] currentProfile] playerSpaceYear];
    int brogguts = [[[GameController sharedGameController] currentProfile] totalBroggutCount];
    [broggutCount setText:[NSString stringWithFormat:@"Collected Brogguts: %i", brogguts]];
    [spaceYearCount setText:[NSString stringWithFormat:@"Space Year: %i P.P.", spaceYear]];
    [self reportScore:brogguts forCategory:@"brogguts_leaderboard"];
    [[GameCenterSingleton sharedGCSingleton] updateBroggutCountAchievements:brogguts];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:fadeCoverView];
    for (int i = 0; i < MAIN_MENU_ANIMATED_STAR_COUNT; i++) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"starTexture" ofType:@"png"];
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
        UIImageView* tempStar = [[UIImageView alloc] initWithImage:image];
        float randomX = RANDOM_0_TO_1() * kPadScreenLandscapeWidth;
        float randomY = RANDOM_0_TO_1() * kPadScreenLandscapeHeight;
        float randomAlpha = (float)(arc4random() % 100) / 100.0f;
        float randomScale = 0.05f + (RANDOM_0_TO_1() * 0.15f);
        [tempStar setTransform:CGAffineTransformMakeScale(randomScale, randomScale)];
        [tempStar setCenter:CGPointMake(randomX, randomY)];
        [tempStar setAlpha:randomAlpha];
        [tempStar setUserInteractionEnabled:NO];
        [backgroundImage addSubview:tempStar];
        [starsArray addObject:tempStar];
        [image release];
        [tempStar release];
    }
    
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

- (UIImage*)imageWithRandomStars {
    CGSize size = CGSizeMake(kPadScreenLandscapeWidth, kPadScreenLandscapeHeight);
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    // Draw stars on image
    
    UIImage* starImage = [UIImage imageNamed:@"starTexture.png"];
    
    int starCount = MAIN_MENU_STATIC_STAR_COUNT;
    for (int i = 0; i < starCount; i++) {
        int rSize = (arc4random() % 8) + 1;
        float rAlpha = (float)(arc4random() % 100) / 100.0f;
        int rX = (arc4random() % (int)size.width) + 1;
        int rY = (arc4random() % (int)size.height) + 1;
        CGRect rect = CGRectMake(rX, rY, rSize, rSize);
        CGContextSetAlpha(context, rAlpha);
        CGContextDrawImage(context, rect, [starImage CGImage]);
    }
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [backgroundImage setImage:[self imageWithRandomStars]];
    
    [self.view bringSubviewToFront:fadeCoverView];
    [self.view bringSubviewToFront:recommendationView];
    [self.view bringSubviewToFront:tutorialButton];
    [recommendationView setAlpha:0.0f];
    [fadeCoverView setAlpha:0.0f];
    
    [[GameController sharedGameController] savePlayerProfile];
    
    CGPoint center = CGPointMake(kPadScreenLandscapeWidth / 2, kPadScreenLandscapeHeight / 2);
    
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
    
    // Play menu background music
    if (![[GameController sharedGameController] currentScene]) {
        [[SoundSingleton sharedSoundSingleton] stopMusic];
        [[SoundSingleton sharedSoundSingleton] playMusicWithKey:kMusicFileNames[kMusicFileMenuLoop] timesToRepeat:-1];
    }
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
