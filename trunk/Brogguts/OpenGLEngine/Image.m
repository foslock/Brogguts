//
//  Image.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "Image.h"
#import "Texture2D.h"
#import "TextureSingleton.h"
#import "ImageRenderSingleton.h"
#import "GameController.h"
#import "Transform2D.h"
#import "BroggutScene.h"

#pragma mark -
#pragma mark Objects filenames interface
/*
 kObjectBroggutSmallID,
 kObjectBroggutMediumID,
 kObjectBroggutLargeID,
 kObjectCraftAntID,
 kObjectCraftMothID,
 kObjectCraftBeetleID,
 kObjectCraftMonarchID,
 kObjectCraftCamelID,
 kObjectCraftRatID,
 kObjectCraftSpiderID,
 kObjectCraftEagleID,
 kObjectStructureBaseStationID,
 kObjectStructureBlockID,
 kObjectStructureRefineryID,
 kObjectStructureCraftUpgradesID,
 kObjectStructureStructureUpgradesID,
 kObjectStructureTurretID,
 kObjectStructureRadarID,
 kObjectStructureFixerID,
 */

NSString* kObjectBroggutSmallSprite = @"smallbroggut.png";
NSString* kObjectBroggutMediumSprite = @"mediumbroggut.png";

NSString* kObjectCraftAntSprite = @"craftant.png";
NSString* kObjectCraftMothSprite = @"craftmoth.png";
NSString* kObjectCraftBeetleSprite = @"craftbeetle.png";
NSString* kObjectCraftMonarchSprite = @"craftmonarch.png";

NSString* kObjectCraftCamelSprite = @"craftcamel.png";
NSString* kObjectCraftRatSprite = @"craftrat.png";
NSString* kObjectCraftSpiderSprite = @"craftspider.png";
NSString* kObjectCraftSpiderDroneSprite = @"craftspiderdrone.png";
NSString* kObjectCraftEagleSprite = @"crafteagle.png";

NSString* kObjectStructureBaseStationSprite = @"structurebasestation.png";
NSString* kObjectStructureBlockSprite = @"structureblock.png";
NSString* kObjectStructureRefinerySprite = @"structurerefinery.png";
NSString* kObjectStructureCraftUpgradesSprite = @"structurecraftupgrades.png";
NSString* kObjectStructureStructureUpgradesSprite = @"structurestructureupgrades.png";
NSString* kObjectStructureTurretSprite = @"structureturret.png";
NSString* kObjectStructureRadarSprite = @"structureradar.png";
NSString* kObjectStructureFixerSprite = @"structurefixer.png";

#pragma mark -
#pragma mark Private interface

@interface Image (Private)
// Method which initializes the common properties of the image.  The initializer specific
// properties are handled within their respective initializers.  This method also grabs
// a reference to the render and resource managers
- (void)initializeImage:(NSString*)aName filter:(GLenum)aFilter;

// Method to initialize the images properties.  This is used by all the initializers to create
// the image details structure and to register the image details with the render manager
- (void)initializeImageDetails;

@end

#pragma mark -
#pragma mark Public implementation

@implementation Image

@synthesize imageFileName;
@synthesize imageFileType;
@synthesize texture;
@synthesize fullTextureSize;
@synthesize textureSize;
@synthesize textureRatio;
@synthesize maxTextureSize;
@synthesize imageSize;
@synthesize textureOffset;
@synthesize rotation;
@synthesize scale;
@synthesize flipHorizontally;
@synthesize flipVertically;
@synthesize IVAIndex;
@synthesize textureName;
@synthesize renderPoint;
@synthesize color;
@synthesize rotationPoint;
@synthesize minMagFilter;
@synthesize imageDetails;
@synthesize subImageRectangle;

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
	if (texture)
		[texture release];
	
	if (imageDetails) {
		if (imageDetails->texturedColoredQuad)
			free(imageDetails->texturedColoredQuad);
		free(imageDetails);
	}
    [super dealloc];
}

#pragma mark -
#pragma mark Initializers

