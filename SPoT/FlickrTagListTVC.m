//
//  FlickrTagListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This class implements, in the UI, the list of Flickr Tags from 
//  photos that have been fetched from Flickr
//
//  It inherits standard TVC functionality from FlickrListTVC
//

#import "FlickrTagListTVC.h"
#import "FlickrFetcher.h"
#import "UIApplication+NetworkActivity.h"

@interface FlickrTagListTVC ()

// An array of photos fetched from Flickr. This is the Model for the MVC
@property (strong, nonatomic) NSArray *flickrPhotos; // of NSDictionary

// This is an NSDictionary using Flickr Tags as the dictionary Key
// The dictionary Value is an NSArray of photos contining that Tag 
@property (strong, nonatomic) NSDictionary *flickrTaggedPhotos;

// tagList is an array of Tags that match the tags in the flickrTaggedPhotos NSDictionary
// ** I hate having to have a seperate data structure for the tags, but the
// tableViewController needs to access by a subscript, and I couldn't find a
// way to access the NSDictionary by subscript.
// I had come up with this idea, and was confirmed on StackOverflow
@property (strong, nonatomic) NSArray *tagList; // all unique tags

@end

@implementation FlickrTagListTVC

- (NSDictionary *)flickrTaggedPhotos
{
    if (!_flickrTaggedPhotos) {
        _flickrTaggedPhotos = [[NSDictionary alloc] init];
    }
    
    return _flickrTaggedPhotos;
}

- (NSArray *)tagList
{
    if (!_tagList) {
        _tagList = [[NSArray alloc] init];
    }
    
    return _tagList;
}

// These tags were specifically excluded in Assignment IV, Requirement 3
+ (NSArray *)excludedTags
{
    return @[@"cs193pspot", @"portrait", @"landscape"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initilaize the TVC with photos
    [self loadStanfordFlickrPhotos];
    
    // <Ctrl-drag> is broken for refreshControl, so add Target/Action manually
    [self.refreshControl addTarget:self
                            action:@selector(loadStanfordFlickrPhotos)
                  forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Class specific methods

- (void)loadStanfordFlickrPhotos
{
    // Start the display of the activity indicator for the TVC
    [self.refreshControl beginRefreshing];
    
    // Fetch the photo array from Flickr
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr photo array downloader", NULL);
    dispatch_async(downloadQueue, ^{
        // Increment Network Activity Indicator counter
        [[UIApplication sharedApplication] showNetworkActivityIndicator];
        
// ----> */        [NSThread sleepForTimeInterval:2.0];
        
        // Load the Model for the MVC of this Table View Controller
        // by fetching some photos from Flickr
        NSArray *latestPhotos = [FlickrFetcher stanfordPhotos]; // NETWORK Activity!

        // Decrement Network Activity Indicator counter
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Reset data structures which manage tags
            self.flickrTaggedPhotos = nil;
            self.tagList = nil;
            
            // Only access self.flickrPhotos in the main thread
            self.flickrPhotos = latestPhotos;
            
            // Build the list of photo tags
            for (NSDictionary *flickrPhoto in self.flickrPhotos) {
                [self addPhotoToFlickrTaggedPhotos:flickrPhoto];
            }
            
            // Build the list of tags found in self.flickrTaggedPhotos NSDictionary
            self.tagList = [self.flickrTaggedPhotos allKeys]; // Recommended by Joan-Carles
            
            // Alphabetically sort the tags
            self.tagList =
                [self.tagList sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            
            // Show the results of the fetch in the TVC after the thread has completed
            [self.tableView reloadData];
            
            // End the display of the activity indicator for the TVC
            [self.refreshControl endRefreshing];
        });
    });
}

// This method will search the tags in the provided flickrPhoto
// and will update self.flickrTaggedPhotos with the tag<-->photo association  
- (void)addPhotoToFlickrTaggedPhotos:(NSDictionary *)flickrPhoto
{
    if (flickrPhoto) {
        // Copy to be modified within this method
        NSMutableDictionary *mutableFlickrTaggedPhotos = [self.flickrTaggedPhotos mutableCopy];
        // Keeps track of valid tags for this photo
        NSMutableArray *tagsToProcess = [[NSMutableArray alloc] init];
        
        // Get the tags from the photo
        NSString *photoTags = [flickrPhoto valueForKey:FLICKR_TAGS];
        NSArray *tagStrings = [photoTags componentsSeparatedByString:@" "];
        
        // Get the non-excluded tags
        for (NSString *tag in tagStrings) {
            if (![[FlickrTagListTVC excludedTags] containsObject:tag]) {
                [tagsToProcess addObject:tag];
            }
        }
        
        // Capitalize the tags (Can't assign to itself in fast enumeration above)
        // Capitalize the string per Assignment IV, Requirement 3
        for (int loopCounter = 0; loopCounter < [tagsToProcess count]; loopCounter++)
        {
            tagsToProcess[loopCounter] = [tagsToProcess[loopCounter] capitalizedString];
        }
        
        // Add this photo to the array of photos for this tag
        for (NSString *tag in tagsToProcess) {
            
            // Get the array of photos already associated with tag
            NSMutableArray *taggedPhotos = [[mutableFlickrTaggedPhotos valueForKey:tag] mutableCopy];
            
            // if taggedPhotos is nil then
            // this tag is not in the self.flickrTaggedPhotos dicitonary yet
            if (!taggedPhotos) {
                // This is a new tag, create a photo array for it
                taggedPhotos = [[NSMutableArray alloc] init];
            }
            
            // Add this photo to the photo array for this tag
            [taggedPhotos addObject:flickrPhoto];
            
            // Creates a new tag/photo array entry in the self.flickrTaggedPhotos dictionary,
            // Or Replaces the photo array for the tag
            [mutableFlickrTaggedPhotos setObject:taggedPhotos forKey:tag];
        }
        self.flickrTaggedPhotos = mutableFlickrTaggedPhotos;
    }
}

// Implementation of method from abstract base class
- (NSString *) cellTitleForRow:(NSUInteger)row
{
    // The Title for this TVC is the Tag
    
    // For the selected row, get the title string
    return self.tagList[row];
}

// Implementation of method from abstract base class
- (NSString *) cellSubTitleForRow:(NSUInteger)row
{
    // The Subtitle for this TVC is number of photos for the Tag
    
    // For the selected row, get the photos for the tag
    NSArray *taggedPhotos = [self.flickrTaggedPhotos valueForKey:self.tagList[row]];
    
    // Get the subtitle string using the number of photos
    return [NSString stringWithFormat:@"%d", [taggedPhotos count]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender]; // the selected cell
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Tag Photo List"]) { // set in storyboard
                if ([segue.destinationViewController respondsToSelector:@selector(setFlickrListPhotos:)]) {
                    
                    // Get the array of photos associated with the tag
                    NSArray *taggedPhotos = [self.flickrTaggedPhotos valueForKey:self.tagList[indexPath.row]];
                    
                    // Send the photos for the tag
                    [segue.destinationViewController performSelector:@selector(setFlickrListPhotos:) withObject:taggedPhotos];
                    
                    // Set the title to the tag being shown
                    [segue.destinationViewController setTitle:[self cellTitleForRow:indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - Table view data source

// Implementation of method from abstract base class
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrTaggedPhotos count];
}

// Implementation of method from abstract base class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"FlickrTag";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
