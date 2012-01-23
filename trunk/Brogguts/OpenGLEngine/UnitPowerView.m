//
//  UnitPowerView.m
//  OpenGLEngine
//
//  Created by James Lockwood on 1/19/12.
//  Copyright (c) 2012 Games in Dorms. All rights reserved.
//

#import "UnitPowerView.h"

#define POWER_BAR_HEIGHT 20.0f
#define POWER_BAR_BRIGHTNESS 0.8f
#define POWER_BAR_ALPHA 0.7f
#define POWER_BAR_SCALE_LINES_COUNT 5

@implementation UnitPowerView

- (void)dealloc {
    [weaponView release];
    [engineView release];
    [hullView release];
    [radarView release];
    [super dealloc];
}

- (void)initMe {
    powerBarMaxWidth = self.frame.size.width;
    [self setBackgroundColor:[UIColor clearColor]];
    weaponPower = 0.0f;
    enginePower = 0.0f;
    hullPower = 0.0f;
    radarPower = 0.0f;
    
    for (int i = 0; i <= POWER_BAR_SCALE_LINES_COUNT; i++) {
        UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(i * (powerBarMaxWidth / POWER_BAR_SCALE_LINES_COUNT), 0.0f, 2.0f, self.frame.size.height)];
        [lineView setBackgroundColor:[UIColor whiteColor]];
        [lineView setAlpha:0.5f];
        [self addSubview:lineView];
        [lineView release];
    }
    
    weaponView = [[UIView alloc] initWithFrame:CGRectMake(0, 16.0f - (POWER_BAR_HEIGHT/2), 0, POWER_BAR_HEIGHT)];
    engineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.0f - (POWER_BAR_HEIGHT/2), 0, POWER_BAR_HEIGHT)];
    hullView = [[UIView alloc] initWithFrame:CGRectMake(0, 82.0f - (POWER_BAR_HEIGHT/2), 0, POWER_BAR_HEIGHT)];
    radarView = [[UIView alloc] initWithFrame:CGRectMake(0, 115.0f - (POWER_BAR_HEIGHT/2), 0, POWER_BAR_HEIGHT)];
    [weaponView setBackgroundColor:[UIColor redColor]];
    [engineView setBackgroundColor:[UIColor redColor]];
    [hullView setBackgroundColor:[UIColor redColor]];
    [radarView setBackgroundColor:[UIColor redColor]];
    [self addSubview:weaponView];
    [self addSubview:engineView];
    [self addSubview:hullView];
    [self addSubview:radarView];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initMe];
    }
    return self;
}

- (void)setWeaponPower:(float)weapon enginePower:(float)engine hullPower:(float)hull radarPower:(float)radar {
    weaponPower = CLAMP((weapon / (float)kMaximumDamagePerSecondValue) * 60.0f, 0.0f, 1.0f);
    enginePower = CLAMP(engine / (float)kMaximumEnginesValue, 0.0f, 1.0f);
    hullPower = CLAMP(hull / (float)kMaximumHullValue, 0.0f, 1.0f);
    radarPower = CLAMP(radar / (float)kMaximumAttackRangeValue, 0.0f, 1.0f);
}

- (void)animateBarsToPowers {
    
    UIColor* weaponColor = [UIColor colorWithRed:POWER_BAR_BRIGHTNESS-weaponPower green:weaponPower blue:0.0f alpha:POWER_BAR_ALPHA];
    UIColor* engineColor = [UIColor colorWithRed:POWER_BAR_BRIGHTNESS-enginePower green:enginePower blue:0.0f alpha:POWER_BAR_ALPHA];
    UIColor* hullColor = [UIColor colorWithRed:POWER_BAR_BRIGHTNESS-hullPower green:hullPower blue:0.0f alpha:POWER_BAR_ALPHA];
    UIColor* radarColor = [UIColor colorWithRed:POWER_BAR_BRIGHTNESS-radarPower green:radarPower blue:0.0f alpha:POWER_BAR_ALPHA];
    
    [UIView animateWithDuration:0.75f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        // Animate!
        [weaponView setFrame:CGRectMake(weaponView.frame.origin.x, weaponView.frame.origin.y, weaponPower * powerBarMaxWidth, POWER_BAR_HEIGHT)];
        [engineView setFrame:CGRectMake(engineView.frame.origin.x, engineView.frame.origin.y, enginePower * powerBarMaxWidth, POWER_BAR_HEIGHT)];
        [hullView setFrame:CGRectMake(hullView.frame.origin.x, hullView.frame.origin.y, hullPower * powerBarMaxWidth, POWER_BAR_HEIGHT)];
        [radarView setFrame:CGRectMake(radarView.frame.origin.x, radarView.frame.origin.y, radarPower * powerBarMaxWidth, POWER_BAR_HEIGHT)];
        [weaponView setBackgroundColor:weaponColor];
        [engineView setBackgroundColor:engineColor];
        [hullView setBackgroundColor:hullColor];
        [radarView setBackgroundColor:radarColor];
    } completion:^(BOOL finished) {
        // Nothing
    }];
}

@end
