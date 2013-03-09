//
//  Tag+Create.h
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/9/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithString:(NSString *)tagString
 inManagedObjectContex:(NSManagedObjectContext *)context;

@end
