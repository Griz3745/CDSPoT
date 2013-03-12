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

#import "CoreDataTableViewController.h"

@interface FlickrListTVC : CoreDataTableViewController

// Handle for the database
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// -- Methods available to derived class --
// Open database document on disk
- (void)useDocument; 

// -- Abstract methods to be implemented by the derived class --
// Required abstract method to reset the fetchedResultsController
- (void)documentReady:(NSManagedObjectContext *)managedObjectContext;

// Optional abstract method for reloading the database
- (void)refresh;

@end
