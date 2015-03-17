//
//  ACImageViewer.h
//  ACBrowsers
//
//  Created by Chris on 1/9/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACFilterSelectController.h"
#import "ACAlertView.h"
#import "ACFile.h"

typedef enum {
    ACImageFlipTypeHorizontal,
    ACImageFlipTypeVertical
} ACImageFlipType;

/* The view controller for viewing image files. Will also open any other image files in the same directory and make it possible to scroll through them. */

@interface ACImageViewer : UIViewController <UIScrollViewDelegate, ACAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; //The scroll view where the images will be shown
@property (strong, nonatomic) ACFile *currentFile; //The current image being displayed
@property (strong, nonatomic) NSMutableArray *fileArray; //The array of image files
@property (strong, nonatomic) UIActivity *activity; //Necessary when presented from a UIActivityViewController
@property (getter = isEditing, nonatomic) BOOL editing; //Indicates whether the image is being edited or not
@property (strong, nonatomic) NSString *selectedFilter; //The name of the filter that was selected
@property (strong, nonatomic) UIImage *originalImage; //The original, unedited image

- (id)initWithFile:(ACFile *)file;
- (void)dismissImageViewer;

@end

/* This is necessary to prevent the screen from auto rotating (currently only portrait is supported */
@interface ACImageNavigationController : UINavigationController

@end