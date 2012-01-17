// This is where are changable constants are, but they are permenant at runtime.

//
// Device Specific Information
//

#define kPadScreenLandscapeWidth 1024.0f
#define kPadScreenLandscapeHeight 768.0f // Without status bar
#define kFrameRateTarget 60.0f

// Sandbox Apple IDs for multiplayer testing (Game Center)
//
// Username: brogguts@gmail.com
// Password: brogguts123
//
// Username: foslock@hotmail.com
// Password: h****s123
//


//
// Testing Definitions
//  - Comment out a line to remove that functionality from the game
//

#define MULTIPLAYER
// #define RESET_ACHIEVEMENTS_ON_START
// #define BOUNDING_DEBUG
// #define DRAW_PATH
#define STARS
#define COLLISIONS
#define GRID
#define BROGGUTS
#define ALL_STRAIGHT_PATHS
#define CRAFT_SHADOWS
// #define STRUCTURE_SHADOWS


//
// Font information
//

enum FontIDs {
	kFontGothicID,
	kFontBlairID,
    kFontGulimID,
    kFontEurostileID,
};

//
// Stars information
//

enum StarValues {
	kStarBrightnessMin = 20, // Percent out of 100 of how bright the star is
	kStarBrightnessMax = 100,
	kStarBrightnessRateMin = 0, // The rate it changes its brightness
	kStarBrightnessRateMax = 5,
	kStarSizeMin = 2, // Size of the star
	kStarSizeMax = 8,
	kStarBottomLayerID = 0,
	kStarBottomLayerSizeMax = 6,
	kStarMiddleLayerID = 1,
	kStarMiddleLayerSizeMax = 12,
	kStarTopLayerID = 2,
	kStarTopLayerSizeMax = 16,
};

//
// ObjectIDs
//

enum AllianceIDs { // When loading a scene, used for deciding enemy or friendly alliances
	kAllianceFriendly,
	kAllianceEnemy,
	kAllianceNeutral,
};

enum ObjectTypeIDs { // When loading a scene, used for parsing
	kObjectTypeBroggut,
	kObjectTypeCraft,
	kObjectTypeStructure,	
};

#define TOTAL_OBJECT_TYPES_COUNT 32

enum ObjectIDs { // How objects are indentified
	kObjectTextID,
	kObjectBroggutSmallID,
	kObjectBroggutMediumYoungID,
	kObjectBroggutMediumOldID,
    kObjectBroggutMediumAncientID,
    kObjectTriggerID,
    kObjectNotificationID,
	kObjectCraftAntID,
	kObjectCraftMothID,
	kObjectCraftBeetleID,
	kObjectCraftMonarchID,
	kObjectCraftCamelID,
	kObjectCraftRatID,
	kObjectCraftSpiderID,
	kObjectCraftSpiderDroneID,
	kObjectCraftEagleID,
	kObjectStructureBaseStationID,
	kObjectStructureBlockID,
	kObjectStructureRefineryID,
	kObjectStructureCraftUpgradesID,
	kObjectStructureStructureUpgradesID,
	kObjectStructureTurretID,
	kObjectStructureFixerID,
    kObjectStructureRadarID,
    kObjectFingerObjectID,
    kObjectExplosionObjectID,
    kObjectBuildingObjectID,
    kObjectTiledButtonID,
    kObjectEndMissionObjectID,
    kObjectStartMissionObjectID,
    kObjectHealthDropObjectID,
    kObjectMissileObjectID,
};

// 
// Craft Specific Information
// 
// Format => kCraft<name><attribute> 

// Max values

enum MaxmimumAttributeValues {
    kMaximumEnginesValue = 6,
    kMaximumWeaponsValue = 6,
    kMaximumAttackRangeValue = 512,
    kMaximumAttackCooldownValue = 100,
};

enum TheAntValues {
	kCraftAntBoundingBoxWidth = 100, // pixels
	kCraftAntBoundingBoxHeight = 50,
	kCraftAntUnlockYears = 0,
	kCraftAntUpgradeUnlockYears = 2,
	kCraftAntUpgradeCost = 100, // brogguts
	kCraftAntUpgradeTime = 20, // seconds
	kCraftAntCostBrogguts = 100,
	kCraftAntCostMetal = 0,
	kCraftAntEngines = 3,
	kCraftAntWeapons = 8, // Damage per attack
	kCraftAntAttackRange = 128, // pixels
	kCraftAntAttackCooldown = 100, // frames for weapon to recharge
	kCraftAntSpecialCoolDown = 0, // frames for special to recharge
	kCraftAntHull = 160,
    kCraftAntViewDistance = 384,
	// Special Values
	kCraftAntCargoSpace = 25, // brogguts
	kCraftAntEnginesBonus = 1,
	kCraftAntMiningCooldown = 10, // (frames / broggut)
    kCraftAntMiningCooldownUpgrade = 6, // (frames / broggut)

};

