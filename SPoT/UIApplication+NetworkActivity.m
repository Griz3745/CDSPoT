//
//  UIApplication+NetworkActivity.m
//  SPoT
//
//  Created by Michael Grysikiewicz on 2/28/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This Category will keep track of the number of active requests to
//  setNetworkActivityIndicatorVisible, and only turn it off when there
//  are no more outstanding active requests
//
//  From: http://stackoverflow.com/questions/3032192/networkactivityindicatorvisible
//
//  I liked this implementation because a category on UIApplication makes the code reusable

#import "UIApplication+NetworkActivity.h"

static NSInteger activityCount = 0;

@implementation UIApplication (NetworkActivity)

- (void)showNetworkActivityIndicator {
    
    // Don't even try to display it if the Staus Bar is Hidden
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    
    // Synchronize to protect against concurrent access to activityCount
    @synchronized ([UIApplication sharedApplication]) {
        if (activityCount == 0) {
            [self setNetworkActivityIndicatorVisible:YES];
        }
        activityCount++;
    }
}

- (void)hideNetworkActivityIndicator {
    
    // Don't even try to display it if the Staus Bar is Hidden
    if ([[UIApplication sharedApplication] isStatusBarHidden]) return;
    
    // Synchronize to protect against concurrent access to activityCount
    @synchronized ([UIApplication sharedApplication]) {
        activityCount--;
        if (activityCount <= 0) {
            [self setNetworkActivityIndicatorVisible:NO];
            activityCount=0;
        }
    }
}

@end