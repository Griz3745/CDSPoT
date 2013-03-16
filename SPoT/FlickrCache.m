//
//  FlickrCache.m
//  FlickrPlaces
//
//  Created by Michael Grysikiewicz on 3/1/12.
//  Copyright (c) 2012 Michael Grysikiewicz. All rights reserved.
//
//  The flickrImageFromPhoto: class method, when given a Flickr photo URL,
//  will return the NSData for that photo.  The cache for this App will be searched first,
//  and if not found there, the NSData for the photo will be fetched from Flickr.
//
//  Whenever the data for the photo URL is fetched from Flickr, it is added to the cache for this App.
//  The size of the cache is mananaged so that it does not exceed CACHE_SIZE_LIMIT
//
//  NOTE: The calling method should implement running this class method in another thread
//

#import "FlickrCache.h"
#import "SPoT.h"
#import "UIApplication+NetworkActivity.h"

@implementation FlickrCache


+ (NSData *)flickrImageForPhotoURL:(NSURL *)flickrPhotoURL
{
    // This method tries to find the photo URL in the App's cache directory.
    // If the photo URL is found, the photo data is fetched from the cache directory and returned.
    // If the photo URL is not found in the App's cache directory,
    // the photo data for the URL is fetched from Flickr, added to the App's cache, and returned.
    // If adding the photo data to the cache causes the cache to exceed CACHE_SIZE_LIMIT,
    // then the oldest photo is removed from the cache until the
    // cache size is less than CACHE_SIZE_LIMIT
    
    // photo as NSData to be returned to the calling method
    NSData *photoData = nil;
    
    // Setup the Cache directory
    NSURL *cacheDirectoryURL = [self createCacheDirectory];
    
    // Create the name for the cached photo
    NSString *uniquePhotoID = [flickrPhotoURL lastPathComponent];
    NSURL *cachePhotoURL = [cacheDirectoryURL URLByAppendingPathComponent:uniquePhotoID];
    
    // Now check to see if a cache file already exists for this photo
    if (![cachePhotoURL checkResourceIsReachableAndReturnError:nil]) {
        
        // The photo is NOT in cache so fetch the photo from Flickr
        photoData = [self fetchFlickrPhoto:flickrPhotoURL];
        
        // Do not let the Cache exceed CACHE_SIZE_LIMIT
        [self makeRoomInCache:cacheDirectoryURL forPhoto:photoData];
        
        // Add this photo to the cache
        if  (![photoData writeToURL:cachePhotoURL atomically:YES])
        {
            NSLog(@"Writing to cache failed for----> %@", cachePhotoURL);
        }
    }
    else {
        // The photo does exist in cache, so pull the photo from cache
        photoData = [[NSData alloc] initWithContentsOfURL:cachePhotoURL];
    }
    
    return photoData;
}

// Remove the photo from cache when it is deleted by the user
+ (void)removePhotoURL:(NSURL *)flickrPhotoURL
{
    // Setup the Cache directory
    NSURL *cacheDirectoryURL = [self createCacheDirectory];
    
    // Create the name for the cached photo
    NSString *uniquePhotoID = [flickrPhotoURL lastPathComponent];
    NSURL *cachePhotoURL = [cacheDirectoryURL URLByAppendingPathComponent:uniquePhotoID];
    
    // Delete flickrPhotoURL from the App's cache
    if ([cachePhotoURL checkResourceIsReachableAndReturnError:nil]) {
        if (![[[NSFileManager alloc] init] removeItemAtURL:cachePhotoURL error:nil])
        {
            NSLog(@"Failed to remove----> %@", cachePhotoURL);
        }
    }
}

// Create and return the Cache directory URL from the Apps Sandbox
+ (NSURL *)createCacheDirectory
{
    // Remember that [NSFileManager defaultManager] is not thread safe
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // Get the URL for the cache sandbox
    // (Always specify NSUserDomainMask for iOS - Apple Documentation)
    NSURL *cacheDirectoryURL = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
    
    // Append the Cache type to the URL, to distinguish from other types of things in the Apps Cache
    cacheDirectoryURL = [cacheDirectoryURL URLByAppendingPathComponent:RECENT_PHOTO_IMAGES_CACHES_DIRECTORY];
    
    // Create the App's sandbox directory, if it doesn't already exist
    if (![fileManager createDirectoryAtURL:cacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"----> Directory creation failed.");
    }
    
    return cacheDirectoryURL;
}

