//
//  PathNode.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/25/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PathNode : NSObject {
	CGPoint nodeLocation;
	float costFromStart;
}

@property (assign) CGPoint nodeLocation;
@property (assign) float costFromStart;

@end
