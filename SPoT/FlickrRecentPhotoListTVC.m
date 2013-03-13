//
//  FlickrRecentPhotoListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This class implements, in the UI, the list of photos for recent user visits
//
//  It inherits photo list functionality from FlickrPhotoListTVC
//  It inherits standard TVC functionality from FlickrListTVC through FlickrPhotoListTVC
//
//  03/07/2013 - Added support for Core Data database
//

#import "FlickrRecentPhotoListTVC.h"
#import "SPoT.h"

@implementation FlickrRecentPhotoListTVC

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    // Get the list of photos from persistent storage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *recentPhotos = [defaults objectForKey:RECENT_PHOTOS_NSUSERDEFAULTS_KEY];
    
    if (recentPhotos)
    {
        // Assign the persistent photos to this TVC
        // This is the Model for this MVC
        // This is the only place that it gets set
        self.flickrListPhotos = recentPhotos;
    }
}

#pragma mark - Class specific methods

// Callback for the create & open for database document
- (void)documentReady
{
    // Prepare the fetchedResultsController, now that the database is ready
    // ----> */ NSLog(@"Got to documentReady in FlickrRecentPhotoListTVC.m: %@", self.photoDatabaseDocument);
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"Flickr Recent Photo";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