// Fetch the photo data from Flickr using the provided URL
+ (NSData *)fetchFlickrPhoto:(NSURL *)flickrPhotoURL
{
    NSData *photoData;
    
    // Increment Network Activity Indicator counter
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    
// ----> */ [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    
    // Fetch the image data from Flickr
    // NOTE: The calling method should implement running this class method in another thread
    photoData = [NSData dataWithContentsOfURL:flickrPhotoURL]; // Network Activity!
    
    // Decrement Network Activity Indicator counter
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    
    return photoData;
}

// I 'Borrowed' the data structure used in makeRoomInCache: and buildCashFileDetails: from Joan.
// After comparing my original implementation with his implementation, I liked his much better.
// The data structure that he came up with made it much easier to properly delete excess files from cache.
//
// *** Since I am not getting paid to write this code, and I am not receiving a grade for this code,
// that makes this a pure learning exercise.  Thank you Joan :) ***

#define DATE_KEY @"date"
#define BYTES_KEY @"bytes"
#define URL_KEY @"url"
#define SUM_OF_BYTES_KEY @"@sum.bytes"


// Use an array of file information to make room in the Cache directory for the photoData
+ (void)makeRoomInCache:(NSURL *)cacheDirectoryURL forPhoto:(NSData *)photoData
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSArray *filesInCache = [self buildCashFileDetails:cacheDirectoryURL];
    
    // Calculate the size of the cache by adding the sizes of the files - Joan 'Magic' code, 1-liner
    // I understand it, but I would have never thought of it, but I will now!
    NSUInteger cacheSizeBeforeAddingPhotoData = [[filesInCache valueForKeyPath:SUM_OF_BYTES_KEY] integerValue];
    
    NSURL *oldestCacheURL;
    
    // If adding this photo will exceeds the CACHE_SIZE_LIMIT limit,
    // then delete older photos from cache until the limit is not exceeded
    for (int loopCounter = 0;
         ((cacheSizeBeforeAddingPhotoData + [photoData length]) > [self deviceCacheSize]);
         loopCounter++) {
        
        // Since the array has been sorted the first item has the oldest date
        oldestCacheURL = filesInCache[loopCounter][URL_KEY]; // [URL_KEY] means 'return the value for that key
        
        // Delete the oldest file from the App's cache
        if (![fileManager removeItemAtURL:oldestCacheURL error:nil])
        {
            NSLog(@"Failed to remove----> %@", oldestCacheURL);
        }
        
        // Update the size of of what is left in the cashe
        cacheSizeBeforeAddingPhotoData -= [filesInCache[loopCounter][BYTES_KEY] unsignedIntegerValue];
    }
}

// Create an array of dictionaries
// Each dictionary contains information about a file in cache
+ (NSArray *)buildCashFileDetails:(NSURL *)cacheDirectoryURL
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // Scan through all the files in the App's directory, code borrowed from Documentation of NSFileManager
    NSDirectoryEnumerator *dirEnumerator =
    [fileManager enumeratorAtURL:cacheDirectoryURL
      includingPropertiesForKeys:@[NSURLFileSizeKey, NSURLContentAccessDateKey]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                    errorHandler:nil];
    
    // Each element of the array is a dictionary of file information containing 3 items: Date, Size, and URL
    NSMutableArray *filesInCache = [[NSMutableArray alloc] init]; 
        
    // Process each file in the Cache Directory
    for (NSURL *theURL in dirEnumerator) {
        // Retrieve the file size.
        NSNumber *fileSizeForCurrentURL; // Use a fresh one each time for adding to the dictionary
        [theURL getResourceValue:&fileSizeForCurrentURL forKey:NSURLFileSizeKey error:NULL];
        
        // Retrieve the file date.
        NSDate   *fileDateForCurrentURL; // Use a fresh one each time for adding to the dictionary
        [theURL getResourceValue:&fileDateForCurrentURL forKey:NSURLContentAccessDateKey error:NULL];
        
        // Store the file information in the array
        [filesInCache addObject:@{DATE_KEY : fileDateForCurrentURL, // Each one of these are a
                                 BYTES_KEY : fileSizeForCurrentURL, // dictionary Key:Value pair
                                   URL_KEY : theURL}];
    }
    
    // Use the DATE_KEY field to sort the array of file information (each one is an NSDictionary)
    NSSortDescriptor *key = [[NSSortDescriptor alloc] initWithKey:DATE_KEY ascending:YES]; // oldest is first
    return [filesInCache sortedArrayUsingDescriptors:@[key]];
}

// Return a cache size limit appropriate for the device
+ (NSUInteger)deviceCacheSize
{
    // Assignment V, Hint 3 suggests varying the cache size depending on the platform
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? IPAD_CACHE_SIZE_LIMIT : IPHONE_CACHE_SIZE_LIMIT;
}

@end