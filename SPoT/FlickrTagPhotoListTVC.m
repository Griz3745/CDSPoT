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
//  03/12/2013 - Added support for Core Data database
//

#import "FlickrTagPhotoListTVC.h"
#import "Photo.h"

@implementation FlickrTagPhotoListTVC

- (void)setTagForPhotos:(Tag *)tagForPhotos
{
    _tagForPhotos = tagForPhotos;
    self.title = tagForPhotos.tagString;
    [self setupFetchedResultsController];
}

#pragma mark - Class specific methods

- (void)setupFetchedResultsController
{
    if (self.tagForPhotos.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors =
            @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                            ascending:YES
                                             selector:@selector(localizedCaseInsensitiveCompare:)],
              [NSSortDescriptor sortDescriptorWithKey:@"subtitle"
                                            ascending:YES
                                             selector:@selector(localizedCaseInsensitiveCompare:)]];
        // Thank you Joan for the syntax for this predicate
        request.predicate = [NSPredicate predicateWithFormat:@"%@ IN tags", self.tagForPhotos];  
        
        self.fetchedResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                managedObjectContext:self.tagForPhotos.managedObjectContext
                                                  sectionNameKeyPath:nil
                                                           cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - Table view data source

// Implementation of method from abstract base class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Flickr Tag Photo"];
    
    // Fetch a photo from the database
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Flesh out the cell based on the database information
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    return cell;
}

@end