enum TheMothValues {
	kCraftMothBoundingBoxWidth = 50, // pixels
	kCraftMothBoundingBoxHeight = 50,
	kCraftMothUnlockYears = 1,
	kCraftMothUpgradeUnlockYears = 6,
	kCraftMothUpgradeCost = 100, // brogguts
	kCraftMothUpgradeTime = 20, // seconds
	kCraftMothCostBrogguts = 200,
	kCraftMothCostMetal = 0,
	kCraftMothEngines = 5,
	kCraftMothWeapons = 4,
	kCraftMothAttackRange = 128, // pixels
	kCraftMothAttackCooldown = 30, // frames for weapon to recharge
	kCraftMothSpecialCoolDown = 500, // frames for special to recharge
	kCraftMothHull = 80,
    kCraftMothViewDistance = 384,
	// Special Values
	kCraftMothEvadePercentage = 25, // percent out of 100
};

enum TheBeetleValues {
	kCraftBeetleBoundingBoxWidth = 64, // pixels
	kCraftBeetleBoundingBoxHeight = 80,
	kCraftBeetleUnlockYears = 2,
	kCraftBeetleUpgradeUnlockYears = 7,
	kCraftBeetleUpgradeCost = 100, // brogguts
	kCraftBeetleUpgradeTime = 20, // seconds
	kCraftBeetleCostBrogguts = 200,
	kCraftBeetleCostMetal = 20,
	kCraftBeetleEngines = 2,
	kCraftBeetleWeapons = 12,
	kCraftBeetleAttackRange = 200, // pixels
	kCraftBeetleAttackCooldown = 60, // frames for weapon to recharge
	kCraftBeetleSpecialCoolDown = 500, // frames for special to recharge
	kCraftBeetleHull = 200,
    kCraftBeetleViewDistance = 512,
	// Special Values
    kCraftBeetleMissileDamage = 24,
    kCraftBeetleMissileRange = 400,
};

enum TheMonarchValues {
	kCraftMonarchBoundingBoxWidth = 64, // pixels
	kCraftMonarchBoundingBoxHeight = 64,
	kCraftMonarchUnlockYears = 3,
	kCraftMonarchUpgradeUnlockYears = 8,
	kCraftMonarchUpgradeCost = 100, // brogguts
	kCraftMonarchUpgradeTime = 20, // seconds
	kCraftMonarchCostBrogguts = 300,
	kCraftMonarchCostMetal = 30,
	kCraftMonarchEngines = 3,
	kCraftMonarchWeapons = 0,
	kCraftMonarchAttackRange = 0, // pixels
	kCraftMonarchAttackCooldown = 0, // frames for weapon to recharge
	kCraftMonarchSpecialCoolDown = 1, // frames for special to recharge
	kCraftMonarchHull = 120,
    kCraftMonarchViewDistance = 512,
	// Special Values
	kCraftMonarchAuraRangeLimit = 256,
	kCraftMonarchAuraNumberLimit = 4, // Number of units allowed in squad
    kCraftMonarchAuraResistanceValue = 2,
    // Upgrade
    kCraftMonarchAuraNumberLimitUpgraded = 8, // Number of additional units allowed in squad
    kCraftMonarchAuraResistanceValueUpgraded = 3,
};

// Advanced Craft

enum TheCamelValues {
	kCraftCamelBoundingBoxWidth = 128, // pixels
	kCraftCamelBoundingBoxHeight = 64,
	kCraftCamelUnlockYears = 4,
	kCraftCamelUpgradeUnlockYears = 11,
	kCraftCamelUpgradeCost = 100, // brogguts
	kCraftCamelUpgradeTime = 30, // seconds
	kCraftCamelCostBrogguts = 400,
	kCraftCamelCostMetal = 40,
	kCraftCamelEngines = 3,
	kCraftCamelWeapons = 8,
	kCraftCamelAttackRange = 512, // pixels
	kCraftCamelAttackCooldown = 50, // frames for weapon to recharge
	kCraftCamelSpecialCoolDown = 500, // frames for special to recharge
	kCraftCamelHull = 240,
    kCraftCamelViewDistance = 512,
	// Special Values
	kCraftCamelCargoSpace = 100, // brogguts
	kCraftCamelMiningCooldown = 5, // (frames / broggut)
	kCraftCamelCargoSpaceUpgraded = 200, // So many brogguts
};

