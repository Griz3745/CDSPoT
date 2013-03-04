//
//  FlickrListTVC.h
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

#import <UIKit/UIKit.h>

@interface FlickrListTVC : UITableViewController

// Methods called by derived classes
- (UITableViewCell *) configureCell:(UITableView *)tableView
                cellReuseIdentifier:(NSString *)cellReuseId
                      cellIndexPath:(NSIndexPath *)indexPath;


// Abstract methods which the derived classes must implement
- (NSString *)cellTitleForRow:(NSUInteger)row;
- (NSString *)cellSubTitleForRow:(NSUInteger)row;

@end
