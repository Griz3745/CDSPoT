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
#import "Photo.h"

@implementation FlickrRecentPhotoListTVC

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.managedObjectContext) {
        [self useDocument]; // Super class method to open the database file
    }
}

#pragma mark - Class specific methods

// Callback for the create & open for database document
- (void)documentReady:(NSManagedObjectContext *)managedObjectContext
{
    // Build the fetch request that will be used to populate the TVC
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors =
        @[[NSSortDescriptor sortDescriptorWithKey:@"lastAccessTime" ascending:NO]];
    [request setFetchLimit:MAX_RECENT_PHOTOS];
    request.predicate = [NSPredicate predicateWithFormat:@"lastAccessTime != nil"];
    
    // Set the fetchedResultsController (from CoreDataTableViewController)
    self.fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
}

#pragma mark - Table view data source

// Implementation of method from abstract base class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Recent Photo"];
    
    // Fetch a photo from the database
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Flesh out the cell based on the database information
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnailImage];

    return cell;
}

@end
