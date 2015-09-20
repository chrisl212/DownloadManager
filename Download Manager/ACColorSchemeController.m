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
    self.redSlider.minimumTrackTintColor = [UIColor redColor];
    self.greenSlider.minimumTrackTintColor = [UIColor greenColor];
    self.blueSlider.minimumTrackTintColor = [UIColor blueColor];

    UIColor *color1 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color1"]];
    self.color1View.backgroundColor = color1;
    
    UIColor *color2 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color2"]];
    self.color2View.backgroundColor = color2;
    
    UIColor *color3 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color3"]];
    self.color3View.backgroundColor = color3;

    UIColor *color4 = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Color4"]];
    self.color4View.backgroundColor = color4;
    
    self.color1View.layer.borderColor = [UIColor blackColor].CGColor;
    self.color1View.layer.borderWidth = 1.0;
    
    self.color2View.layer.borderColor = [UIColor blackColor].CGColor;
    self.color2View.layer.borderWidth = 1.0;
    
    self.color3View.layer.borderColor = [UIColor blackColor].CGColor;
    self.color3View.layer.borderWidth = 1.0;
    
    self.color4View.layer.borderColor = [UIColor blackColor].CGColor;
    self.color4View.layer.borderWidth = 1.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setColorForKey:(NSString *)key usingView:(UIView *)view
{
    UIColor *color = [view backgroundColor];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:key];
}

- (void)save:(id)sender
{
    [self setColorForKey:@"Color1" usingView:self.color1View];
    [self setColorForKey:@"Color2" usingView:self.color2View];
    [self setColorForKey:@"Color3" usingView:self.color3View];
    [self setColorForKey:@"Color4" usingView:self.color4View];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appearance" object:nil];
}

- (void)adjustColor:(id)sender
{
    self.selectedView.backgroundColor = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:1.0];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    
    self.selectedView.layer.borderColor = [UIColor blackColor].CGColor;
    self.selectedView = [self.view hitTest:[touch locationInView:self.view] withEvent:nil];
    self.selectedView.layer.borderColor = [UIColor greenColor].CGColor;

    [self.selectedView.backgroundColor getRed:&red green:&green blue:&blue alpha:nil];
    if ([self.selectedView isEqual:self.view])
        self.selectedView = nil;
        
    self.redSlider.value = red;
    self.greenSlider.value = green;
    self.blueSlider.value = blue;
}

- (void)reset:(id)sender
{
    double red1 = 170.0;
    double green1 = 57.0;
    double blue1 = 57.0;
    
    double red2 = 102.0;
    double green2 = 102.0;
    double blue2 = 102.0;
    
    double red3 = 255.0;
    double green3 = 255.0;
    double blue3 = 255.0;
    
    double red4 = 210.0;
    double green4 = 210.0;
    double blue4 = 210.0;
    
    UIColor *color = [UIColor colorWithRed:RGB(red1) green:RGB(green1) blue:RGB(blue1) alpha:1.0];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"Color1"];
    self.color1View.backgroundColor = color;
    
    color = [UIColor colorWithRed:RGB(red2) green:RGB(green2) blue:RGB(blue2) alpha:1.0];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"Color2"];
    self.color2View.backgroundColor = color;

    color = [UIColor colorWithRed:RGB(red3) green:RGB(green3) blue:RGB(blue3) alpha:1.0];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"Color3"];
    self.color3View.backgroundColor = color;

    color = [UIColor colorWithRed:RGB(red4) green:RGB(green4) blue:RGB(blue4) alpha:1.0];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"Color4"];
    self.color4View.backgroundColor = color;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"appearance" object:nil];
}

@end
