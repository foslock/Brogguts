//
//  RatCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "RatCraftObject.h"


@implementation RatCraftObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftRatID withLocation:location isTraveling:traveling];
	if (self) {
		
	}
	return self;
}

@end
