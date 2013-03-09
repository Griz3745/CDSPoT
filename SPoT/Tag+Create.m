//
//  Tag+Create.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/9/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

// Create a database entry for the given tagString in the given context
+ (Tag *)tagWithString:(NSString *)tagString
 inManagedObjectContex:(NSManagedObjectContext *)context
{
    Tag *tag = nil;
    
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
    if (!matches || (![matches count] > 1)) {
        // Handle error
        NSLog(@"Error fetching tag from database");
    } else if (![matches count]) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.tagString = tagString;
        
    } else {
        tag = [matches lastObject];
    }
    
    return tag;
}

@end
