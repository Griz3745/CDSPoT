//
//  FlickrTagPhotoListTVC.m
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

#import "FlickrTagPhotoListTVC.h"
#import "SPoT.h"
#import "FlickrFetcher.h"

@implementation FlickrTagPhotoListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Used in base class for the segue to this class
    self.segueIdentifierString = @"Show Tagged Photo";
}

#pragma mark - Class specific methods

// Implementation of method from abstract base class, Optional
// This class wants to save to persistent storage the list of visited photos
- (void)savePhoto:(NSDictionary *)flickrPhoto
{
    // Save Recently viewed photos in NSUserDefaults
    
    // The NSUserDefaults for this app will be an NSArray of NSDictionaries (the photo info)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!recentPhotos) recentPhotos = [[NSMutableArray alloc] init];
    
    // If this photo is not already in recentPhotos, then add it and synchronize NSUserDefaults
    BOOL photoFound = NO;
    for (NSDictionary *element in recentPhotos)
    {
        // FLICKR_PHOTO_ID is unique for each photo
        if ([[element objectForKey:FLICKR_PHOTO_ID] isEqual:[flickrPhoto objectForKey:FLICKR_PHOTO_ID]]) // These are NSStrings
        {
            // The _flickrPhoto is already in the NSUserDefaluts recentsPhotos array
            // and does not need to be added
            photoFound = YES;
            break; // Exit the forLoop (NSDictionary *element in recentPhotos)
        }
    }
    
    if (!photoFound)
    {
        // Limit the size of the persistent storage
        if ([recentPhotos count] >= MAX_PERSISTENT_PHOTOS) {
            [recentPhotos removeLastObject];
        }
        
        // Add this photo to the beginning of the recentPhotos array
        if (flickrPhoto)
        {
            [recentPhotos insertObject:flickrPhoto atIndex:0];
        }
        
        // Update NSUserDefaults
        [defaults setObject:recentPhotos forKey:RECENT_PHOTOS_KEY];
        [defaults synchronize];
    }
}

// Implementation of method from abstract base class
- (void)alphabetizePhotoList
{
    // Alphabetically sort the photos, using the title, and subtitle keys
    // from the Flickr photo description
    NSSortDescriptor *titleDescriptor =
        [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_TITLE ascending:YES];
    NSSortDescriptor *subTitleDescriptor =
        [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_DESCRIPTION ascending:YES];
    self.flickrListPhotos =
        [self.flickrListPhotos sortedArrayUsingDescriptors:@[titleDescriptor, subTitleDescriptor]];
}

#pragma mark - Table view data source

// Implementation of method from abstract base class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"Flickr Tag Photo";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
