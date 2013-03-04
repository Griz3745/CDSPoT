//
//  FlickrCache.h
//  FlickrPlaces
//
//  Created by Michael Grysikiewicz on 11/24/12.
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

#import <Foundation/Foundation.h>

@interface FlickrCache : NSObject

//
//  NOTE: The calling method should implement running this class method in another thread
//
+ (NSData *) flickrImageFromPhoto:(NSURL *)flickrPhotoURL;

@end