enum TheRatValues {
	kCraftRatBoundingBoxWidth = 80, // pixels
	kCraftRatBoundingBoxHeight = 64,
	kCraftRatUnlockYears = 5,
	kCraftRatUpgradeUnlockYears = 10,
	kCraftRatUpgradeCost = 100, // brogguts
	kCraftRatUpgradeTime = 40, // seconds
	kCraftRatCostBrogguts = 500,
	kCraftRatCostMetal = 50,
	kCraftRatEngines = 5,
	kCraftRatWeapons = 12,
	kCraftRatAttackRange = 100, // pixels
	kCraftRatAttackCooldown = 30, // frames for weapon to recharge
	kCraftRatSpecialCoolDown = 500, // frames for special to recharge
	kCraftRatHull = 80,
    kCraftRatViewDistance = 256,
	// Special Values
	kCraftRatViewDistanceUpgraded = 768,
};

enum TheSpiderValues {
	kCraftSpiderBoundingBoxWidth = 160, // pixels
	kCraftSpiderBoundingBoxHeight = 160,
	kCraftSpiderUnlockYears = 7,
	kCraftSpiderUpgradeUnlockYears = 12, // increases movement speed
	kCraftSpiderUpgradeCost = 100, // brogguts
	kCraftSpiderUpgradeTime = 50, // seconds
	kCraftSpiderCostBrogguts = 600,
	kCraftSpiderCostMetal = 60,
	kCraftSpiderEngines = 1,
	kCraftSpiderWeapons = 0,
	kCraftSpiderAttackRange = 512, // pixels
	kCraftSpiderAttackCooldown = 0, // frames for weapon to recharge
	kCraftSpiderSpecialCoolDown = 500, // frames for special to recharge
	kCraftSpiderHull = 400,
    kCraftSpiderViewDistance = 512,
    // Upgrades are dealt with in drone values
};

enum TheSpiderDroneValues {
	kCraftSpiderDroneBoundingBoxWidth = 24, // pixels
	kCraftSpiderDroneBoundingBoxHeight = 24,
	kCraftSpiderDroneUnlockYears = 0,
	kCraftSpiderDroneUpgradeUnlockYears = 0, // No upgrade
	kCraftSpiderDroneUpgradeCost = 0, // brogguts
	kCraftSpiderDroneUpgradeTime = 0, // seconds
	kCraftSpiderDroneCostBrogguts = 50,
	kCraftSpiderDroneCostMetal = 0,
	kCraftSpiderDroneEngines = 6,
	kCraftSpiderDroneWeapons = 4,
	kCraftSpiderDroneAttackRange = 32, // pixels
	kCraftSpiderDroneAttackCooldown = 30, // frames for weapon to recharge
	kCraftSpiderDroneSpecialCoolDown = 0, // frames for special to recharge
	kCraftSpiderDroneHull = 40,
    kCraftSpiderDroneViewDistance = 0, // Can't remove fog
	// Special Values
	kCraftSpiderDroneRebuildTime = 6, // seconds
	kCraftSpiderDroneCostBroggutsUpgraded = 25, // brogguts
	kCraftSpiderDroneRebuildTimeUpgraded = 4, // seconds
};

enum TheEagleValues {
	kCraftEagleBoundingBoxWidth = 160, // pixels
	kCraftEagleBoundingBoxHeight = 80,
	kCraftEagleUnlockYears = 8,
	kCraftEagleUpgradeUnlockYears = 13, // increases explode damage
	kCraftEagleUpgradeCost = 100, // brogguts
	kCraftEagleUpgradeTime = 20, // seconds
	kCraftEagleCostBrogguts = 600,
	kCraftEagleCostMetal = 60,
	kCraftEagleEngines = 6,
	kCraftEagleWeapons = 20,
	kCraftEagleAttackRange = 360, // pixels
	kCraftEagleAttackCooldown = 30, // frames for weapon to recharge
	kCraftEagleSpecialCoolDown = 0, // frames for special to recharge
	kCraftEagleHull = 200,
    kCraftEagleViewDistance = 512,
	// Special Values
    kCraftEagleSelfRepairAmountPerSecond = 5, // HP / seconds
};

//
// Structure Specific Information
//
// Format => kStructure<name><attribute> 

