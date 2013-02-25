//
//  FlickrTagListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrTagListTVC.h"
#import "FlickrFetcher.h"

@interface FlickrTagListTVC ()

@property (strong, nonatomic) NSArray *flickrPhotos; // of NSDictionary

@end

@implementation FlickrTagListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.flickrPhotos = [FlickrFetcher stanfordPhotos];
#warning - NSLog here
    NSLog(@"%@", self.flickrPhotos[0]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Tag Photo List"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setFlickrListPhotos:)]) {
#warning - incorrect implementation - send tagged photo list
                    [segue.destinationViewController performSelector:@selector(setFlickrListPhotos:) withObject:self.flickrPhotos];
                    [segue.destinationViewController setTitle:[self getCellTitleForRow:indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSString *) getCellTitleForRow:(NSUInteger)row
{
    // For the selected row, get the title string
#warning - incorrect implementation
/* ----> */    return [[self.flickrPhotos objectAtIndex:row] valueForKey:FLICKR_PHOTO_TITLE];
}

- (NSString *) getCellSubTitleForRow:(NSUInteger)row
{
    // For the selected row, get the subtitle string
#warning - incorrect implementation
    /* ----> */    return [[self.flickrPhotos objectAtIndex:row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"FlickrTag";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
