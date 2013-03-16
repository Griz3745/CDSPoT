//
//  FlickrPhotoListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This is an abstract base class for all of the Photo List
//  Table View Contoller (TVC) classes in the SPoT App.
//  All of the abstract methods provide a template
//  of the task which the derived method should perform.
//
//  It inherits standard TVC functionality from FlickrListTVC
//
//  03/12/2013 - Major modification to support use with Core Data
//

#import "FlickrPhotoListTVC.h"
#import "FlickrFetcher.h"
#import "Photo.h"
#import "Tag.h"

@interface FlickrPhotoListTVC() <UISplitViewControllerDelegate>

@end

@implementation FlickrPhotoListTVC

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.splitViewController.delegate = self;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender]; // the selected cell
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setPhoto:"]) { // set in the storyboard
            // Get the selected photo
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            
            if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                // Set the photo in the destination class
                [segue.destinationViewController performSelector:@selector(setPhoto:)
                                                      withObject:photo];
                
                 // Move the splitViewBarButtonItem when the image is switched
                [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
            }
        }
    }
}

#pragma mark - Class specific methods

// Verifies that the returned class implements the getter/setter: splitViewBarButtonItem
- (id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) {
        detail = nil;
    }
    
    return detail;
}

// Move the button from the old TVC and put it on the new TVC, code from Lecture 11 Slides
- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    // Get the old splitViewBarButtonItem
    UIBarButtonItem *splitViewBarButtonItem =
        [[self splitViewDetailWithBarButtonItem] performSelector:@selector(splitViewBarButtonItem)];
    
    // Remove the old splitViewBarButtonItem
    [[self splitViewDetailWithBarButtonItem] performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
    
    // Put the splitViewBarButtonItem on the new destinationViewController
    if (splitViewBarButtonItem) {
        [destinationViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:splitViewBarButtonItem];
    }
}

#pragma mark - <SplitViewControllerDelegate>

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    // Set the barButton title to the sending VC title
    barButtonItem.title = @"Photo List";
    
    // Add the button in the detailViewController
    [[self splitViewDetailWithBarButtonItem] performSelector:@selector(setSplitViewBarButtonItem:)
                                                  withObject:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Remove the button in the detailViewController
    [[self splitViewDetailWithBarButtonItem] performSelector:@selector(setSplitViewBarButtonItem:)
                                                  withObject:nil];
}

#pragma mark - UITableViewDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Fetch the photo from the database
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Mark photo as deleted
        // Don't delete from database, otherwise the refresh method will put it back in
        photo.isUserDeleted = @(YES);
        
        // Update the 'undeletedPhotoCount' for each Tag that this photo is a member
        for (Tag* tag in photo.tags) {
            tag.undeletedPhotoCount = @([tag.undeletedPhotoCount integerValue] - 1);
        }
    }
}

@end
