//
//  ACFilterSelectController.h
//  ACBrowsers
//
//  Created by Chris on 1/11/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "ACImageViewer.h"

@class ACFilterSelectController;

@interface ACFilterSelectController : UITableViewController

@property (strong, nonatomic) NSArray *actualFilterNames; //The actual names (eg. CIPhotoEffectNoir)
@property (strong, nonatomic) NSArray *filterNames; //The "pretty" names (eg. Photo Effect Noir)

- (void)dismiss;

@end
