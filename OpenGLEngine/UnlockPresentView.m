//
//  UnlockPresentView.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/25/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "UnlockPresentView.h"
#import "GameController.h"
#import "PlayerProfile.h"
#import "Image.h"
#import "UpgradeManager.h"
#import "Global.h"

@implementation UnlockPresentView
@synthesize view, craftOneView, craftTwoView, craftOneLabel, craftTwoLabel;
@synthesize structureOneView, structureTwoView, structureOneLabel, structureTwoLabel;
@synthesize upgradeOneView, upgradeTwoView, upgradeOneLabel, upgradeTwoLabel, plusOneView, plusTwoView;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code.
        
        [[NSBundle mainBundle] loadNibNamed:@"UnlockView" owner:self options:nil];
        [self addSubview:self.view];
        
        // Observe orientation change notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
        [self orientationChanged:nil];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"UnlockView" owner:self options:nil];
    [self addSubview:self.view];
    
    // Observe orientation change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [self orientationChanged:nil];
}

- (void) dealloc
{
    // Remove our observation of the device orientation notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [craftOneView release];
    [craftOneLabel release];
    [craftTwoView release];
    [craftTwoLabel release];
    
    [structureOneView release];
    [structureOneLabel release];
    [structureTwoView release];
    [structureTwoLabel release];
    
    [upgradeOneView release];
    [upgradeOneLabel release];
    [upgradeTwoView release];
    [upgradeTwoLabel release];
    
    [plusOneView release];
    [plusTwoView release];
    
    [view release];
    [super dealloc];
}

- (void)setImageView:(UIImageView*)iView withImage:(UIImage*)image {
    if (image.size.width <= iView.frame.size.width &&
        image.size.height <= iView.frame.size.height) {
        // Fits in image!
        [iView setContentMode:UIViewContentModeCenter];
    } else {
        [iView setContentMode:UIViewContentModeScaleAspectFit];
    }
    // Add spinner in BG
    UIImageView* sunView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spinningsun.png"]];
    [sunView setAlpha:0.1f];
    [self.view addSubview:sunView];
    [self.view sendSubviewToBack:sunView];
    [sunView setCenter:iView.center];
    [UIView animateWithDuration:(RANDOM_0_TO_1() + 1.5f) delay:0.0f options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [sunView setTransform:CGAffineTransformRotate(sunView.transform, DEGREES_TO_RADIANS(180))];
    } completion:^(BOOL finished) {
        //
    }];
    
    [sunView release];
    [iView setImage:image];
}

- (BOOL)setUnlocksForNextSceneIndex:(int)nextIndex {
    BOOL isAnyNewUnlocks = NO;
    PlayerProfile* profile = [[GameController sharedGameController] currentProfile];
    
    // Go through each craft and see if something is going to be unlocked
    int count = 0;
    [craftOneLabel setText:@""];
    [craftTwoLabel setText:@""];
    for (int i = kObjectCraftAntID; i <= kObjectCraftEagleID; i++) {
        int unlockTime = [profile levelObjectUnlockedWithID:i];
        if (unlockTime == nextIndex
            && ![profile isObjectUnlockedWithID:i]) {
            if (count == 0) {
                isAnyNewUnlocks = YES;
                UIImage* image = [UIImage imageNamed:[Image fileNameForObjectWithID:i]];
                [self setImageView:craftOneView withImage:image];
                NSString* name = [UpgradeManager formalNameForObjectWithID:i];
                [craftOneLabel setText:name];
                count++;
            } else {
                UIImage* image = [UIImage imageNamed:[Image fileNameForObjectWithID:i]];
                [self setImageView:craftTwoView withImage:image];
                NSString* name = [UpgradeManager formalNameForObjectWithID:i];
                [craftTwoLabel setText:name];
                count++;
                break;
            }
        }
    }
    
    // Same for structures
    count = 0;
    [structureOneLabel setText:@""];
    [structureTwoLabel setText:@""];
    for (int i = kObjectStructureBaseStationID; i <= kObjectStructureRadarID; i++) {
        int unlockTime = [profile levelObjectUnlockedWithID:i];
        if (unlockTime == nextIndex &&
            ![profile isObjectUnlockedWithID:i]) {
            if (count == 0) {
                isAnyNewUnlocks = YES;
                UIImage* image = [UIImage imageNamed:[Image fileNameForObjectWithID:i]];
                [self setImageView:structureOneView withImage:image];
                NSString* name = [UpgradeManager formalNameForObjectWithID:i];
                [structureOneLabel setText:name];
                count++;
            } else {
                UIImage* image = [UIImage imageNamed:[Image fileNameForObjectWithID:i]];
                [self setImageView:structureTwoView withImage:image];
                NSString* name = [UpgradeManager formalNameForObjectWithID:i];
                [structureTwoLabel setText:name];
                count++;
                break;
            }
        }
    }
    
    // Same for upgrades
    count = 0;
    [upgradeOneLabel setText:@""];
    [upgradeTwoLabel setText:@""];
    [plusOneView setHidden:YES];
    [plusTwoView setHidden:YES];
    for (int i = kObjectCraftAntID; i <= kObjectStructureRadarID; i++) {
        int unlockTime = [profile levelUpgradeUnlockedWithID:i];
        if (unlockTime == nextIndex &&
            ![profile isUpgradeUnlockedWithID:i]) {
            if (count == 0) {
                isAnyNewUnlocks = YES;
                [plusOneView setHidden:NO];
                UIImage* image = [UIImage imageNamed:[Image fileNameForObjectWithID:i]];
                [self setImageView:upgradeOneView withImage:image];
                NSString* name = [UpgradeManager formalNameForObjectWithID:i];
                [upgradeOneLabel setText:name];
                count++;
            } else {
                [plusTwoView setHidden:NO];
                UIImage* image = [UIImage imageNamed:[Image fileNameForObjectWithID:i]];
                [self setImageView:upgradeTwoView withImage:image];
                NSString* name = [UpgradeManager formalNameForObjectWithID:i];
                [upgradeTwoLabel setText:name];
                count++;
                break;
            }
        }
    }
    return isAnyNewUnlocks;
}

- (void)orientationChanged:(NSNotification *)notification {
	UIInterfaceOrientation orientation = [[GameController sharedGameController] interfaceOrientation];
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
        CGAffineTransform tran = CGAffineTransformMakeTranslation(kPadScreenLandscapeWidth / 8, 128.0);
        tran = CGAffineTransformTranslate(tran, view.frame.size.height / 2, view.frame.size.width / 2);
        tran = CGAffineTransformRotate(tran, DEGREES_TO_RADIANS(-90));
        tran = CGAffineTransformTranslate(tran, -view.frame.size.width / 2, -view.frame.size.height / 2);
        [self setTransform:tran];
	}
	if (orientation == UIInterfaceOrientationLandscapeRight) {
        CGAffineTransform tran = CGAffineTransformMakeTranslation(kPadScreenLandscapeWidth / 8, 128.0);
        tran = CGAffineTransformTranslate(tran, view.frame.size.height / 2, view.frame.size.width / 2);
        tran = CGAffineTransformRotate(tran, DEGREES_TO_RADIANS(90));
        tran = CGAffineTransformTranslate(tran, -view.frame.size.width / 2, -view.frame.size.height / 2);
        [self setTransform:tran];
	}

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [[GameController sharedGameController] pushUnlockViewOut];
}

@end
