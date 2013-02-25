//
//  FlickrTagListTVC.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/24/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "FlickrTagListTVC.h"
#import "FlickrFetcher.h"

@interface FlickrTagListTVC ()

@property (strong, nonatomic) NSArray *flickrPhotos; // of NSDictionary
@property (strong, nonatomic) NSMutableDictionary *flickrTaggedPhotos; // tag / NSArray of photos(NSDictionary)

// tagList is an array of tags that are in the flickrTaggedPhotos NSDictionary
// I hate having to have a seperate data structure for the tags, but the
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

+ (NSArray *)excludedTags
{
    return @[@"cs193pspot", @"portrait", @"landscape"];
}

- (void)addPhotoToFlickrTaggedPhotos:(NSDictionary *)flickrPhoto
{
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
        
        // Capitalize the tags
        for (int loopCounter = 0; loopCounter < [tagsToProcess count]; loopCounter++)
        {
            tagsToProcess[loopCounter] = [tagsToProcess[loopCounter] capitalizedString];
        }
        
        // Add this photo to the array of photos for this tag
        for (NSString *tag in tagsToProcess) {
            NSMutableArray *taggedPhotos = [[self.flickrTaggedPhotos valueForKey:tag] mutableCopy];
            if (!taggedPhotos) {
                // If this is a new tag, create a photo array for it
                taggedPhotos = [[NSMutableArray alloc] init];
                
                // Add a tag to the list
                [self.tagList addObject:tag];
            }
            
            // Add this photo to photo array for this tag
            [taggedPhotos addObject:flickrPhoto];
            
            // Creates a new tag/photo array, Or Replaces the photo array for the tag
            [self.flickrTaggedPhotos setObject:taggedPhotos forKey:tag];
        }
        
        // Alphabetically sort the tags
        self.tagList = [[self.tagList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fetch some photos from Flickr
    self.flickrPhotos = [FlickrFetcher stanfordPhotos];

    // Build the list of photo tags
    for (NSDictionary *flickrPhoto in self.flickrPhotos) {
        [self addPhotoToFlickrTaggedPhotos:flickrPhoto];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Tag Photo List"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setFlickrListPhotos:)]) {
                    
                    // Get the array of photos associated with the tag
                    NSArray *taggedPhotos = [self.flickrTaggedPhotos valueForKey:self.tagList[indexPath.row]];
                    [segue.destinationViewController performSelector:@selector(setFlickrListPhotos:) withObject:taggedPhotos];
                    
                    // Set the title to the tag being shown
                    [segue.destinationViewController setTitle:[self getCellTitleForRow:indexPath.row]];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSString *) getCellTitleForRow:(NSUInteger)row
{
    // For the selected row, get the title string
    return self.tagList[row];
}

- (NSString *) getCellSubTitleForRow:(NSUInteger)row
{
    // For the selected row, get the subtitle string
    NSArray *taggedPhotos = [self.flickrTaggedPhotos valueForKey:self.tagList[row]];

    return [NSString stringWithFormat:@"%d", [taggedPhotos count]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.flickrTaggedPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pull a cell prototype from the pool
    static NSString *cellReuseID = @"FlickrTag";
    
    return [self configureCell:tableView cellReuseIdentifier:cellReuseID cellIndexPath:indexPath];
}

@end
