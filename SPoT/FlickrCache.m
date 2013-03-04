//
//  FlickrCache.m
//  FlickrPlaces
//
//  Created by Michael Grysikiewicz on 3/1/12.
//  Copyright (c) 2012 Michael Grysikiewicz. All rights reserved.
//
//  This class has one class method, which when given a Flickr photo URL,
//  will return the NSData for that photo.  The cache for this App will be searched first,
//  and if not found there, the NSData for the photo will be fetched from Flickr.
//
//  Whenever the data for the photo URL is fetched from Flickr, it is added to the cache for this App.
//  The size of the cache is mananaged so that it does not exceed CACHE_SIZE_LIMIT
//
//  NOTE: The calling method should implement running this class method in another thread
//
//  *** I debated back and forth about breaking this single method into several methods.  I don't like
//  having such a long method, but there were no parts of the code that were repeated and would logically
//  make a subroutine.  There were also local variables, like FileManager and others that were used throughout.
//  It just seemed messier to break it apart, than to leave it as a single method

#import "FlickrCache.h"
#import "SPoT.h"
#import "UIApplication+NetworkActivity.h"

@implementation FlickrCache

+ (NSData *)flickrImageFromPhoto:(NSURL *)flickrPhotoURL
{
    // This method tries to find the photo URL in the App's cache directory.
    // If the URL is found it is the photo data is fetched from the cache directory and returned.
    // If the photo URL is not found in the App's cache directory,
    // the photo data for the URL is fetched from Flickr and added to the App's cache.
    // If adding the photo data to the cache causes the cache to exceed CACHE_SIZE_LIMIT,
    // then the oldest photo is removed from the cache until the
    // cache size is less than CACHE_SIZE_LIMIT
    
    
#pragma mark - cache directory setup
    // photo as NSData to be returned to the calling method
    NSData *photoData = nil;

    // Remember that [NSFileManager defaultManager] is not thread safe
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    // Get the URL for the cache sandbox
    // (Always specify NSUserDomainMask for iOS - Apple Documentation)
    NSURL *cacheDirectoryURL = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
    
    // Append the name for this App to the URL
    cacheDirectoryURL = [cacheDirectoryURL URLByAppendingPathComponent:RECENT_PHOTO_IMAGES_CACHES_DIRECTORY];
    
    // Create the App's sandbox directory, if it doesn't already exist
    if (![fileManager createDirectoryAtURL:cacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSLog(@"----> Directory creation failed.");
    }
    
    // Create the name for the cached photo
    NSString *uniquePhotoID = [flickrPhotoURL lastPathComponent];
    NSURL *cachePhotoURL = [cacheDirectoryURL URLByAppendingPathComponent:uniquePhotoID];
    
#pragma mark - flickr photo fetch
    // Now check to see if a cache file already exists for this photo
    if (![cachePhotoURL checkResourceIsReachableAndReturnError:nil]) {
        // The photo is NOT in cache so fetch the photo from Flickr

        // Increment Network Activity Indicator counter
        [[UIApplication sharedApplication] showNetworkActivityIndicator];
        
// ----> */ [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        
        // Fetch the image data from Flickr
        // NOTE: The calling method should implement running this class method in another thread
        photoData = [NSData dataWithContentsOfURL:flickrPhotoURL]; // Network Activity!
        
        // Decrement Network Activity Indicator counter
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
       
#pragma mark - obtain cache directory details        
        // Scan through all the files in the App's directory, code borrowed from Documentation of NSFileManager
        NSDirectoryEnumerator *dirEnumerator =
            [fileManager enumeratorAtURL:cacheDirectoryURL
              includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLFileSizeKey, NSURLContentAccessDateKey,nil]
                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                            errorHandler:nil];

        NSUInteger cumulativeSizeOfCachedPhotos = 0;
        NSNumber *fileSizeForCurrentURL;
        NSMutableArray *arrayOfCacheURLs = [NSMutableArray array];

        // Enumerate the dirEnumerator results, each value is stored in arrayOfURLsInCache
        for (NSURL *theURL in dirEnumerator) {
            // Retrieve the file size. From NSURLFileSizeKey, cached during the enumeration.
            [theURL getResourceValue:&fileSizeForCurrentURL forKey:NSURLFileSizeKey error:NULL];
            
            // Get the cumulative size of the photo data in the App cache directory
            cumulativeSizeOfCachedPhotos += fileSizeForCurrentURL.unsignedIntegerValue;
            
            // Create a list of all of the URLs in the App cache directory
            // (There was a 1-liner to create arrayOfCacheURLs, but it looked just like the
            // enumerator above. Since I had to do this enumerator anyway, it seemed more
            // convoluted to do the 1-liner)
            [arrayOfCacheURLs addObject:theURL];
            
        }
        
#pragma mark - remove excess photos from cache        
        NSURL *oldestCacheURL;
        NSURL *currentCacheURL;
        
        NSDate *accessDateForOldestCacheURL;
        NSDate *accessDateForCurrentCacheURL;

        // If adding this photo will exceeds the CACHE_SIZE_LIMIT limit,
        // then delete older photos from cache until the limit is not exceeded
        while ((cumulativeSizeOfCachedPhotos + [photoData length]) > CACHE_SIZE_LIMIT)
        {
            // Find the oldest file
            oldestCacheURL = arrayOfCacheURLs[0]; // This wont be nil because it wont get here unless there are photos
            [oldestCacheURL getResourceValue:&accessDateForOldestCacheURL forKey:NSURLContentAccessDateKey error:NULL];
            
            // Compare the currentCacheURL to the oldestCacheURL to find the oldest. (The 1-liner try was messy)
            for (int arrayIndex = 1; arrayIndex < arrayOfCacheURLs.count; arrayIndex++)
            {
                currentCacheURL = arrayOfCacheURLs[arrayIndex];
                [currentCacheURL getResourceValue:&accessDateForCurrentCacheURL forKey:NSURLContentAccessDateKey error:NULL];
                if ([accessDateForCurrentCacheURL compare:accessDateForOldestCacheURL] == NSOrderedAscending)
                {
                    oldestCacheURL = currentCacheURL;
                    accessDateForOldestCacheURL = accessDateForCurrentCacheURL;
                }
            }
            
            // Delete the oldest file from the App's cache
            if (![fileManager removeItemAtURL:oldestCacheURL error:nil])
            {
                NSLog(@"Failed to remove----> %@", oldestCacheURL);
            }
            
            // Remove the oldestURL from arrayOfURLsInCache
            [arrayOfCacheURLs removeObject:oldestCacheURL];
            
            // Update cumulativeSizeOfCachedPhotos
            NSNumber *fileSizeForOldestURL;
            [oldestCacheURL getResourceValue:&fileSizeForOldestURL forKey:NSURLFileSizeKey error:NULL];
            cumulativeSizeOfCachedPhotos -= fileSizeForOldestURL.unsignedIntegerValue;
        }

#pragma mark - return photo data to calling method
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

@end