enum kObjectStructureBaseStation {
	kStructureBaseStationBoundingBoxWidth = 64, // pixels
	kStructureBaseStationBoundingBoxHeight = 64,
	kStructureBaseStationUnlockYears = 0,
	kStructureBaseStationUpgradeUnlockYears = 0, // No upgrade
	kStructureBaseStationUpgradeCost = 0, // brogguts
	kStructureBaseStationUpgradeTime = 0, // seconds
	kStructureBaseStationCostBrogguts = 0,
	kStructureBaseStationCostMetal = 0,
	kStructureBaseStationMovingTime = 0, // seconds to move to active spot
	kStructureBaseStationHull = 750,
    kStructureBaseStationViewDistance = 768,
    // Special
    kStructureBaseStationSupplyBonus = 4,
    kStructureBaseStationHullCapacityUpgrade = 1000,
};

enum TheBlockValues {
	kStructureBlockBoundingBoxWidth = 64, // pixels
	kStructureBlockBoundingBoxHeight = 64,
	kStructureBlockUnlockYears = 0,
	kStructureBlockUpgradeUnlockYears = 1,
	kStructureBlockUpgradeCost = 0, // brogguts
	kStructureBlockUpgradeTime = 0, // seconds
	kStructureBlockCostBrogguts = 100,
	kStructureBlockCostMetal = 0,
	kStructureBlockMovingTime = 1, // seconds to move to active spot
	kStructureBlockHull = 200,
    kStructureBlockViewDistance = 512,
	// Special Values
    kStructureBlockSupplyBonus = 3,
    kStructureBlockHullIncreaseUpgrade = 300,
};

enum TheRefineryValues {
	kStructureRefineryBoundingBoxWidth = 80, // pixels
	kStructureRefineryBoundingBoxHeight = 80,
	kStructureRefineryUnlockYears = 0,
	kStructureRefineryUpgradeUnlockYears = 7,
	kStructureRefineryUpgradeCost = 100, // brogguts
	kStructureRefineryUpgradeTime = 20, // seconds
	kStructureRefineryCostBrogguts = 300,
	kStructureRefineryCostMetal = 0,
	kStructureRefineryMovingTime = 4, // seconds to move to active spot
	kStructureRefineryHull = 160,
    kStructureRefineryViewDistance = 384,
	// Special Values
	kStructureRefineryBroggutConversionRate = 5, // number of metal per batch
	kStructureRefineryBroggutConvertTime = 120, // Frames for one batch of metal
    kStructureRefineryBroggutConvertTimeUpgrade = 80,
};

enum TheCraftUpgradesValues {
	kStructureCraftUpgradesBoundingBoxWidth = 80, // pixels
	kStructureCraftUpgradesBoundingBoxHeight = 80,
	kStructureCraftUpgradesUnlockYears = 2,
	kStructureCraftUpgradesUpgradeUnlockYears = 0, // No upgrade
	kStructureCraftUpgradesUpgradeCost = 0, // brogguts
	kStructureCraftUpgradesUpgradeTime = 0, // seconds
	kStructureCraftUpgradesCostBrogguts = 400,
	kStructureCraftUpgradesCostMetal = 0,
	kStructureCraftUpgradesMovingTime = 4, // seconds to move to active spot
	kStructureCraftUpgradesHull = 160,
    kStructureCraftUpgradesViewDistance = 384,
	// Special Values
    kStructureCraftUpgradesTimePercentageUpgrade = 75, // Percent out of 100
};

enum TheStructureUpgradesValues {
	kStructureStructureUpgradesBoundingBoxWidth = 80, // pixels
	kStructureStructureUpgradesBoundingBoxHeight = 80,
	kStructureStructureUpgradesUnlockYears = 1,
	kStructureStructureUpgradesUpgradeUnlockYears = 0, // No upgrade
	kStructureStructureUpgradesUpgradeCost = 0, // brogguts
	kStructureStructureUpgradesUpgradeTime = 0, // seconds
	kStructureStructureUpgradesCostBrogguts = 400,
	kStructureStructureUpgradesCostMetal = 0,
	kStructureStructureUpgradesMovingTime = 4, // seconds to move to active spot
	kStructureStructureUpgradesHull = 160,
    kStructureStructureUpgradesViewDistance = 384,
	// Special Values
    kStructureStructureUpgradesTimePercentageUpgrade = 75, // Percent out of 100
};

