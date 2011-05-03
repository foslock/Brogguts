//
//  TurretStructure.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/24/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TurretStructureObject.h"
#import "ParticleSingleton.h"
#import "Image.h"

@implementation TurretStructureObject

- (void)dealloc {
    [turretGunImage release];
    [super dealloc];
}

- (id)initWithLocation:(CGPoint)location isTraveling:(BOOL)traveling {
	self = [super initWithTypeID:kObjectStructureTurretID withLocation:location isTraveling:traveling];
	if (self) {
		isCheckedForRadialEffect = YES;
		effectRadius = kStructureTurretAttackRange;
		attributeAttackCooldown = kStructureTurretAttackCooldown;
		attributeWeaponsDamage = kStructureTurretWeapons;
		attributeAttackRange = kStructureTurretAttackRange;
		attackCooldownTimer = 0;
        turretGunImage = [[Image alloc] initWithImageNamed:@"spriteturretgun.png" filter:GL_LINEAR];
        [turretGunImage setRotation:45.0f];
	}
	return self;
}

- (void)attackTarget {
	if (closestEnemyObject) {
		if (GetDistanceBetweenPoints(objectLocation, closestEnemyObject.objectLocation) <= attributeAttackRange) {
			if (attackCooldownTimer == 0 && !closestEnemyObject.destroyNow) {
				CGPoint enemyPoint = closestEnemyObject.objectLocation;
				attackLaserTargetPosition = CGPointMake(enemyPoint.x + (RANDOM_MINUS_1_TO_1() * 20.0f),
														enemyPoint.y + (RANDOM_MINUS_1_TO_1() * 20.0f));
				[[ParticleSingleton sharedParticleSingleton] createParticles:10 withType:kParticleTypeSpark atLocation:attackLaserTargetPosition];
                float direction = GetAngleInDegreesFromPoints(objectLocation, attackLaserTargetPosition);
                [turretGunImage setRotation:direction];
				attackCooldownTimer = attributeAttackCooldown;
				if ([closestEnemyObject attackedByEnemy:self withDamage:attributeWeaponsDamage]) {
					[self setClosestEnemyObject:nil];
				}
			}
		}
	}
}

- (void)updateObjectLogicWithDelta:(float)aDelta {
	// Attack if able!
	if (attackCooldownTimer > 0) {
		attackCooldownTimer--;
	} else {
		[self attackTarget];
	}
	
	[super updateObjectLogicWithDelta:aDelta];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
    [super renderCenteredAtPoint:aPoint withScrollVector:vector];
    [turretGunImage renderCenteredAtPoint:aPoint withScrollVector:vector];
}

- (void)renderOverObjectWithScroll:(Vector2f)scroll {
    [super renderOverObjectWithScroll:scroll];
    enablePrimitiveDraw();
	
	// Draw the laser attack
	if (GetDistanceBetweenPoints(objectLocation, closestEnemyObject.objectLocation) <= effectRadius) {
		float width = CLAMP((10.0f * (float)(attackCooldownTimer - (attributeAttackCooldown / 2)) / (float)attributeAttackCooldown), 0.0f, 10.0f);
		if (width != 0.0f) {
			if (objectAlliance == kAllianceFriendly)
				glColor4f(0.2f, 1.0f, 0.2f, 0.8f);
			if (objectAlliance == kAllianceEnemy)
				glColor4f(1.0f, 0.2f, 0.2f, 0.8f);
			glLineWidth(width);
			drawLine(objectLocation, attackLaserTargetPosition, scroll);
			glLineWidth(1.0f);
		}
	}
	disablePrimitiveDraw();
}

@end
