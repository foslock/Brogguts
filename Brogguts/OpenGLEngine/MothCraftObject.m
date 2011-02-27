//
//  MothCraftObject.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "MothCraftObject.h"


@implementation MothCraftObject


- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectCraftMothID withLocation:location isTraveling:traveling];
	if (self) {
		
	}
	return self;
}


@end
