//
//  ACColorSchemeController.h
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACColorSchemeController : UIViewController
{
    CGFloat red, green, blue;
}

@property (weak, nonatomic) UIView *selectedView;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;

@property (weak, nonatomic) IBOutlet UIView *color1View;
@property (weak, nonatomic) IBOutlet UIView *color2View;
@property (weak, nonatomic) IBOutlet UIView *color3View;
@property (weak, nonatomic) IBOutlet UIView *color4View;

- (IBAction)adjustColor:(id)sender;

@end
