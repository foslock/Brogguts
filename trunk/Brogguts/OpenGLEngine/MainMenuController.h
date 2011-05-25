//
//  MainMenuController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/10/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LETTER_MOVE_TIME 2.0f
#define MAIN_MENU_STAR_COUNT 30
#define LETTER_JITTER_DISTANCE 8.0f

@interface MainMenuController : UIViewController {
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
    
    UIImageView* backgroundOne;
    UIImageView* backgroundTwo;
    UIImageView* backgroundThree;
    
    NSMutableArray* starsArray;
}

@property (assign) IBOutlet UIImageView* backgroundOne;
@property (assign) IBOutlet UIImageView* backgroundTwo;
@property (assign) IBOutlet UIImageView* backgroundThree;
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


- (void)animateStars;
- (void)animateLetters;

- (void)updateCountLabels;

- (IBAction)loadOptionsViewController;
- (IBAction)loadInfoViewController;
- (IBAction)startTutorialLevels;
- (IBAction)openBroggupedia;
- (IBAction)startCampaignLevels;
- (IBAction)loadProfileViewController;
- (IBAction)loadSkirmishViewController;
- (IBAction)spaceYearButtonPressed;
- (IBAction)broggutCountButtonPressed;

- (void)updateBackgroundsWithTouchLocation:(CGPoint)location;

@end
