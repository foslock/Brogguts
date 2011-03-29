//
//  ImageRenderSingleton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "ImageRenderSingleton.h"
#import "Image.h"
#import "GameController.h"

static ImageRenderSingleton* sharedImageRenderSingleton = nil;

#pragma mark -
#pragma mark Private interface

@interface ImageRenderSingleton (Private) 
// Method used when an Image is instantiated.  It reserves a location within the render
// managers IVA for this image and passes back a pointer to the TexturedColoredQuad
// structure within the IVA.
- (void)copyImageDetails:(ImageDetails*)aImageDetails;

// Method used toadd a texture name to the list of textures that will be used to render the
// current contents of the render queue.
- (void)addToTextureList:(uint)aTextureName withLayer:(int)layer;
@end

@implementation ImageRenderSingleton

#pragma mark -
#pragma mark Singleton implementation

+ (ImageRenderSingleton *)sharedImageRenderSingleton
{
	@synchronized (self) {
		if (sharedImageRenderSingleton == nil) {
			[[self alloc] init];
		}
	}
	
	return sharedImageRenderSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedImageRenderSingleton == nil) {
			sharedImageRenderSingleton = [super allocWithZone:zone];
			return sharedImageRenderSingleton;
		}
	}
	
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; // This is sooo not zero
}

#pragma mark -
#pragma mark Public implementation

- (void)dealloc {
	if (iva) {
        for (int i = 0; i < RENDERING_LAYER_COUNT; i++) {
            free(iva[i]);
        }
        free(iva);
    }
	if (ivaIndices) {
        for (int i = 0; i < RENDERING_LAYER_COUNT; i++) {
            free(ivaIndices[i]);
        }
        free(ivaIndices);
    }
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        iva = calloc(RENDERING_LAYER_COUNT, sizeof(TexturedColoredVertex*));
        ivaIndices = calloc(RENDERING_LAYER_COUNT, sizeof(GLushort*));
        
        // Initialize the texture to render count
        for (int i = 0; i < RENDERING_LAYER_COUNT; i++) {
            // Initialize the vertices array.
            iva[i] = calloc(kMax_Images, sizeof(TexturedColoredQuad)); // A quad is four verticies
            
            // Initialize the indices array.  This array will be used to specify the indexes into
            // the interleaved vertex array.  This array will allow us to just specify the specific
            // interleaved array elements we want glDrawElements to render.  We multiply by 6 as
            // we are using GL_TRIANGLE to render and we therefore define two triangles each with 
            // three vertices to make a quad.
            ivaIndices[i] = calloc(kMax_Images * 6, sizeof(GLushort));
            
            // Initialize the IVA index
            ivaIndex[i] = 0;
            
            // Set the total texture count for this layer to 0
            renderTextureCount[i] = 0;
            
            // Initialize the contents of the imageCountForTexture array. We want to make sure that
            // the memory contents for this array are clean before we get started.
            for (int j = 0; j < kMax_Images; j++) {
                imageCountForTexture[i][j] = 0;
            }
        }		
	}
    return self;
}

- (void)addImageDetailsToRenderQueue:(ImageDetails*)aImageDetails {
    
	// Copy the imageDetails to the render managers IVA
	[self copyImageDetails:aImageDetails];
	
	// Add the texture used for this image to the list of textures to be rendered
    GLuint layer = CLAMP(aImageDetails->imageLayer, 0, RENDERING_LAYER_COUNT - 1);
	[self addToTextureList:aImageDetails->textureName withLayer:layer];
	
	// As we have added an images details to the render queue we need to increment the iva index
	ivaIndex[layer]++;
}

- (void)addTexturedColoredQuadToRenderQueue:(TexturedColoredQuad*)aTCQ texture:(uint)aTexture withLayer:(GLuint)layer {
    GLuint newLayer = CLAMP(layer, 0, RENDERING_LAYER_COUNT - 1);
	memcpy((TexturedColoredQuad*)(iva[newLayer]) + ivaIndex[newLayer], aTCQ, sizeof(TexturedColoredQuad));
	
	// Add the texture used for this image to the list of textures to be rendered
	
	[self addToTextureList:aTexture withLayer:newLayer];
	
	// As we have added a TexturedColoredQuad to the render queue we need to increment the iva index
	ivaIndex[newLayer]++;
}

- (void)renderImages { // Loops through each layer and renders each in the correct order
    for (int i = 0; i < RENDERING_LAYER_COUNT; i++) {
        [self renderImagesOnLayer:i];
    }
}