- (id)initWithImageNamed:(NSString*)aName filter:(GLenum)aFilter {
    
    self = [super init];
	if (self != nil) {
        // Initialize the common properties for this image
        [self initializeImage:aName filter:aFilter];
        
        // Set the width and height of the image to be the full width and hight of the image
        // within the texture
        imageSize = texture.contentSize;
		originalImageSize = imageSize;
        
        // Get the texture width and height which is to be used.  For an image which is not using
        // a sub region of a texture then these values are the maximum width and height values from
        // the texture2D object
        textureSize.width = texture.maxS;
        textureSize.height = texture.maxT;
        
        // Set the texture offset to be {0, 0} as we are not using a sub region of this texture
        textureOffset = CGPointZero;
        
        // Init the images imageDetails structure
        [self initializeImageDetails];
    }
	return self;
}

- (id)initWithImageNamed:(NSString*)aName filter:(GLenum)aFilter subTexture:(CGRect)aSubTexture {
    
    self = [super init];
	if (self != nil) {
		// Save the sub textures rectangle
		subImageRectangle = aSubTexture;
        
		// Initialize the common properties for this image
        [self initializeImage:aName filter:aFilter];
        
        // Set the width and height of the image that has been passed into in.  This is defining a
        // sub region within the larger texture.
        imageSize = aSubTexture.size;
		originalImageSize = imageSize;
        
        // Calculate the point within the texture from where the texture sub region will be started
        textureOffset.x = textureRatio.width * aSubTexture.origin.x;
        textureOffset.y = textureRatio.height * aSubTexture.origin.y;
        
        // Calculate the width and height of the sub region this image is going to use.
        textureSize.width = (textureRatio.width * imageSize.width) + textureOffset.x;
        textureSize.height = (textureRatio.height * imageSize.height) + textureOffset.y;
        
        // Init the images imageDetails structure
        [self initializeImageDetails];
    }
	return self;
}

#pragma mark -
#pragma mark Sub Image, Copy and Percentage

- (Image*)subImageInRect:(CGRect)aRect {
    // Create a new image which represents the defined sub image of this image
    Image *subImage = [[Image alloc] initWithImageNamed:imageFileName filter:minMagFilter subTexture:aRect];
    subImage.scale = scale;
    subImage.color = color;
    subImage.flipVertically = flipVertically;
    subImage.flipHorizontally = flipHorizontally;
	subImage.rotation = rotation;
	subImage.rotationPoint = rotationPoint;
    return [subImage autorelease];
}

- (Image*)imageDuplicate {
	Image *imageCopy = [[self subImageInRect:subImageRectangle] retain];
	return [imageCopy autorelease];
}

- (void)setImageSizeToRender:(CGSize)aImageSize {
	
	// If the width or height passed in is < 0 or > 100 then log an error
	if (aImageSize.width < 0 || aImageSize.width > 100 || aImageSize.height < 0 || aImageSize.height > 100) {
		NSLog(@"ERROR - Image: Illegal % provided to setImageSizeToRender 'width=%f, height=%f'", aImageSize.width, aImageSize.height);
		return;
	}
	
	// Using the original size of this image, calculate the new image width based on the
	// percentage provided
	imageSize.width = (originalImageSize.width / 100) * aImageSize.width;
	imageSize.height = (originalImageSize.height / 100) * aImageSize.height;
	
	// Calculate the width and height of the sub region this image is going to use.
	textureSize.width = (textureRatio.width * imageSize.width) + textureOffset.x;
	textureSize.height = (textureRatio.height * imageSize.height) + textureOffset.y;
	
	// Initialize the image details.  This will recalculate the images geometry and texture
	// coordinates in the imageDetails structure.
	[self initializeImageDetails];
}

#pragma mark -
#pragma mark Image Rendering

- (void)renderAtPoint:(CGPoint)aPoint {
    [self renderAtPoint:aPoint scale:scale rotation:rotation];
}

