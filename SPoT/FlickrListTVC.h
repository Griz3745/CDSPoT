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
//  03/07/2013 - Added support for Core Data database
//    NOTE: Each concrete derived class will have its own pointer to the database
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

- (void)documentReady; // Callback for the create & open for database document

// Shared SINGLE instance of the document
@property (strong, nonatomic) UIManagedDocument *photoDatabaseDocument;

@end
