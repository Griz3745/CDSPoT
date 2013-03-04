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

#import "FlickrRecentPhotoListTVC.h"
#import "SPoT.h"

@implementation FlickrRecentPhotoListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Used in base class for the segue to this class
    self.segueIdentifierString = @"Show Recent Photo";
}

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

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"Flickr Recent Photo";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
