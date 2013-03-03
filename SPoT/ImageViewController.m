//
//  ImageViewController.m
//  MyShutterbug
//
//  Created by Michael Grysikiewicz on 2/23/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//
//  This code implements, in the UI, the display of a photo image
//
//  This is code was developed in Lecture 9, Winter 2013

#import "ImageViewController.h"
#import "FlickrCache.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // handle to manage the scrollView
@property (strong, nonatomic) UIImageView *imageView; // handle to manage the imageView

// Assignment IV, Requirement 6 says to turn off auto zooming if the user performs a zoom(pinch)
@property (nonatomic, getter = allowAutoZoom) BOOL autoZoom; // borrowed 'autoZoom' from Joan-Carlos

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation ImageViewController

// This is the Model for this MVC, can be set externally
- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    
    // We have a new image to display
    [self resetImage];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        // Don't know the image size at this point, set later
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    
    return _imageView;
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    
    // Override the setTitle method so that IF this TVC has a
    // titleBarButtonItem, then it's title will be set as well
    self.titleBarButtonItem.title = title;
}
- (void)viewDidLayoutSubviews // from AutoLayout
{
    [super viewDidLayoutSubviews];
    
    if ((self.allowAutoZoom) && (self.imageView.image)) { // image could be null because of threading
            // Set the full screen zoom for the image view within the scroll view
            [self.scrollView zoomToRect:[self setFullScreenImageZoom] animated:NO];
    }
}

- (void)resetToolBarBackButton:(UIBarButtonItem *)splitViewBarButtonItem
{
    UIToolbar *toolBar = self.toolBar;
    NSMutableArray *toolBarItems = [toolBar.items mutableCopy];
    
    // Remove existing back button
    if (self.splitViewBarButtonItem) {
        [toolBarItems removeObject:self.splitViewBarButtonItem];
    }
    
    // Put the bar button on the left of the toolbar
    if (splitViewBarButtonItem) {
        [toolBarItems insertObject:splitViewBarButtonItem atIndex:0];
    }
    
    // Add the update toolBarItems bar to the toolbar
    toolBar.items = toolBarItems;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    [self resetToolBarBackButton:splitViewBarButtonItem];
    
    // Keep this at the end because of the code that removes the old button
    _splitViewBarButtonItem =  splitViewBarButtonItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the image view to the scroll view
    [self.scrollView addSubview:self.imageView];
    
    // Initialize zoom limits
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    
    // For the zooming protocol, all methods are optional,
    // but still have to do it so that it knows which view to zoom
    self.scrollView.delegate = self;
    
    self.titleBarButtonItem.title = self.title;
    
    // Have to reset the tool bar back button, because
    // outlets weren't set when the setter was called from
    // prepare for segue
    [self resetToolBarBackButton:self.splitViewBarButtonItem];
    
    [self resetImage];
}

#pragma mark - Class specific methods

// Build a CGRect used to display as much of the image as possible, without any bordering white space
- (CGRect)setFullScreenImageZoom
{
    // Frankly, I struggled with the code in this method. It works and I understand it when
    // I think about it for a while, but it is not easily intuitive for me

    // Understanding how the aspect ratio of the scrollView relates to the aspect ratio of the
    // imageView determines if the image will take up the full width or the full height of the scrollView
    CGFloat imageAspectRatio = self.imageView.image.size.width / self.imageView.image.size.height;
    CGFloat scrollViewAspectRatio = self.scrollView.bounds.size.width / self.scrollView.bounds.size.height;
    
    CGFloat smallerRectWidth, smallerRectHeight;
    
    // If the image is narrower than the scrollView, keep the image width
    if (imageAspectRatio < scrollViewAspectRatio) {
        
        // Use the image width and calculate the height
        smallerRectWidth = self.imageView.image.size.width;
        smallerRectHeight = (self.imageView.image.size.width *
                             self.scrollView.bounds.size.height) /
                             self.scrollView.bounds.size.width;
    }
    else  { // The scrollView is narrower than the image, keep the image height
        
        // Use the image height and calculate the width
        smallerRectHeight = self.imageView.image.size.height;
        smallerRectWidth = (self.imageView.image.size.height *
                            self.scrollView.bounds.size.width) /
                            self.scrollView.bounds.size.height;
    }
    
    // Create a CGRect which corresponds to the portion of the image view that fills the scroll view
    CGRect smallerRect = CGRectMake(0, 0, smallerRectWidth, smallerRectHeight);
    
    return smallerRect;
}

// Reset the scrollView and imageView whenever an new image has been set
- (void)resetImage
{     
    // self.scrollView will be nil if the setter for imageURL
    // is called externally, like from prepareForSegue, but
    // when this method(resetImage) is called from viewDidLoad
    // self.scrollView will not be nil
    if ((self.scrollView) &&
        (self.imageURL)) {
        
        // Blank out any previous setting
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        self.autoZoom = YES;
        
        // Start the activity indicatior signaling an image load
        [self.activitySpinner startAnimating];

        // Fetch the photo from Flickr
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr photo downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            // Save the self.imageURL for later verification
            NSURL *savedImageURL = self.imageURL;

            // Get the image from the Cache Directory of the App OR from Flickr
            NSData *imageData = [FlickrCache flickrImageFromPhoto:self.imageURL];
            
            // Set the photo in the UI
            dispatch_async(dispatch_get_main_queue(), ^{
                // Verify that the user has not already selected a new URL
                if (![savedImageURL isEqual:self.imageURL]) {
                    // It never gets here on the iPhone because it always instantiates a new
                    // controller, it doesn't get here for the iPad either
                    // because it is using a 'Replace Segue' which also
                    // instantiates a new controller
                    // If I were reusing the view controller, like I did
                    // in the Summer '12 class, it could get here
                    NSLog(@"Mismatched URL, discarding old one");
                } else {
                    // Convert the NSData into a UIImage
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    
                    if (image) {
                        // Very important to reset the zoom scale BEFORE resetting the contentSize
                        self.scrollView.zoomScale = 1.0;
                        
                        // Tells scrollView how big an area to scroll over
                        self.scrollView.contentSize = image.size;
                        
                        // Set the image in the imageView
                        self.imageView.image = image;
                        
                        // Must reset the frame of the imageView explicitly, set to "natural size"
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        
                        // Set the zoom scale when the image is first loaded
                        [self.scrollView zoomToRect:[self setFullScreenImageZoom] animated:NO];
                    }
                }
                
                // Remove the activity indicatior once the image is loaded
                [self.activitySpinner stopAnimating];
            });
        });
    }
}

#pragma mark - methods for <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // Specifies which view, within the scrollView, will be zoomed by the scrollView
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{ // Found this method from looking at Joan-Carlos' code
    
    // Disable autoZoom after the user performs a zoom (by pinching)
    self.autoZoom = NO;
}

@end
