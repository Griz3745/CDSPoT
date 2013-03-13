//
//  ImageViewController.h
//  MyShutterbug
//
//  Created by Michael Grysikiewicz on 2/23/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This code implements, in the UI, the display of a photo image
//
//  This is code was developed in Lecture 9, Winter 2013
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface ImageViewController : UIViewController

// This is the Model for this MVC, can be set externally
@property (strong, nonatomic) Photo *photo;

// Allow the masterViewController to manage this button
@property (strong, nonatomic) UIBarButtonItem *splitViewBarButtonItem;

@end