- (void)renderAtPoint:(CGPoint)aPoint scale:(Scale2f)aScale rotation:(float)aRotation {
    renderPoint = aPoint;
    scale = aScale;
    rotation = aRotation;
    dirty = YES;
    [self render];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint {
    [self renderCenteredAtPoint:aPoint scale:scale rotation:rotation];
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint withScrollVector:(Vector2f)vector {
	float maxDelta = MAX(imageSize.width, imageSize.height);
	CGRect viewbounds = CGRectInset([[sharedGameController currentScene] visibleScreenBounds], -maxDelta, -maxDelta);
	if (CGRectContainsPoint(viewbounds, aPoint)) { // ONLY RENDER OBJECTS ON SCREEN
		CGPoint newPoint = CGPointMake(aPoint.x - vector.x, aPoint.y - vector.y);
		[self renderCenteredAtPoint:newPoint scale:scale rotation:rotation];
	}
}

- (void)renderCenteredAtPoint:(CGPoint)aPoint scale:(Scale2f)aScale rotation:(float)aRotation {
    scale = aScale;
    rotation = aRotation;
    // Adjust the point the image is going to be rendered at, so that the centre
    // of the image is located at the point which has been passed in.  This takes
    // into account the current scale of the image as well
    renderPoint.x = aPoint.x - ((imageSize.width * scale.x) / 2);
    renderPoint.y = aPoint.y - ((imageSize.height * scale.y) / 2);
    dirty = YES;
    [self render];    
    
}

- (void)renderCentered {
    // Take a copy of the images point as we will be adjusting this so that the image is
    // rendered centered on that point
    CGPoint pointCopy = renderPoint;
    
    // Adjust the point the image is going to be rendered at so that the centre of the image
    // is rendered at that point.
    renderPoint.x = renderPoint.x - ((imageSize.width * scale.x) / 2);
    renderPoint.y = renderPoint.y - ((imageSize.height * scale.y) / 2);
    
    // Mark the image as dirty and render the image
    dirty = YES;
    [self render];
    
    // Restore the point ivar
    renderPoint = pointCopy;
}

- (void)render {
	
	// Update the color of the image before it gets copied to the render manager
	imageDetails->texturedColoredQuad->vertex1.vertexColor = 
	imageDetails->texturedColoredQuad->vertex2.vertexColor =
	imageDetails->texturedColoredQuad->vertex3.vertexColor =
	imageDetails->texturedColoredQuad->vertex4.vertexColor = color;
	
	// Add this image to the render queue.  This will cause this image to be rendered the next time
    // the renderManager is asked to render.  It also copies the data over to the image renderer
    // IVA.  It is this data that is changed next by applying the images matrix
    [imageRenderSingleton addImageDetailsToRenderQueue:imageDetails];
    
	// If the images point, scale or rotation are changed, it means we need to adjust the 
    // images matrix and transform the vertices.  If dirty is set we also check to see if it is 
    // necessary to adjust the rotation and scale.  If they are 0 then nothing needs to
    // be done and we can save some cycles.
    if (dirty) {
        // Load the identity matrix before applying transforming the matrix for this image.  The
        // order in which the transformations are applied is important.
        loadIdentityMatrix(matrix);
		
        // Translate the position of the image first
        translateMatrix(matrix, renderPoint);
		
        // If this image has been configured to be flipped vertically or horizontally
        // then set the scale for the image to -1 for the appropriate axis and then translate 
        // the image so that the images origin is rendered in the correct place
        if(flipVertically) {
            scaleMatrix(matrix, Scale2fMake(1, -1));
            translateMatrix(matrix, CGPointMake(0, (-imageSize.height * scale.y)));
        }
		
        if(flipHorizontally) {
            scaleMatrix(matrix, Scale2fMake(-1, 1));
            translateMatrix(matrix, CGPointMake((-imageSize.width * scale.x), 0));
        }
        
		// No point in calculating a rotation matrix if there is no rotation been set
        if(rotation != 0) {
			rotationPoint = CGPointMake(imageSize.width / 2 * scale.x, imageSize.height / 2 * scale.y);
			rotateMatrix(matrix, rotationPoint, rotation);
		}
            
        
        // No point in calculcating scale if no scale has been set.
		if(scale.x != 1.0f || scale.y != 1.0f) 
            scaleMatrix(matrix, scale);
        
        // Transform the images matrix based on the calculations done above
        transformMatrix(matrix, imageDetails->texturedColoredQuad, imageDetails->texturedColoredQuadIVA);
        
        // Mark the image as now clean
		dirty = NO;
	}
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation Image (Private)

- (void)initializeImage:(NSString*)aImageName filter:(GLenum)aFilter {
	
    // Grab a reference to the texture, image renderer and shared game singletons
    textureSingleton = [TextureSingleton sharedTextureSingleton];
    imageRenderSingleton = [ImageRenderSingleton sharedImageRenderSingleton];
    sharedGameController = [GameController sharedGameController];
    
	// Set the image name to the name of the image file used to create the texture.  This is also
    // the key within the texture manager for grabbing a texture from the cache.
    self.imageFileName = aImageName;
	
	// Create a Texture2D instance using the image file with the specified name.  Retain a
	// copy as the Texture2D class autoreleases the instance returned.
	self.texture = [textureSingleton textureWithFileName:self.imageFileName filter:aFilter];
	
	// Set the texture name to the OpenGL texture name given to the Texture2D object
	textureName = texture.name;
	
	// Get the full width and height of the texture.  We could keep accessing the getters of the texture
	// instance, but keeping our own copy cuts down a little on the messaging
	fullTextureSize.width = texture.width;
	fullTextureSize.height = texture.height;
	
	// Grab the texture width and height ratio from the texture
	textureRatio.width = texture.textureRatio.width;
	textureRatio.height = texture.textureRatio.height;
    
    // Set the default color
    color = Color4fMake(1.0f, 1.0f, 1.0f, 1.0f);
	
	// Set the default rotation point which is the origin of the image i.e. {0, 0}
    rotationPoint = CGPointZero;
    
    // Set the min/mag filter value
    minMagFilter = aFilter;
	
	// Initialize properties with default values
    rotation = 0.0f;
    scale.x = 1.0f;
    scale.y = 1.0f;
    flipHorizontally = NO;
    flipVertically = NO;
}

- (void)initializeImageDetails {
    
    // Set up a TexturedColoredQuad structure which is going to hold the origial informtion
    // about our image.  This structure will never change, but will be used when performing
    // transforms on the image with the results being loaded into the RenderManager using this
    // images render index
	if (!imageDetails) {
		imageDetails = calloc(1, sizeof(ImageDetails));
		imageDetails->texturedColoredQuad = calloc(1, sizeof(TexturedColoredQuad));
	}
    
    // Set up the geometry for the image
    imageDetails->texturedColoredQuad->vertex1.geometryVertex = CGPointMake(0.0f, 0.0f);
    imageDetails->texturedColoredQuad->vertex2.geometryVertex = CGPointMake(imageSize.width, 0.0f);
    imageDetails->texturedColoredQuad->vertex3.geometryVertex = CGPointMake(0.0f, imageSize.height);
    imageDetails->texturedColoredQuad->vertex4.geometryVertex = CGPointMake(imageSize.width, imageSize.height);
    
    // Set up the texture coordinates for the image as is.  If a subimage is needed then
    // the getSubImage selector can be used to create a new image with the adjusted
    // texture coordinates.  The texture inside a Texture2D object is upside down, so the
    // texture coordinates need to account for that so the image will show the right way up
    // when rendered
    imageDetails->texturedColoredQuad->vertex1.textureVertex = CGPointMake(textureOffset.x, textureSize.height);
    imageDetails->texturedColoredQuad->vertex2.textureVertex = CGPointMake(textureSize.width, textureSize.height);
    imageDetails->texturedColoredQuad->vertex3.textureVertex = CGPointMake(textureOffset.x, textureOffset.y);
    imageDetails->texturedColoredQuad->vertex4.textureVertex = CGPointMake(textureSize.width, textureOffset.y);
    
    // Set up the vertex colors.  To start with these are all 1.0's
    imageDetails->texturedColoredQuad->vertex1.vertexColor = 
    imageDetails->texturedColoredQuad->vertex2.vertexColor = 
    imageDetails->texturedColoredQuad->vertex3.vertexColor = 
    imageDetails->texturedColoredQuad->vertex4.vertexColor = color;    
	
    // Set the imageDetails textureName
    imageDetails->textureName = textureName;
    
    // Mark the image as dirty which means that the images matrix will be transformed
    // with the results loaded into the images IVA pointer
    dirty = YES;   
}

- (void)setRenderPoint:(CGPoint)aPoint {
	renderPoint = aPoint;
	dirty = YES;
}

- (void)setRotation:(float)aRotation {
	rotation = aRotation;
	if (rotation > 360.0f) rotation -= 360.0f;
	if (rotation < 0.0f) rotation += 360.0f;
	dirty = YES;
}

- (void)setScale:(Scale2f)aScale {
    scale = aScale;
	dirty = YES;
}

- (void)setFlipVertically:(BOOL)aFlip {
	flipVertically = aFlip;
	dirty = YES;
}

- (void)setFlipHorizontally:(BOOL)aFlip {
	flipHorizontally = aFlip;
	dirty = YES;
}

@end

