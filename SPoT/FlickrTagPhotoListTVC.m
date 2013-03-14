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
#import "UIApplication+NetworkActivity.h"

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
    cell.imageView.image = [UIImage imageWithData:photo.thumbnailImage];
    
    if (!photo.thumbnailImage) {
        // Fetch the photo's thumbnail from Flickr
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr thumbnail downloader", NULL);
        dispatch_async(downloadQueue, ^{
            // Increment Network Activity Indicator counter
            [[UIApplication sharedApplication] showNetworkActivityIndicator];
            
            // Fetch the thumbnail from Flickr
            NSData *thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            
            // Decrement Network Activity Indicator counter
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            
            // Use 'performBlock to assure that the access to the database occurs
            // in the same thread that the database was created
            [photo.managedObjectContext performBlock:^{ // don't assume main thread
                photo.thumbnailImage = thumbnailData;
            }];
        });
    }
    
    return cell;
}

@end
