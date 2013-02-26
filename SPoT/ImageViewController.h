//
//  ImageViewController.h
//  MyShutterbug
//
//  Created by Michael Grysikiewicz on 2/23/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

// This is the Model for this MVC, can be set externally
@property (nonatomic, strong) NSURL *imageURL;

@end
