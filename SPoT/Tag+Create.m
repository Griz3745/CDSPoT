//
//  Tag+Create.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/9/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "Tag+Create.h"
#import "SPoT.h"

@implementation Tag (Create)

// Create a database entry for the given tagString in the given context
+ (Tag *)tagWithString:(NSString *)tagString
 inManagedObjectContex:(NSManagedObjectContext *)context
{
    Tag *tag = nil;

    if (tagString.length) {
        // Make the tagstring capitalized for aesthetics
        tagString = [tagString capitalizedString];
        
        // Build a query to see if the tag is in the database
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tagString"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"tagString = %@", tagString];
        
        // Execute the query
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        // Evaluate the query
        if (!matches || ([matches count] > 1)) {
            // Handle error
            NSLog(@"Error fetching tag from database");
            
        } else if (![matches count]) { // It's not in the database, so add it
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            tag.tagString = tagString;
            tag.firstItem = ([tagString isEqual:[ALL_TAG capitalizedString]]) ? @(YES) : @(NO);
            
        } else { // Return the tag that is in the database
            tag = [matches lastObject];
        }
    }
    
    return tag;
}

@end
