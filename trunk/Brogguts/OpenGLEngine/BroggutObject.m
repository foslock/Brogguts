//
//  BroggutObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggutObject.h"
#import "BroggutScene.h"
#import "Image.h"

@implementation BroggutObject
@synthesize broggutValue, broggutType;

- (id)initWithImage:(Image *)image withLocation:(CGPoint)location {
	self = [super initWithImage:image withLocation:location withObjectType:kObjectBroggutSmallID];
	if (self) {
		broggutValue = 0;
		broggutType = kObjectBroggutSmallID;
        float randomScale = (RANDOM_0_TO_1() * 0.25f) + 0.75f;
        objectImage.scale = Scale2fMake(randomScale, randomScale);
	}
	return self;
}

@end
