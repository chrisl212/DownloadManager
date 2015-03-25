//
//  ACColorSchemeController.h
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACColorSchemeController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *color1Red;
@property (weak, nonatomic) IBOutlet UITextField *color1Green;
@property (weak, nonatomic) IBOutlet UITextField *color1Blue;

@property (weak, nonatomic) IBOutlet UITextField *color2Red;
@property (weak, nonatomic) IBOutlet UITextField *color2Green;
@property (weak, nonatomic) IBOutlet UITextField *color2Blue;

@property (weak, nonatomic) IBOutlet UITextField *color3Red;
@property (weak, nonatomic) IBOutlet UITextField *color3Green;
@property (weak, nonatomic) IBOutlet UITextField *color3Blue;

@property (weak, nonatomic) IBOutlet UITextField *color4Red;
@property (weak, nonatomic) IBOutlet UITextField *color4Green;
@property (weak, nonatomic) IBOutlet UITextField *color4Blue;

- (IBAction)save:(id)sender;

@end
