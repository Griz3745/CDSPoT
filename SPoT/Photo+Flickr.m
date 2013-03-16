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

// Create a database entry for the given photo in the give context using the given format
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
    if (!matches || ([matches count] > 1)) { // More than 1 is an error
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
        photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.thumbnailImage = nil;
        photo.lastAccessTime = nil;
        photo.section = [[photo.title substringToIndex:1] capitalizedString];
        photo.isUserDeleted = @(NO);

        // Get the tags from the photo
        NSString *photoTagString = [[photoDictionary valueForKey:FLICKR_TAGS] description];
        NSArray *photoDictionaryTagStrings = [photoTagString componentsSeparatedByString:@" "];

        // Add the non-excluded tags to the NSSet of database tags for this photo
        NSMutableSet *tagEntitiesForPhoto = [[NSMutableSet alloc] init];
        
        for (NSString *tag in photoDictionaryTagStrings) { // Iterate across the array of tag strings
            if (![[Photo excludedTags] containsObject:tag]) { // Make sure the tag is not in the excluded list
                Tag *dbTag = [Tag tagWithString:tag inManagedObjectContex:context]; // Factory method to create a Tag
                if (dbTag) {
                    [tagEntitiesForPhoto addObject:dbTag]; // Add the returned Tag to the MutableSet
                    
                    // Now adding this photo to this tag, so increment the undeletedPhotoCount
                    // Need to keep this count so that tags with no more photos wont be fetched
                    dbTag.undeletedPhotoCount = @([dbTag.undeletedPhotoCount integerValue] + 1);
                } else {
/* ----> */                    NSLog(@"Error in dbTag Creation");
                }
            }
        }
        
        // Add the relationship
        photo.tags = tagEntitiesForPhoto; // Add the MutableSet to the Photo Entity
        
    } else { // It's in the database
        photo = [matches lastObject];
    }
    
    return photo;
}

// These tags were specifically excluded in Assignment IV, Requirement 3
+ (NSArray *)excludedTags
{
    return @[@"cs193pspot", @"portrait", @"landscape"];
}

@end
