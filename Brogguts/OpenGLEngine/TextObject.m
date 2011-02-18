//
//  TextObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/11/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TextObject.h"
#import "BitmapFont.h"

@implementation TextObject
@synthesize isHidden, fontID, objectText, scrollWithBounds;

- (void)dealloc {
	[objectText release];
	[super dealloc];
}

- (id)initWithFontID:(int)fontid Text:(NSString*)string withLocation:(CGPoint)location withDuration:(float)duration {
	self = [super initWithImage:nil withLocation:location withObjectType:kObjectTextID];
	if (self) {
		isHidden = NO;
		scrollWithBounds = YES; // Defaults to staying in the absolute bounds
		fontID = fontid;
		isTextObject = YES;
		fontColor = Color4fMake(1.0f, 1.0f, 1.0f, 1.0f);
		destroyNow = NO;
		timeLeft = duration;
		fadeTime = duration / 3; // By default 2/3 through the duration
		isCheckedForCollisions = NO;
		fontScale = Scale2fMake(1.0f, 1.0f);
		self.objectText = string;
	}
	return self;
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	if (timeLeft != -1.0f) {
		timeLeft -= aDelta;
		if (timeLeft < fadeTime) {
			fontColor = Color4fMake(1.0f, 1.0f, 1.0f, CLAMP(timeLeft / fadeTime, 0.0f, 1.0f));
		}
		if (timeLeft <= 0.0f) {
			destroyNow = YES;
		}
	}
	[super updateObjectLogicWithDelta:aDelta];
}

- (void)renderWithFont:(BitmapFont*)font {
	if (isHidden) return;
	Color4f savedColor = [font fontColor];
	[font setFontColor:fontColor];
	[font renderStringAt:objectLocation text:self.objectText];
	[font setFontColor:savedColor];
}

- (void)renderWithFont:(BitmapFont*)font withScrollVector:(Vector2f)scroll {
	if (isHidden) return;
	CGPoint location = CGPointMake(objectLocation.x - scroll.x, objectLocation.y - scroll.y);
	Color4f savedColor = [font fontColor];
	[font setFontColor:fontColor];
	[font renderStringAt:location text:self.objectText];
	[font setFontColor:savedColor];
}

@end
