//
//  FlickrCache.h
//  FlickrPlaces
//
//  Created by Michael Grysikiewicz on 11/24/12.
//  Copyright (c) 2012 Michael Grysikiewicz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrCache : NSObject

+ (NSData *) flickrImageFromPhoto:(NSDictionary *) photo;

@end
