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

@end

@implementation ImageViewController

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    
    // We have a new image to display
    [self resetImage];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    // For the zooming protocol, all optional, but still have to do it so that it knows which view to zoom
    self.scrollView.delegate = self;
    [self resetImage];
}

@end
