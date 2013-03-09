//
//  Photo+Flickr.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/9/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

// Create a database entry for the given photo in the give context
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
                   usingFormat:(FlickrPhotoFormat)flickrFormat
{
    Photo *photo = nil;

    // Build a query to see if the photo is in the database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@",
                         [photoDictionary[FLICKR_PHOTO_ID] description]];
    
    // Execute the query
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Evaluate the query
    if (!matches || ([ matches count] > 1)) { // More than 1 is an error
        // Handle error
        NSLog(@"Error fetching photo from database");
        
    } else if (![matches count]) { // It's not in the database
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];

        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description]; // using description ensures that a
                                                                         // reasonable string will be returned
                                                                         // if the title is nil
        photo.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary format:flickrFormat] absoluteString];
        photo.uniqueID = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.thumbnailImage = nil;
        photo.lastAccessTime = [NSDate date];

        // Get the tags from the photo
        NSString *photoTags = [photoDictionary valueForKey:FLICKR_TAGS];
#warning - combine with the line above
        photoTags = [photoTags capitalizedString];
        NSArray *tagStrings = [photoTags componentsSeparatedByString:@" "];

        // Get the non-excluded tags
        NSMutableArray *tagsToProcess;
        for (NSString *tag in tagStrings) {
            if (![[Photo excludedTags] containsObject:tag]) {
                [tagsToProcess addObject:tag];
            }
        }
                
        // Get the NSSet of database tags for this photo
        NSMutableSet *tagsForPhoto = [[NSMutableSet alloc] init];
        for (NSString *tag in tagsToProcess) {
            [tagsForPhoto addObject:[Tag tagWithString:tag inManagedObjectContex:context]];
        }
        
        // Add the relationship
        photo.tags = tagsForPhoto;
        
    } else { // It's in the database
        photo = [matches lastObject];
    }
    
    return photo;
}

// These tags were specifically excluded in Assignment IV, Requirement 3
+ (NSArray *)excludedTags
{
    return @[@"Cs193pspot", @"Portrait", @"Landscape"];
}

@end
