//
//  AllTagPhotoListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/16/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "AllTagPhotoListTVC.h"
#import "Tag.h"

@implementation AllTagPhotoListTVC

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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.sortDescriptors =
        @[[NSSortDescriptor sortDescriptorWithKey:@"tagString"
                                        ascending:YES
                                         selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(firstItem != YES)  AND (undeletedPhotoCount > 0)"];
    
    // Set the fetchedResultsController (from CoreDataTableViewController)
    self.fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:managedObjectContext
                                          sectionNameKeyPath:@"tagString"
                                                   cacheName:nil];
}

- (Photo *)photoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Thanks to Joan for this code to get the set of photos
    
    // Get the Set of photos assiciated with the tag at indexPath
    NSSet *photosInSection = ((Tag *)[[self.fetchedResultsController fetchedObjects]
                                      objectAtIndex:indexPath.section]).photos;
    
    // Filter out user deleted photos
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"isUserDeleted = NO"];
    NSSet *visiblePhotosInSection = [photosInSection filteredSetUsingPredicate:filterPredicate];
    
    // Sort the undeleted photos
    NSArray *sortDescriptors =
        @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
          [NSSortDescriptor sortDescriptorWithKey:@"subtitle" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *sortedVisiblePhotosInSection = [visiblePhotosInSection sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedVisiblePhotosInSection[indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSInteger returnValue = [[[[self.fetchedResultsController fetchedObjects] objectAtIndex:section] undeletedPhotoCount] integerValue];
    return returnValue;
}

@end
