//
//  ACColorSchemeController.m
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACColorSchemeController.h"

#define RGB(x) x/255.0

@implementation ACColorSchemeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIButton *button in self.view.subviews)
        if ([button isKindOfClass:[UIButton class]])
            button.tintColor = [UIColor blueColor];
    CGFloat red, blue, green;
    UIColor *color1 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"]];
    [color1 getRed:&red green:&green blue:&blue alpha:NULL];
    red *= 255.0, blue *= 255.0, green *= 255.0;
    _color1Red.text = [NSString stringWithFormat:@"%.0f", red];
    _color1Blue.text = [NSString stringWithFormat:@"%.0f", blue];
    _color1Green.text = [NSString stringWithFormat:@"%.0f", green];

    UIColor *color2 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color2"]];
    [color2 getRed:&red green:&green blue:&blue alpha:NULL];
    red *= 255.0, blue *= 255.0, green *= 255.0;
    _color2Red.text = [NSString stringWithFormat:@"%.0f", red];
    _color2Blue.text = [NSString stringWithFormat:@"%.0f", blue];
    _color2Green.text = [NSString stringWithFormat:@"%.0f", green];

    UIColor *color3 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color3"]];
    [color3 getRed:&red green:&green blue:&blue alpha:NULL];
    red *= 255.0, blue *= 255.0, green *= 255.0;
    _color3Red.text = [NSString stringWithFormat:@"%.0f", red];
    _color3Blue.text = [NSString stringWithFormat:@"%.0f", blue];
    _color3Green.text = [NSString stringWithFormat:@"%.0f", green];

    UIColor *color4 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color4"]];
    [color4 getRed:&red green:&green blue:&blue alpha:NULL];
    red *= 255.0, blue *= 255.0, green *= 255.0;
    _color4Red.text = [NSString stringWithFormat:@"%.0f", red];
    _color4Blue.text = [NSString stringWithFormat:@"%.0f", blue];
    _color4Green.text = [NSString stringWithFormat:@"%.0f", green];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save:(id)sender
{
    double red1 = _color1Red.text.doubleValue;
    double green1 = _color1Green.text.doubleValue;
    double blue1 = _color1Blue.text.doubleValue;
    
    double red2 = _color2Red.text.doubleValue;
    double green2 = _color2Green.text.doubleValue;
    double blue2 = _color2Blue.text.doubleValue;
    
    double red3 = _color3Red.text.doubleValue;
    double green3 = _color3Green.text.doubleValue;
    double blue3 = _color3Blue.text.doubleValue;
    
    double red4 = _color4Red.text.doubleValue;
    double green4 = _color4Green.text.doubleValue;
    double blue4 = _color4Blue.text.doubleValue;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red1) green:RGB(green1) blue:RGB(blue1) alpha:1.0]] forKey:@"Color1"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red2) green:RGB(green2) blue:RGB(blue2) alpha:1.0]] forKey:@"Color2"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red3) green:RGB(green3) blue:RGB(blue3) alpha:1.0]] forKey:@"Color3"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red4) green:RGB(green4) blue:RGB(blue4) alpha:1.0]] forKey:@"Color4"];
}

- (void)reset:(id)sender
{
    double red1 = 52.0;
    double green1 = 102.0;
    double blue1 = 153.0;
    
    double red2 = 102.0;
    double green2 = 102.0;
    double blue2 = 102.0;
    
    double red3 = 255.0;
    double green3 = 255.0;
    double blue3 = 255.0;
    
    double red4 = 183.0;
    double green4 = 183.0;
    double blue4 = 183.0;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red1) green:RGB(green1) blue:RGB(blue1) alpha:1.0]] forKey:@"Color1"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red2) green:RGB(green2) blue:RGB(blue2) alpha:1.0]] forKey:@"Color2"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red3) green:RGB(green3) blue:RGB(blue3) alpha:1.0]] forKey:@"Color3"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[UIColor colorWithRed:RGB(red4) green:RGB(green4) blue:RGB(blue4) alpha:1.0]] forKey:@"Color4"];
}

@end
