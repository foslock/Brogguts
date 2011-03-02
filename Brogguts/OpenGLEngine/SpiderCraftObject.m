//
//  SpiderCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 3/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "SpiderCraftObject.h"


@implementation SpiderCraftObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftSpiderID withLocation:location isTraveling:traveling];
	if (self) {
		
	}
	return self;
}

@end
