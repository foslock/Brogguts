//
//  BroggutObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BroggutObject.h"


@implementation BroggutObject
@synthesize broggutValue, broggutType;

- (id)initWithImage:(Image *)image withLocation:(CGPoint)location withObjectType:(int)objecttype {
	self = [super initWithImage:image withLocation:location withObjectType:objecttype];
	if (self) {
		broggutValue = 0;
		broggutType = kObjectBroggutSmallID;
	}
	return self;
}

@end
