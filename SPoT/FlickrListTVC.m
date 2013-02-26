//
//  FlickrListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This is an abstract base class for all of the Table View Contoller (TVC)
//  classes in the SPoT App.  All of the abstract methods provide a template
//  of the task which the derived method should perform.
//
//  The configureCell:cellReuseIdentifier:cellIndexPath: should not be
//  overridden by the derived class.  It provides a generic way to configure each cell
//

#import "FlickrListTVC.h"

@interface FlickrListTVC ()

@end

@implementation FlickrListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO; 
}

#pragma mark - Class specific methods

- (NSString *)getCellSubTitleForRow:(NSUInteger)row
{
    // Abstract method
    return @"Cell subtitle not set";
}

- (NSString *)getCellTitleForRow:(NSUInteger)row
{
    // Abstract method
    return @"Cell title not set";
}

- (UITableViewCell *) configureCell:(UITableView *)tableView
                cellReuseIdentifier:(NSString *)cellReuseId
                      cellIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    
    // Configure the cell
    cell.textLabel.text = [self getCellTitleForRow:indexPath.row];
    cell.detailTextLabel.text = [self getCellSubTitleForRow:indexPath.row];
    
    return cell;
}
 
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Abstract method
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Abstract method, MUST be overriden becuase cellReuseID is static
    
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"Cell";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
