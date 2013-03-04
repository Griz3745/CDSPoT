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

@interface ImageViewController : UIViewController

// This is the Model for this MVC, can be set externally
@property (nonatomic, strong) NSURL *imageURL;

// Allow the masterViewController to manage this button
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;

@end