- (void)renderImagesOnLayer:(int)renderLayer {
    renderLayer = CLAMP(renderLayer, 0, RENDERING_LAYER_COUNT - 1);
    
    // Populate the vertex, texcoord and colorpointers with our interleaved vertex data
    glVertexPointer(2, GL_FLOAT, sizeof(TexturedColoredVertex), &(iva[renderLayer][0].geometryVertex) );
    glTexCoordPointer(2, GL_FLOAT, sizeof(TexturedColoredVertex), &(iva[renderLayer][0].textureVertex) );
    glColorPointer(4, GL_FLOAT, sizeof(TexturedColoredVertex), &(iva[renderLayer][0].vertexColor) );
	// NSLog(@"Rendering Layer (%i) with <%i> images", renderLayer, renderTextureCount[renderLayer]);
    
    // Loop through the texture index array rendering the images as necessary
    for(NSInteger textureIndex = 0; textureIndex < renderTextureCount[renderLayer]; textureIndex++) {
		
        GLuint textureID = texturesToRender[renderLayer][textureIndex];
        // Bind to the textureName of the current texture.  This is the key of the texture
        // structure
        glBindTexture(GL_TEXTURE_2D, textureID);
		
        // Init the vertex counter.  This will be used to identify how many elements need to be used
        // within the indices array.
        int vertexCounter=0;
		
        for(NSInteger imageIndex = 0; imageIndex < imageCountForTexture[renderLayer][textureID]; imageIndex++) {
            // Set the indicies array to point to IVA entries for the image being processed
            // We are using GL_TRIANGLES so we construct two triangles from the vertices we
            // have inside the IVA for each image quad. Four vertices per quad so increment the vertex counter
            NSUInteger index = textureIndices[renderLayer][textureID][imageIndex] * 4;
            ivaIndices[renderLayer][vertexCounter++] = index;     // Bottom left
            ivaIndices[renderLayer][vertexCounter++] = index+2;   // Top Left
            ivaIndices[renderLayer][vertexCounter++] = index+1;   // Bottom right
            ivaIndices[renderLayer][vertexCounter++] = index+1;   // Bottom right
            ivaIndices[renderLayer][vertexCounter++] = index+2;   // Top left
            ivaIndices[renderLayer][vertexCounter++] = index+3;   // Top right
        }
        
        // Now we have loaded the indices array with indexes into the IVA, we draw those triangles
        glDrawElements(GL_TRIANGLES, vertexCounter, GL_UNSIGNED_SHORT, ivaIndices[renderLayer]);
        
        // Clear the quad count for the current texture
        imageCountForTexture[renderLayer][textureID] = 0;
    }
    
    // Reset the number of textures which need to be rendered
    renderTextureCount[renderLayer] = 0;
	
	// Reset the ivaIndex so that we start to load the next set of images from the start of the IVA.
	ivaIndex[renderLayer] = 0;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation ImageRenderSingleton (Private)

- (void)copyImageDetails:(ImageDetails*)aImageDetails {
    GLuint newLayer = CLAMP(aImageDetails->imageLayer, 0, RENDERING_LAYER_COUNT - 1);

    // Check to make sure that we have not exceeded the maximum size of the render queue.  If the queue size
	// is exceeded then render the images that are currently in the render managers queue.  This resets the
	// queue and allows the image to be added to the render managers then empty queue.
    if(ivaIndex[newLayer] + 1 > kMax_Images) {
        NSLog(@"ERROR - RenderManager: Render queue size exceeded.  Consider increasing the default size. %d", ivaIndex[newLayer] + 1);
		[self renderImagesOnLayer:newLayer];
    }
	
    // Point the texturedColoredQuadIVA to the current location in the render managers IVA queue
    aImageDetails->texturedColoredQuadIVA = (TexturedColoredQuad*)(iva[newLayer]) + ivaIndex[newLayer];
    
    // Copy the images base texturedColoredQuad into the assigned IVA index.  This is necessary to make sure
	// the texture and color informaiton is loaded into the IVA.  The geometry from the image is loaded
	// when the image is transformed within the Image render method.
    memcpy(aImageDetails->texturedColoredQuadIVA, aImageDetails->texturedColoredQuad, sizeof(TexturedColoredQuad));
}

- (void)addToTextureList:(uint)aTextureName withLayer:(int)layer {
	layer = CLAMP(layer, 0, RENDERING_LAYER_COUNT - 1);
    
	// Check to see if the texture for this image has already been added to the queue
    BOOL textureFound = NO;
    for(int index = 0; index < renderTextureCount[layer]; index++) {
        if(texturesToRender[layer][index] == aTextureName) {
            textureFound = YES;
            break;
        }
    }
    
	if(!textureFound) {
        // This is the first time this texture has been placed on the queue, so add this texture to the
        // texturesToRender array
        int renderIndex = renderTextureCount[layer]++;
        texturesToRender[layer][renderIndex] = aTextureName;
    }
	
    // Add this new images ivaIndex to the textureIndices array
    textureIndices[layer][aTextureName][imageCountForTexture[layer][aTextureName]] = ivaIndex[layer];
	
	// Up the image count for the texture we have just processed
	imageCountForTexture[layer][aTextureName] += 1; 
}

@end
