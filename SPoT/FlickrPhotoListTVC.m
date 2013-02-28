//
//  FlickrPhotoListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This is an abstract base class for all of the Photo List
//  Table View Contoller (TVC) classes in the SPoT App.
//  All of the abstract methods provide a template
//  of the task which the derived method should perform.
//
//  It inherits standard TVC functionality from FlickrListTVC
//

#import "FlickrPhotoListTVC.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotoListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Alphabetize photo list
    // calling an abstract method
    [self alphabetizePhotoList];
}

#pragma mark - Class specific methods

// Save the photo description, not the image
- (void)savePhoto:(NSDictionary *)flickrPhoto
{
    // Abstract method
    // This method is NOT required
    // Only for derived classes which need to perform the save operation
    // to persistent storage
}

- (void)alphabetizePhotoList
{
    // Abstract
    // This method is NOT required
    // Only for derived classes which want an alphabetized list
}

- (void)setFlickrListPhotos:(NSArray *)flickrListPhotos
{
    // Model for this MVC, can be set externally
    _flickrListPhotos = flickrListPhotos;
    
    // Since the Model has changed, a whole scale reload of the table is necessary
    [self.tableView reloadData];
}

// Implementation of method from abstract base class
- (NSString *) cellTitleForRow:(NSUInteger)row
{
    // For the selected row, get the photo's title string
    return [[self.flickrListPhotos objectAtIndex:row] valueForKey:FLICKR_PHOTO_TITLE];
}

// Implementation of method from abstract base class
- (NSString *) cellSubTitleForRow:(NSUInteger)row
{
    // For the selected row, get the photo's subtitle string
    return [[self.flickrListPhotos objectAtIndex:row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; // the selected cell
        if (indexPath) {
            if ([segue.identifier isEqualToString:self.segueIdentifierString]) { // set in the storyboard
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    
                    // This line actually fetches the photo from Flickr
                    NSURL *url = [FlickrFetcher urlForPhoto:self.flickrListPhotos[indexPath.row] format:FlickrPhotoFormatLarge];
                    
                    // Save the photo description, not the image
                    [self savePhoto:self.flickrListPhotos[indexPath.row]];
                    
                    // Set the photo in the destination class
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:url];
                    
                    // Set the title of the destination view controller
                    [segue.destinationViewController setTitle:[self cellTitleForRow:indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrListPhotos count];
}
@end
