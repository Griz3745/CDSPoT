//
//  ImageViewController.m
//  MyShutterbug
//
//  Created by Michael Grysikiewicz on 2/23/13.
//  Copyright (c) 2013 Michael Grysikiewicz. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, getter = allowAutoZoom) BOOL autoZoom; // borrowed 'autoZoom' from Joan-Carlos

@end

@implementation ImageViewController

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    
    // We have a new image to display
    [self resetImage];
}

- (CGRect)setInitialImageZoom
{
    // Create a CGRect which corresponds to the portion of the image view that fills the scroll view
    CGFloat imageAspectRatio = self.imageView.image.size.width / self.imageView.image.size.height;
    CGFloat scrollViewAspectRatio = self.scrollView.bounds.size.width / self.scrollView.bounds.size.height;
    
    CGFloat smallerRectWidth, smallerRectHeight;
    
    if (imageAspectRatio < scrollViewAspectRatio)
    {
        // Use the image width and calculate the height
        smallerRectWidth = self.imageView.image.size.width;
        smallerRectHeight = (self.imageView.image.size.width * self.scrollView.bounds.size.height) / self.scrollView.bounds.size.width;
    }
    else
    {
        // Use the image height and calculate the width
        smallerRectHeight = self.imageView.image.size.height;
        smallerRectWidth = (self.imageView.image.size.height * self.scrollView.bounds.size.width) / self.scrollView.bounds.size.height;
    }
    
    CGRect smallerRect = CGRectMake(0, 0, smallerRectWidth, smallerRectHeight);
    
    return smallerRect;
}

- (void)resetImage
{     
    // self.scrollView will be nil if the setter for imageURL
    // is called externally, like from prepareForSegue, but
    // when this method(resetImage) is called from viewDidLoad
    // self.scrollView will not be nil
    if (self.scrollView) {
        
        // Blank out any previous setting
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        self.autoZoom = YES;
        
        // Get the 'bag of bits' specified by imageURL
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
        UIImage *image = [[UIImage alloc] initWithData:imageData]; // image for the data
        if (image) {
            // Very important to reset the zoom scale BEFORE resetting the contentSize
            self.scrollView.zoomScale = 1.0;
            self.scrollView.contentSize = image.size;
            self.imageView.image = image;
            // Must reset the frame of the imageView explicitly, set to "natural size"
            self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        }
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        // Don't know the image size at this point
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    
    return _imageView;
}

// Optional delegate method for <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.allowAutoZoom) {
        // Set the initial zoom for the image view within the scroll view
        [self.scrollView zoomToRect:[self setInitialImageZoom] animated:NO];
    }
}

- (void)viewDidLoad
{
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    // For the zooming protocol, all optional, but still have to do it so that it knows which view to zoom
    self.scrollView.delegate = self;
    [self resetImage];
}

// Disable autoZoom after the user performs a zoom (by pinching)
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{ // Found this method from looking at Joan-Carlos' code
    self.autoZoom = NO;
}

@end
