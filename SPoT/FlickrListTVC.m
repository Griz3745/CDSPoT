//
//  FlickrListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrListTVC.h"

@interface FlickrListTVC ()

@end

@implementation FlickrListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO; 
}

#pragma mark - Table view data source

- (NSString *) getCellSubTitleForRow:(NSUInteger)row
{
    // Abstract method
    return @"Cell subtitle not set";
}

- (NSString *) getCellTitleForRow:(NSUInteger)row
{
    // Abstract method
    return @"Cell title not set";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Abstract method
    return 0;
}

- (UITableViewCell *) configureCell:(UITableView *)tableView cellReuseIdentifier:(NSString *)cellReuseId cellIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    // Configure the cell
    cell.textLabel.text = [self getCellTitleForRow:indexPath.row];
    cell.detailTextLabel.text = [self getCellSubTitleForRow:indexPath.row];
    
    return cell;
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"Cell";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
