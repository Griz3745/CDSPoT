//
//  Photo+Flickr.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/9/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "Photo+Flickr.h"
#import "SPoT.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

// Create a database entry for the given photo in the give context using the given format
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
                   usingFormat:(FlickrPhotoFormat)flickrFormat
{
    Photo *photoEntity = nil;

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
        photoEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];

        photoEntity.title = [photoDictionary[FLICKR_PHOTO_TITLE] description]; // using description ensures that a
                                                                               // reasonable string will be returned
                                                                               // if the title is nil
        photoEntity.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photoEntity.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary format:flickrFormat] absoluteString];
        photoEntity.uniqueID = [photoDictionary[FLICKR_PHOTO_ID] description];
        photoEntity.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary
                                                        format:FlickrPhotoFormatSquare] absoluteString];
        photoEntity.thumbnailImage = nil;
        photoEntity.lastAccessTime = nil;
        photoEntity.section = [[photoEntity.title substringToIndex:1] capitalizedString];
        photoEntity.isUserDeleted = @(NO);

        NSMutableSet *tagEntitiesForPhoto = [[NSMutableSet alloc] init];

        // Add the special 'All' tag to the photo, Extra Credit 3
        NSString *photoTagString = ALL_TAG;
        Tag *tagEntity = [Tag tagWithString:photoTagString inManagedObjectContex:context]; // Factory method to create a Tag
        [tagEntitiesForPhoto addObject:tagEntity]; // Add the returned Tag to the MutableSet
        tagEntity.undeletedPhotoCount = @([tagEntity.undeletedPhotoCount integerValue] + 1);

        // Get the other tags from the photo
        photoTagString = [[photoDictionary valueForKey:FLICKR_TAGS] description];
        NSArray *photoDictionaryTagStrings = [photoTagString componentsSeparatedByString:@" "];

        // Add the non-excluded tags to the NSSet of database tags for this photo
        for (NSString *tag in photoDictionaryTagStrings) { // Iterate across the array of tag strings
            if (![[Photo excludedTags] containsObject:tag]) { // Make sure the tag is not in the excluded list
                tagEntity = [Tag tagWithString:tag inManagedObjectContex:context]; // Factory method to create a Tag
                if (tagEntity) {
                    [tagEntitiesForPhoto addObject:tagEntity]; // Add the returned Tag to the MutableSet
                    
                    // Now adding this photo to this tag, so increment the undeletedPhotoCount
                    // Need to keep this count so that tags with no more photos wont be fetched
                    tagEntity.undeletedPhotoCount = @([tagEntity.undeletedPhotoCount integerValue] + 1);
                } else {
/* ----> */                    NSLog(@"Error in dbTag Creation");
                }
            }
        }
        
        // Add the relationship
        photoEntity.tags = tagEntitiesForPhoto; // Add the MutableSet to the Photo Entity
        
    } else { // It's in the database
        photoEntity = [matches lastObject];
    }
    
    return photoEntity;
}

// These tags were specifically excluded in Assignment IV, Requirement 3
+ (NSArray *)excludedTags
{
    return @[@"cs193pspot", @"portrait", @"landscape"];
}

@end
