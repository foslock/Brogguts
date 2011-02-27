//
//  TurretStructure.h
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StructureObject.h"

@interface TurretStructureObject : StructureObject {
	// Attacking vars
	int attackCooldownTimer;
	CGPoint attackLaserTargetPosition;
	int attributeAttackCooldown;
	int attributeWeaponsDamage;
	int attributeAttackRange;
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling;

- (void)attackTarget;

@end
