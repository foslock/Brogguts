//
//  MainMenuController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#define LETTER_MOVE_TIME 2.0f
#define MAIN_MENU_ANIMATED_STAR_COUNT 0
#define MAIN_MENU_STATIC_STAR_COUNT 600
#define LETTER_JITTER_DISTANCE 8.0f

extern NSString* const kTutorialExperienceKey;

@interface MainMenuController : UIViewController <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, UIAlertViewDelegate> {
    NSMutableArray* lettersArray;
    UIImageView* letterB;
    UIImageView* letterR;
    UIImageView* letterO;
    UIImageView* letterG1;
    UIImageView* letterG2;
    UIImageView* letterU;
    UIImageView* letterT;
    UIImageView* letterS;
    UIButton* broggupediaButton;
    UIButton* campaignButton;
    UIButton* skirmishButton;
    UIButton* basecampButton;
    UIButton* settingsButton;
    UIButton* infoButton;
    UIButton* tutorialButton;
    UIButton* broggutCountButton;
    UIButton* spaceYearButton;
    UILabel* broggutCount;
    UILabel* spaceYearCount;
    
    BOOL hasStartedTutorial;
    BOOL hasStartedBaseCamp;
    BOOL isShowingRecommendation;
    int tutorialExperience;
    UIView* fadeCoverView;
    UIImageView* recommendationView;
    
    UIActivityIndicatorView* spinnerView;
    
    UIImageView* backgroundImage;
    
    NSMutableArray* starsArray;
}

@property (assign) IBOutlet UIImageView* backgroundImage;
@property (assign) IBOutlet UIImageView* letterB;
@property (assign) IBOutlet UIImageView* letterR;
@property (assign) IBOutlet UIImageView* letterO;
@property (assign) IBOutlet UIImageView* letterG1;
@property (assign) IBOutlet UIImageView* letterG2;
@property (assign) IBOutlet UIImageView* letterU;
@property (assign) IBOutlet UIImageView* letterT;
@property (assign) IBOutlet UIImageView* letterS;
@property (assign) IBOutlet UIButton* broggupediaButton;
@property (assign) IBOutlet UIButton* campaignButton;
@property (assign) IBOutlet UIButton* skirmishButton;
@property (assign) IBOutlet UIButton* basecampButton;
@property (assign) IBOutlet UIButton* settingsButton;
@property (assign) IBOutlet UIButton* infoButton;
@property (assign) IBOutlet UIButton* tutorialButton;
@property (assign) IBOutlet UIButton* broggutCountButton;
@property (assign) IBOutlet UIButton* spaceYearButton;
@property (assign) IBOutlet UILabel* broggutCount;
@property (assign) IBOutlet UILabel* spaceYearCount;
@property (assign) IBOutlet UIImageView* recommendationView;

- (void)animateLetters;

- (void)updateCountLabels;

- (IBAction)playButtonSound:(id)sender;
- (IBAction)loadOptionsViewController;
- (IBAction)loadInfoViewController;
- (IBAction)startTutorialLevels;
- (IBAction)openBroggupedia;
- (IBAction)startCampaignLevels;
- (IBAction)showAchievementController;
- (IBAction)showLeaderboardController;
- (IBAction)loadProfileViewController;
- (IBAction)loadSkirmishViewController;
- (IBAction)spaceYearButtonPressed;
- (IBAction)broggutCountButtonPressed;

- (void)makeSpinnerAppear;

@end
