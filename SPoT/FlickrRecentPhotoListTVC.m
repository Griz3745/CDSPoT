//
//  FlickrRecentPhotoListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrRecentPhotoListTVC.h"

@implementation FlickrRecentPhotoListTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
#warning - set the flickrListPhotos from NSUserDefaults 
    // Get array of saved phots from NSUserDefaults
// ---->    NSString *savedURLString; // ----> saved URL string from NSUserDefaults
// ---->    NSURL *flickPhotoURL = [NSURL URLWithString:savedURLString];
// ---->    self.flickrListPhotos = ???

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"Flickr Recent Photo";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
