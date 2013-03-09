//
//  SingletonManagedDocument.h
//  SPoT
//
//  Created by Michael Grysikiewicz on 3/7/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This class simply gives access to a single instance of the sharedManagedDocument
//  sharedManagedDocumentexists in memory, so it it up to the calling routine to create it and open it.
//  I would have liked to perform the creation and open in this class, but I could not
//  find a way to make the completion handler work in a nice way with the calling methods
//

#import <Foundation/Foundation.h>


@interface SingletonManagedDocument : NSObject

// Return the shared, singleton instance of SingletonManagedDocument
+(SingletonManagedDocument *)sharedSingletonManagedDocument;

// Returns an alloc'd, but NOT opened document
- (UIManagedDocument *)managedDocumentForName:(NSString *)documentName;

@end
