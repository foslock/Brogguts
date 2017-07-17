//
//  SplashScreenViewController.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/31/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SplashScreenViewController : UIViewController {
    BOOL didSkipIntro;
}

@property (retain) IBOutlet UIImageView* defaultSplash;
@property (retain) IBOutlet UIImageView* logoSplash;
@property (retain) IBOutlet UIImageView* maskSplash;

- (void)fadeDefaultOut;
- (void)turnLogoSplashOn;
- (void)fadeLogoIn;
- (void)turnLogoOff;
- (void)endSplashSequence;

@end
