//
//  Photo+Flickr.h
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/9/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "Photo.h"
#import "FlickrFetcher.h"

@interface Photo (Flickr)

// Create a database entry for the given photo in the give context
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
                   usingFormat:(FlickrPhotoFormat)flickrFormat;

@end
