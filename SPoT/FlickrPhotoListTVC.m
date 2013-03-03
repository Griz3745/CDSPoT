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

#import "FlickrPhotoListTVC.h"
#import "FlickrFetcher.h"

@interface FlickrPhotoListTVC() <UISplitViewControllerDelegate>

@end

@implementation FlickrPhotoListTVC

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.splitViewController.delegate = self;
// ----> //    self.backButtonTitle = @"SPoT";
// ----> //    NSLog(@"FlickrPhotoListTVC:awakeFromNib Title: %@", self.backButtonTitle);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Alphabetize photo list
    // calling an abstract method
    [self alphabetizePhotoList];
}

/* ---->
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
// ----> //    NSLog(@"FlickrPhotoListTVC Title: %@", self.title);
// ----> //    self.backButtonTitle = self.title;
}
----> */

#pragma mark - Class specific methods

// Save the photo description, not the image
- (void)savePhoto:(NSDictionary *)flickrPhoto
{
    // Abstract method
    // This method is NOT required
    // Only for derived classes which need to perform the save operation
    // to persistent storage
}

- (void)alphabetizePhotoList
{
    // Abstract
    // This method is NOT required
    // Only for derived classes which want an alphabetized list
}

- (void)setFlickrListPhotos:(NSArray *)flickrListPhotos
{
    // Model for this MVC, can be set externally
    _flickrListPhotos = flickrListPhotos;
    
    // Since the Model has changed, a whole scale reload of the table is necessary
    [self.tableView reloadData];
}

// Implementation of method from abstract base class
- (NSString *) cellTitleForRow:(NSUInteger)row
{
    // For the selected row, get the photo's title string
    return [[self.flickrListPhotos objectAtIndex:row] valueForKey:FLICKR_PHOTO_TITLE];
}

// Implementation of method from abstract base class
- (NSString *) cellSubTitleForRow:(NSUInteger)row
{
    // For the selected row, get the photo's subtitle string
    return [[self.flickrListPhotos objectAtIndex:row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
}

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

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    // Get the old splitViewBarButtonItem
    UIBarButtonItem *splitViewBarButtonItem =
        [[self splitViewDetailWithBarButtonItem] performSelector:@selector(splitViewBarButtonItem)];
    
    // Remove the old splitViewBarButtonItem
    [[self splitViewDetailWithBarButtonItem] performSelector:@selector(setSplitViewBarButtonItem:) withObject:nil];
    
    // Put the splitViewBarButtonItem on the new destinationViewController
    if (splitViewBarButtonItem) {
// ---->        splitViewBarButtonItem.title = self.backButtonTitle;
        [destinationViewController performSelector:@selector(setSplitViewBarButtonItem:) withObject:splitViewBarButtonItem];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; // the selected cell
        if (indexPath) {
            if ([segue.identifier isEqualToString:self.segueIdentifierString]) { // set in the storyboard
                if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                    
                    // Build the Flickr URL for this photo
                    FlickrPhotoFormat spotPhotoFormat;
                    if (self.splitViewController) { // iPad
                        spotPhotoFormat = FlickrPhotoFormatOriginal;
                    } else {
                        spotPhotoFormat = FlickrPhotoFormatLarge;
                    }
                    NSURL *spotPhotoURL = [FlickrFetcher urlForPhoto:self.flickrListPhotos[indexPath.row] format:spotPhotoFormat];
                    
                    // Save the photo description, not the image
                    [self savePhoto:self.flickrListPhotos[indexPath.row]];
                    
                    // Set the photo in the destination class
                    [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:spotPhotoURL];
                    
                    // Set the title of the destination view controller
                    [segue.destinationViewController setTitle:[self cellTitleForRow:indexPath.row]];
                    
                    // Move the splitViewBarButtonItem when the image is switched
                    [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrListPhotos count];
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
// ---->    barButtonItem.title = self.backButtonTitle;
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

@end
