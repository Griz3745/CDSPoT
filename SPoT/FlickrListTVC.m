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
//  03/07/2013 - Added support for Core Data database
//    NOTE: Each concrete derived class will have its own pointer to the database
//

#import "FlickrListTVC.h"
#import "SingletonForManagedDocument.h"

@implementation FlickrListTVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        // Reset the fetchedResultsController whenever a new managedObjectContext is set
        [self documentReady:managedObjectContext];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - Class specific methods

- (void)documentReady:(NSManagedObjectContext *)managedObjectContext
{
    // Required abstract method to reset the fetchedResultsController
}
-
(void)refresh
{
    // Optional abstract method for reloading the database
}

- (void) useDocument
{
    UIManagedDocument *document =
        [SingletonForManagedDocument sharedSingletonInstance].sharedManagedDocument;

    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
         // does not exidst on disk, so create it
         [document saveToURL:document.fileURL
            forSaveOperation:UIDocumentSaveForCreating
           completionHandler:^(BOOL success) {
               if (success) {
                   self.managedObjectContext = document.managedObjectContext;
                   // Initilaize the TVC with photos
                   [self refresh]; // Reloads the photos
               }
           }];
     } else if (document.documentState == UIDocumentStateClosed) {
         // exists on disk, but we need to open it
         [document openWithCompletionHandler:^(BOOL success) {
             if (success) {
                 self.managedObjectContext = document.managedObjectContext;
             }
         }];
     } else if (document.documentState == UIDocumentStateNormal) {
         self.managedObjectContext = document.managedObjectContext;
     }
}

@end
