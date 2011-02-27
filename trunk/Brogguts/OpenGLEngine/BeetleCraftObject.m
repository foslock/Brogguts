//
//  BeetleCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "BeetleCraftObject.h"


@implementation BeetleCraftObject

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftBeetleID withLocation:location isTraveling:traveling];
	if (self) {
		
	}
	return self;
}

@end
