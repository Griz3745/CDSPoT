//
//  FlickrPhotoListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrPhotoListTVC.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotoListTVC

- (void)setFlickrListPhotos:(NSArray *)flickrListPhotos
{
    // Model for this MVC
    _flickrListPhotos = flickrListPhotos;
    
    // Alphabetically sort the photos
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_TITLE ascending:YES];
    NSSortDescriptor *subTitleDescriptor = [[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_DESCRIPTION ascending:YES];
    _flickrListPhotos = [_flickrListPhotos sortedArrayUsingDescriptors:@[titleDescriptor, subTitleDescriptor]];
    
    // Since the Model has changed, a whole scale reload of the table is necessary
    [self.tableView reloadData];
}

- (NSString *) getCellTitleForRow:(NSUInteger)row
{
    // For the selected row, get the title string
    return [[self.flickrListPhotos objectAtIndex:row] valueForKey:FLICKR_PHOTO_TITLE];
}

- (NSString *) getCellSubTitleForRow:(NSUInteger)row
{
    // For the selected row, get the subtitle string
    return [[self.flickrListPhotos objectAtIndex:row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrListPhotos count];
}

- (void)savePhotoURL:(NSURL *)url
{
    // Abstract method
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Tagged Photo"] ||
                [segue.identifier isEqualToString:@"Show Recent Photo"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    NSURL *url = [FlickrFetcher urlForPhoto:self.flickrListPhotos[indexPath.row] format:FlickrPhotoFormatLarge];
                    [self savePhotoURL:url];
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    [segue.destinationViewController setTitle:[self getCellTitleForRow:indexPath.row]];
                }
            }
        }
    }
}

@end
