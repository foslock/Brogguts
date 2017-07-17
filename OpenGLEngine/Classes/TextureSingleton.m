//
//  TextureSingleton.m
//  OpenGLEngine
//
//  Created by James F Lockwood on 2/1/11.
//  Copyright 2011 Games in Dorms. All rights reserved.
//

#import "TextureSingleton.h"
#import "Texture2D.h"

static TextureSingleton* sharedTextureSingleton = nil;

@implementation TextureSingleton

#pragma mark -
#pragma mark Singleton implementation

+ (TextureSingleton *)sharedTextureSingleton
{
	@synchronized (self) {
		if (sharedTextureSingleton == nil) {
			[[self alloc] init];
		}
	}
	
	return sharedTextureSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharedTextureSingleton == nil) {
			sharedTextureSingleton = [super allocWithZone:zone];
			return sharedTextureSingleton;
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

- (oneway void)release
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
    
    // Release the cachedTextures dictionary.
	[cachedTextures release];
	[super dealloc];
}


- (id)init {
	// Initialize a dictionary
	if ((self = [super init])) {
		cachedTextures = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (Texture2D*)textureWithFileName:(NSString*)aName filter:(GLenum)aFilter {
    
    // Try to get a texture from cachedTextures with the supplied key.
    Texture2D *cachedTexture;
	
	if((cachedTexture = [cachedTextures objectForKey:aName])) {
		return cachedTexture;
	}
	
	// We are using imageWithContentsOfFile rather than imageNamed, as imageNamed caches the image in the device.
	// This can lead to memory issue as we do not have direct control over when it would be released.  Not using
	// imageNamed means that it is not cached by the OS and we have control over when it is released.
	NSString *filename = [aName stringByDeletingPathExtension];
	NSString *filetype = [aName pathExtension];
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:filetype];
	cachedTexture = [[Texture2D alloc] initWithImage:[UIImage imageWithContentsOfFile:path] filter:aFilter];
	[cachedTextures setObject:cachedTexture forKey:aName];
	
	// Return the texture which is autoreleased as the caller is responsible for it
    return [cachedTexture autorelease];
}

- (void)addTextureWithImage:(UIImage*)image withName:(NSString*)aName filter:(GLenum)aFilter {
    // Try to get a texture from cachedTextures with the supplied key.
    Texture2D *cachedTexture;
	
	if((cachedTexture = [cachedTextures objectForKey:aName])) {
        // NSLog(@"A texture with the name %@ already exists", aName);
		return; // Already exists
	}
	
	cachedTexture = [[Texture2D alloc] initWithImage:[image retain] filter:aFilter];
	[cachedTextures setObject:cachedTexture forKey:aName];
    [cachedTexture release];
    [image release];
}

- (BOOL)releaseTextureWithName:(NSString*)aName {
	
    // If a texture was found we can remove it from the cachedTextures and return YES.
    if([cachedTextures objectForKey:aName]) {
        [cachedTextures removeObjectForKey:aName];
        return YES;
    }
    
    // No texture was found with the supplied key so log that and return NO;
    NSLog(@"INFO - Resource Manager: A texture with the key '%@' could not be found to release.", aName);
    return NO;
}

- (void)releaseAllTextures {
    NSLog(@"INFO - Resource Manager: Releasing all cached textures.");
    [cachedTextures removeAllObjects];
}

@end