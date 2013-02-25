//
//  FlickrPhotoListTVC.h
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrListTVC.h"

@interface FlickrPhotoListTVC : FlickrListTVC

// Model for this MVC
@property (strong, nonatomic) NSArray *flickrListPhotos; // of NSDictionary

// Abstract methods - implemented by derived classes
- (void)savePhotoURL:(NSURL *)url;

@end