enum TheTurretValues {
	kStructureTurretBoundingBoxWidth = 128, // pixels
	kStructureTurretBoundingBoxHeight = 128,
	kStructureTurretUnlockYears = 4,
	kStructureTurretUpgradeUnlockYears = 6,
	kStructureTurretUpgradeCost = 100, // brogguts
	kStructureTurretUpgradeTime = 50, // seconds
	kStructureTurretCostBrogguts = 200,
	kStructureTurretCostMetal = 20,
	kStructureTurretMovingTime = 6, // seconds to move to active spot
	kStructureTurretHull = 200,
    kStructureTurretViewDistance = 768,
	// Special Values
	kStructureTurretWeapons = 2,
	kStructureTurretAttackRange = 512,
    kStructureTurretAttackCooldown = 20,
	kStructureTurretAttackCooldownUpgrade = 10,
};

enum TheRadarValues {
	kStructureRadarBoundingBoxWidth = 64, // pixels
	kStructureRadarBoundingBoxHeight = 64,
	kStructureRadarUnlockYears = 2,
	kStructureRadarUpgradeUnlockYears = 6,
	kStructureRadarUpgradeCost = 100, // brogguts
	kStructureRadarUpgradeTime = 50, // seconds
	kStructureRadarCostBrogguts = 300,
	kStructureRadarCostMetal = 30,
	kStructureRadarMovingTime = 8, // seconds to move to active spot
	kStructureRadarHull = 160,
    kStructureRadarViewDistance = 1024,
	// Special Values
	kStructureRadarRadius = 1024,
	kStructureRadarRadiusUpgrade = 2048,
    kStructureRadarViewDistanceUpgrade = 2048,
};

enum TheFixerValues {
	kStructureFixerBoundingBoxWidth = 128, // pixels
	kStructureFixerBoundingBoxHeight = 128,
	kStructureFixerUnlockYears = 3,
	kStructureFixerUpgradeUnlockYears = 5,
	kStructureFixerUpgradeCost = 100, // brogguts
	kStructureFixerUpgradeTime = 50, // seconds
	kStructureFixerCostBrogguts = 400,
	kStructureFixerCostMetal = 40,
	kStructureFixerMovingTime = 6, // seconds to move to active spot
	kStructureFixerHull = 120,
    kStructureFixerViewDistance = 512,
	// Special Values
	kStructureFixerRepairRange = 400,
    kStructureFixerRepairAmount = 2,
	kStructureFixerRepairCooldown = 125, // HP per 100 frames
	kStructureFixerFriendlyTargetLimit = 1,
	kStructureFixerFriendlyTargetLimitUpgrade = 2,
};

//
// Gameplay Specific Information
//

enum MovingAIStates {
	kMovingAIStateStill,
	kMovingAIStateMoving,
	kMovingAIStateMining,
};

enum AttackingAIStates {
	kAttackingAIStateNeutral,
	kAttackingAIStateAttacking,
};

enum BroggutDataValues {
	kBroggutRarityBase = 1000, // What below percents are divided into
	kBroggutYoungRarity = 900, // 
	kBroggutOldRarity = 95,
	kBroggutAncientRarity = 5,
	kBroggutSmallMaxRotationSpeed = 1,
	kBroggutSmallMinDiameter = 32,
	kBroggutSmallMaxDiameter = 48,
	kBroggutSmallMinVelocity = 0,
	kBroggutSmallMaxVelocity = 50, // Out of 100
	kBroggutMediumMinRotationSpeed = 2,
	kBroggutMediumMaxRotationSpeed = 4,
	kBroggutMediumMinDiameter = 100,
	kBroggutMediumMaxDiameter = 128,
	kBroggutYoungSmallMinValue = 2,
	kBroggutYoungSmallMaxValue = 8,
	kBroggutOldSmallMinValue = 8,
	kBroggutOldSmallMaxValue = 20,
	kBroggutAncientSmallMinValue = 80,
	kBroggutAncientSmallMaxValue = 100,
	kBroggutYoungMediumMinValue = 200,
	kBroggutYoungMediumMaxValue = 400,
	kBroggutOldMediumMinValue = 500,
	kBroggutOldMediumMaxValue = 1000,
	kBroggutAncientMediumMinValue = 2500,
	kBroggutAncientMediumMaxValue = 5000,
};

enum BroggutAgeConstants {
    kBroggutMediumAgeYoung,
    kBroggutMediumAgeOld,
    kBroggutMediumAgeAncient,
};


//
// Friendly AI Specific Information
//



//
// Enemy AI Specific Information
//

