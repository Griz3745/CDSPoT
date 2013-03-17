//
//  FlickrTagListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This class implements, in the UI, the list of Flickr Tags from 
//  photos that have been fetched from Flickr
//
//  It inherits standard TVC functionality from FlickrListTVC
//
//  03/07/2013 - Major modification to support for Core Data database
//

#import "FlickrTagListTVC.h"
#import "FlickrFetcher.h"
#import "UIApplication+NetworkActivity.h"
#import "Tag.h"
#import "Photo+Flickr.h"

@implementation FlickrTagListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // <Ctrl-drag> is broken for refreshControl, so add Target/Action manually
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.managedObjectContext) {
        [self useDocument]; // Super class method to open the database file
    }
    
    // If the database file was created, but not properly populated, try again to populate
    // This addresses Assignment 6, Hint 11
    if (self.fetchedResultsController.fetchedObjects) {
        if (![self.fetchedResultsController.fetchedObjects count]) {
            [self refresh];
        }
    }
}

#pragma mark - Class specific methods

// Prepare the fetchedResultsController, now that the database is ready
- (void)documentReady:(NSManagedObjectContext *)managedObjectContext
{
    // Build the fetch request that will be used to populate the TVC
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors =
    @[[NSSortDescriptor sortDescriptorWithKey:@"firstItem"
                                    ascending:NO],
      [NSSortDescriptor sortDescriptorWithKey:@"tagString"
                                    ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    // Don't fetch tags which have no more 'undeleted' photos
    request.predicate = [NSPredicate predicateWithFormat:@"undeletedPhotoCount > 0"];
    
    // Set the fetchedResultsController (from CoreDataTableViewController)
    self.fetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                            managedObjectContext:managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
}

// Implementation of Super Class's optional abstract method for reloading the database
- (void)refresh
{
    // Start the display of the activity indicator for the TVC
    [self.refreshControl beginRefreshing];
    
    // Fetch the photo array from Flickr
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr photo array downloader", NULL);
    dispatch_async(downloadQueue, ^{
        // Increment Network Activity Indicator counter
        [[UIApplication sharedApplication] showNetworkActivityIndicator];
        
// ----> */        [NSThread sleepForTimeInterval:2.0];
        
        // Load the Flickr photo dictionaries
        NSArray *latestPhotos = [FlickrFetcher stanfordPhotos]; // NETWORK Activity!

        // Decrement Network Activity Indicator counter
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        
        // Set the FlickrPhotoFormat
        FlickrPhotoFormat spotPhotoFormat;
        if (self.splitViewController) { // iPad
            spotPhotoFormat = FlickrPhotoFormatOriginal;
        } else {
            spotPhotoFormat = FlickrPhotoFormatLarge;
        }
        
        // Use 'performBlock to assure that the access to the database occurs
        // in the same thread that the database was created
       [self.managedObjectContext performBlock:^{ // don't assume main thread
            // Add the photos to the database. This is the Model for the App
           for (NSDictionary *photo in latestPhotos) {
                [Photo photoWithFlickrInfo:photo
                    inManagedObjectContext:self.managedObjectContext
                               usingFormat:spotPhotoFormat];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                // End the display of the activity indicator for the TVC
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

- (void)debugCDDebugTagPrint
{
/* ----> */
    if (self.debug) {
        [self.managedObjectContext performBlock:^{ // don't assume main thread
            // Build a query to see if the tag is in the database
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstItem"
                                                                      ascending:YES]];
// ----> selector:@selector(localizedCaseInsensitiveCompare:)]];
            request.predicate = nil;
            
            // Execute the query
            NSError *error;
            NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
            for (Tag *dbTag in matches) {
                NSLog(@"matches:%@", dbTag.tagString);
                for (Photo *dbPhoto in dbTag.photos) {
                    NSLog(@"    %@, %@", dbPhoto.title, dbPhoto.subtitle);
                }
            }
            int i;
            i = 0; // This is here just for a spot to  put the breakpoint
        }];
    }
/* ----> */
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender]; // the selected cell
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setTagForPhotos:"]) { // set in storyboard
            // Get the selected tag
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            if ([segue.destinationViewController respondsToSelector:@selector(setTagForPhotos:)]) {
                // Set the Tag in the destination view controller
                [segue.destinationViewController performSelector:@selector(setTagForPhotos:) withObject:tag];
            }
        }
    }
}

#pragma mark - Table view data source

// Must still implement this method from the TableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    Tag* tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Pull a cell prototype from the pool
    if ([tag.firstItem boolValue]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AllPhotoTag"];

    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FlickrTag"];
    }
    
    // Pull the data from the database, using the fetch setup when the fetchedResults controller was created
    cell.textLabel.text = tag.tagString;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photo%@",
                                 tag.undeletedPhotoCount, ([tag.undeletedPhotoCount integerValue] == 1) ? @"" : @"s"];

    return cell;
}

@end
