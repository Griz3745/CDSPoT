//
//  FlickrCache.m
//  FlickrPlaces
//
//  Created by Michael Grysikiewicz on 11/24/12.
//  Copyright (c) 2012 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrCache.h"
#import "SPoT.h"
#import "FlickrFetcher.h"

@implementation FlickrCache

+ (NSData *) flickrImageFromPhoto:(NSDictionary *) photo
{
    // This method tries to find the image for the photo in the App's cache.
    // If the image is found it is returned. If the image is not found it is fetched from Flickr
    // and added to the App's cache.  If adding the photo to the cache causes the
    // cache to exceed 10MB, then the oldest photo is removed from the cache until the
    // cache size is less than 10MB
    
    NSData *photoData = nil;
    
    // Do not use the default file manager if using the fileManager delegates, alloc one instead
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // Get the URL for the sandbox
    NSArray *cachesInSandbox = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheDirectory = cachesInSandbox.lastObject;
    
    // Create the URL in the sandbox for this App
    cacheDirectory = [cacheDirectory URLByAppendingPathComponent:SPOT_APP_CACHES_DIRECTORY];
    
    // Create the App's sandbox directory, if it doesn't already exist
    if (![fileManager createDirectoryAtURL:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil])
    {
        NSLog(@"----> Directory creation failed.");
    }
    
    // Create the name for the cached photo
    NSURL *cachedPhoto = [cacheDirectory URLByAppendingPathComponent:[photo objectForKey:FLICKR_PHOTO_ID]];
        
    // Now check to see if a cache file already exists for this photo
    if (![cachedPhoto checkResourceIsReachableAndReturnError:nil])
    {
        // The photo is not in cache so fetch the photo from Flickr
        FlickrPhotoFormat flickrPhotoFormat = FlickrPhotoFormatLarge;
        NSURL *photoURL = [[FlickrFetcher class] urlForPhoto:photo format:flickrPhotoFormat];

        // ----> The following line accesses the network
        photoData = [NSData dataWithContentsOfURL:photoURL];
// ----> */ [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
        
        // Get the size of the fetched photo
        NSUInteger photoSize = photoData.length;
        
        // Scan through all the files in the App's directory, code borrowed from Documentation of NSFileManager
        NSDirectoryEnumerator *dirEnumerator =
            [fileManager enumeratorAtURL:cacheDirectory
              includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLFileSizeKey, NSURLCreationDateKey,nil]
                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                            errorHandler:nil];

        NSUInteger cumulativeSizeOfCachedPhotos = 0;
        NSMutableArray *arrayOfURLsInCache = [NSMutableArray array];
        NSNumber *fileSizeForCurrentURL;

        // Enumerate the dirEnumerator results, each value is stored in arrayOfURLsInCache
        for (NSURL *theURL in dirEnumerator)
        {
            // Retrieve the file size. From NSURLFileSizeKey, cached during the enumeration.
            [theURL getResourceValue:&fileSizeForCurrentURL forKey:NSURLFileSizeKey error:NULL];
            
            // Get the cumulative size of the photos in the App directory
            cumulativeSizeOfCachedPhotos += fileSizeForCurrentURL.unsignedIntegerValue;
            
            // Add all of the URLs to the array
            [arrayOfURLsInCache addObject:theURL];
            
        }
            
        // If adding this photo will exceeds the 10MB limit,
        // then delete older photos from cache until the limit is not exceeded
        NSURL *oldestURL;
        NSURL *currentURL;
        
        NSDate *creationDateForOldestURL;
        NSDate *creationDateForCurrentURL;

        while ((cumulativeSizeOfCachedPhotos + photoSize) > CACHE_SIZE_LIMIT)
        {
            // Find the oldest file
            oldestURL = [arrayOfURLsInCache objectAtIndex:0];
            [oldestURL getResourceValue:&creationDateForOldestURL forKey:NSURLCreationDateKey error:NULL];
            
            // Compare the currentURL to the oldestURL
            for (int arrayIndex = 1; arrayIndex < arrayOfURLsInCache.count; arrayIndex++)
            {
                currentURL = [arrayOfURLsInCache objectAtIndex:arrayIndex];
                [currentURL getResourceValue:&creationDateForCurrentURL forKey:NSURLCreationDateKey error:NULL];
                if ([creationDateForCurrentURL compare:creationDateForOldestURL] == NSOrderedAscending)
                {
                    oldestURL = currentURL;
                    creationDateForOldestURL = creationDateForCurrentURL;
                }
            }
            
            // Delete the oldest file from the App's cache
            NSString *fileNameForOldestURL;
            [oldestURL getResourceValue:&fileNameForOldestURL forKey:NSURLNameKey error:NULL];
            
            if (![fileManager removeItemAtURL:oldestURL error:nil])
            {
                NSLog(@"Failed to remove----> %@", fileNameForOldestURL);
            }
            
            // Remove the oldestURL from arrayOfURLsInCache
            [arrayOfURLsInCache removeObjectIdenticalTo:oldestURL];
            
            // Update cumulativeSizeOfCachedPhotos
            NSNumber *fileSizeForOldestURL;
            [oldestURL getResourceValue:&fileSizeForOldestURL forKey:NSURLFileSizeKey error:NULL];
            cumulativeSizeOfCachedPhotos -= fileSizeForOldestURL.unsignedIntegerValue;
        }
        
        // Add this photo to the cache
        if  (![photoData writeToURL:cachedPhoto atomically:YES])
        {
            NSLog(@"Writing to cache failed for----> %@", cachedPhoto);
        }
    }
    else
    {
        // Return the cached photo
        photoData = [[NSData alloc] initWithContentsOfURL:cachedPhoto];
    }
    
    return photoData;
}

@end