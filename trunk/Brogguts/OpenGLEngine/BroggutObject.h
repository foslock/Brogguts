//
//  BroggutObject.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/13/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollidableObject.h"

@interface BroggutObject : CollidableObject {
	int broggutValue;
	int broggutType;
}

@property (nonatomic, assign) int broggutValue;
@property (nonatomic, assign) int broggutType;

@end
