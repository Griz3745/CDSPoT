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

@interface FlickrTagListTVC ()

// An array of photos fetched from Flickr. This is the Model for the MVC
@property (strong, nonatomic) NSArray *flickrPhotos; // of NSDictionary

// This is an NSDictionary using Flickr Tags as the dictionary Key
// The dictionary Value is an NSArray of photos contining that Tag 
@property (strong, nonatomic) NSMutableDictionary *flickrTaggedPhotos;

// tagList is an array of tags that match the tags in the flickrTaggedPhotos NSDictionary
// ** I hate having to have a seperate data structure for the tags, but the
// tableViewController needs to access by a subscript, and I couldn't find a
// way to access the NSDictionary by subscript.
// I had come up with this idea, and was confirmed on StackOverflow
@property (strong, nonatomic) NSMutableArray *tagList; // all unique tags

@end

@implementation FlickrTagListTVC

- (NSMutableDictionary *)flickrTaggedPhotos
{
    if (!_flickrTaggedPhotos) {
        _flickrTaggedPhotos = [[NSMutableDictionary alloc] init];
    }
    
    return _flickrTaggedPhotos;
}

- (NSMutableArray *)tagList
{
    if (!_tagList) {
        _tagList = [[NSMutableArray alloc] init];
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
    
    // Load the Model for the MVC of this Table View Controller
    // Fetch some photos from Flickr
    self.flickrPhotos = [FlickrFetcher stanfordPhotos];
    
    // Build the list of photo tags
    for (NSDictionary *flickrPhoto in self.flickrPhotos) {
        [self addPhotoToFlickrTaggedPhotos:flickrPhoto];
    }
    
    // Alphabetically sort the tags
    self.tagList =
        [[self.tagList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

#pragma mark - Class specific methods

// This method will search the tags in the provided flickrPhoto
// and will update self.flickrTaggedPhotos with the tag<-->photo association  
- (void)addPhotoToFlickrTaggedPhotos:(NSDictionary *)flickrPhoto
{
    // Keeps track of valid tags for this photo
    NSMutableArray *tagsToProcess = [[NSMutableArray alloc] init];
    
    if (flickrPhoto) {
        // Get the tags from the photo
        NSString *photoTags = [flickrPhoto valueForKey:FLICKR_TAGS];
        NSArray *tagStrings = [photoTags componentsSeparatedByString:@" "];
        
        // Get the non-excluded tags
        for (NSString *tag in tagStrings) {
            if (![[FlickrTagListTVC excludedTags] containsObject:tag]) {
                [tagsToProcess addObject:tag];
            }
        }
        
        // Capitalize the tags (Can't assign to itself in fast enumeration)
        for (int loopCounter = 0; loopCounter < [tagsToProcess count]; loopCounter++)
        {
            tagsToProcess[loopCounter] = [tagsToProcess[loopCounter] capitalizedString];
        }
        
        // Add this photo to the array of photos for this tag
        for (NSString *tag in tagsToProcess) {
            NSMutableArray *taggedPhotos = [[self.flickrTaggedPhotos valueForKey:tag] mutableCopy];
            
            // if taggedPhotos is nil then
            // this tag is not in the self.flickrTaggedPhotos dicitonary yet
            if (!taggedPhotos) {
                // This is a new tag, create a photo array for it
                taggedPhotos = [[NSMutableArray alloc] init];
                
                // Add a tag to the list
                [self.tagList addObject:tag];
            }
            
            // Add this photo to photo array for this tag
            [taggedPhotos addObject:flickrPhoto];
            
            // Creates a new tag/photo array entry in the self.flickrTaggedPhotos dictionary,
            // Or Replaces the photo array for the tag
            [self.flickrTaggedPhotos setObject:taggedPhotos forKey:tag];
        }
    }
}

// Implementation of method from abstract base class
- (NSString *) getCellTitleForRow:(NSUInteger)row
{
    // The Title for this TVC is the Tag
    
    // For the selected row, get the title string
    return self.tagList[row];
}

// Implementation of method from abstract base class
- (NSString *) getCellSubTitleForRow:(NSUInteger)row
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
                    [segue.destinationViewController setTitle:[self getCellTitleForRow:indexPath.row]];
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
