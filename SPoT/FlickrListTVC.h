//
//  FlickrListTVC.h
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
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
