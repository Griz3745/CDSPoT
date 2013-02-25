//
//  FlickrTagPhotoListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrTagPhotoListTVC.h"

@implementation FlickrTagPhotoListTVC

- (void)savePhotoURL:(NSURL *)url
{
    // Abstract method
#warning - save url to NSUserDefaults
    // ---->     NSString *urlAsString = [NSURL URLWithString:<#(NSString *)#>]
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"Flickr Tag Photo";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
