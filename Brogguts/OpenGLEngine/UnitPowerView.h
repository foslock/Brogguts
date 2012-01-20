//
//  UnitPowerView.h
//  OpenGLEngine
//
//  Created by James Lockwood on 1/19/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitPowerView : UIView {
    float weaponPower;  // Damage per frame
    float enginePower;  // Engines
    float hullPower;    // Hull
    float radarPower;    // Attack range
    UIView* weaponView;
    UIView* engineView;
    UIView* hullView;
    UIView* radarView;
    float powerBarMaxWidth;
}

// Pass in the ship attribute, it will be scaled down here
- (void)setWeaponPower:(float)weapon enginePower:(float)engine hullPower:(float)hull radarPower:(float)radar;
- (void)animateBarsToPowers;

@end
