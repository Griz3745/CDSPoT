//
//  SingletonManagedDocument.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/7/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This class simply gives access to a single instance of the sharedManagedDocument
//  sharedManagedDocument exists in memory, so it it up to the calling routine to create it and open it.
//  I would have liked to perform the creation and open in this class, but I could not
//  find a way to make the completion handler work in a nice way with the calling methods
//

#import "SingletonManagedDocument.h"
#import "SPoT.h"

@interface SingletonManagedDocument()

// Access to the shared managed document
@property (readwrite, strong, nonatomic) UIManagedDocument *sharedManagedDocument;

@end

@implementation SingletonManagedDocument

+ (SingletonManagedDocument *)sharedSingletonManagedDocument
{
    static SingletonManagedDocument *sharedSingletonManagedDocument;
    
    @synchronized (self) {
        if (!sharedSingletonManagedDocument) {
            sharedSingletonManagedDocument = [[SingletonManagedDocument alloc] init];
        }
    }
    
    return  sharedSingletonManagedDocument;
}

// Perform allocation of the UIManagedDocument
- (UIManagedDocument *)sharedManagedDocument
{
    if (!_sharedManagedDocument) {
        // Build the url
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE_NAME];
        _sharedManagedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    return _sharedManagedDocument;
}

@end
