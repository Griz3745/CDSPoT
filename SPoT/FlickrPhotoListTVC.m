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
#import "Tag.h"
#import "FlickrCache.h"
#import "UIApplication+NetworkActivity.h"

@interface FlickrPhotoListTVC() <UISplitViewControllerDelegate>

// Tracks an association between a cell and the current photo for that cell
// Necessary to prevent redrawing of thumbnails when a cell is reused
@property (strong, nonatomic) NSMutableDictionary *cellThumbnails;

@end

@implementation FlickrPhotoListTVC

- (NSMutableDictionary *) cellThumbnails
{
    if (!_cellThumbnails) _cellThumbnails = [[NSMutableDictionary alloc] init];
    
    return _cellThumbnails;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.splitViewController.delegate = self;
}

#pragma mark - Segue

- (Photo *)photoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender]; // the selected cell
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setPhoto:"]) { // set in the storyboard
            // Get the selected photo
            Photo *photo = [self photoForRowAtIndexPath:(NSIndexPath *)indexPath];
            
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
        Photo *photo = [self photoForRowAtIndexPath:(NSIndexPath *)indexPath];
        
        // Mark photo as deleted
        // Don't delete from database, otherwise the refresh method will put it back in
        photo.isUserDeleted = @(YES);
        
        // Update the 'undeletedPhotoCount' for each Tag that this photo is a member
        for (Tag* tag in photo.tags) {
            tag.undeletedPhotoCount = @([tag.undeletedPhotoCount integerValue] - 1);
        }
        
        id imageViewController = [self.splitViewController.viewControllers lastObject];
        
        if ([imageViewController respondsToSelector:@selector(setPhoto:)] &&
            [imageViewController respondsToSelector:@selector(photo)]) {
            
            if ([photo isEqual:[imageViewController performSelector:@selector(photo) withObject:photo]]) {
                // This is the same photo, but now it is marked for deletion
                [imageViewController performSelector:@selector(setPhoto:) withObject:photo];
            }
        }
        
        // Remove the photo from cache
        [FlickrCache removePhotoURL:[NSURL URLWithString:photo.imageURL]];
        
        // This reloadData is necessary because AllTagPhotoListTVC fetches Tags, but displays Photos
        // so the auto-refresh of the fetchResultsController does not detect the change a refresh automatically
        [self.tableView reloadData];
    }
}

// Implementation of method from abstract base class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSInteger cellTag = 1;

    // Pull a cell prototype from the pool
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];

    // Fetch a photo from the database
    Photo *photo = [self photoForRowAtIndexPath:(NSIndexPath *)indexPath];
    
    // Flesh out the cell based on the database information
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
    
    if (!photo.thumbnailImage) {
        
        NSString *uniqueCellIdentifier;
        
        // Cells start with a tag of 0, so I give each new one a unique tag
        // A non-zero tag means the cell is being reused
        if (cell.tag == 0)
        {
            cell.tag = cellTag++;
        }
        
        // Convert the tag to a string so that it can be used as a key in the Dictionary
        uniqueCellIdentifier = [NSString stringWithFormat:@"%d", cell.tag];
        
        // Tracks an association between a cell and the current photo for that cell
        // Necessary to prevent redrawing of thumbnails when a cell is reused
        self.cellThumbnails[uniqueCellIdentifier] = photo;
        
        // Fetch the photo's thumbnail from Flickr
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr thumbnail downloader", NULL);
        dispatch_async(downloadQueue, ^{
            // Increment Network Activity Indicator counter
            [[UIApplication sharedApplication] showNetworkActivityIndicator];
            
            // Fetch the thumbnail from Flickr
            NSData *thumbnailData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            
            // Decrement Network Activity Indicator counter
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            
            // Use 'performBlock to assure that the access to the database occurs
            // in the same thread that the database was created
            dispatch_async(dispatch_get_main_queue(), ^{
                Photo *currentPhotoForCell = self.cellThumbnails[uniqueCellIdentifier];
                if ([photo isEqual:currentPhotoForCell]) {
                    // Tell the cell to redraw
                    cell.imageView.image = [[UIImage alloc] initWithData:thumbnailData];
// ----> */                    [cell setNeedsDisplay];
/* ----> */                     NSLog(@"Photo is displayed for cell.tag:%d", cell.tag);
                } else {
/* ----> */                    NSLog(@"Photo has changed for cell.tag:%d", cell.tag);
                }
                [photo.managedObjectContext performBlock:^{ // don't assume main thread
                    photo.thumbnailImage = thumbnailData;
                }];
            });
        });
    } else {
        cell.imageView.image = [[UIImage alloc] initWithData:photo.thumbnailImage];
    }

    return cell;
}

@end
