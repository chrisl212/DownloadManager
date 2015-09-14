//
//  ACTextField.m
//  Download Manager
//
//  Created by Christopher Loonam on 9/2/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACTextField.h"

#define DURATION 0.1

@implementation ACTextField
{
    UIColor *originalBackgroundColor;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.isFirstResponder)
        return;
    [UIView animateWithDuration:DURATION animations:^{
        originalBackgroundColor = self.backgroundColor;
        self.backgroundColor = self.textFieldTintColor;
    }];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [UIView animateWithDuration:DURATION animations:^{
        self.backgroundColor = originalBackgroundColor;
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:DURATION animations:^{
        self.backgroundColor = originalBackgroundColor;
    }];
}

@end
