//
//  FlickrTagPhotoListTVC.h
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This class implements, in the UI, the list of photos for a particular tag
//
//  It inherits photo list functionality from FlickrPhotoListTVC
//  It inherits standard TVC functionality from FlickrListTVC through FlickrPhotoListTVC
//

#import "FlickrPhotoListTVC.h"
#import "Tag.h"

@interface FlickrTagPhotoListTVC : FlickrPhotoListTVC

// Model for this MVC, can be set externally
@property (strong, nonatomic) Tag *tagForPhotos;

@end
