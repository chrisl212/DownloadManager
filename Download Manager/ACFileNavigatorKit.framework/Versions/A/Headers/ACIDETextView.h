//
//  ACIDETextView.h
//  testIDE
//
//  Created by Chris on 7/9/13.
//  Copyright (c) 2013 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+ACAdditions.h"

@interface ACIDETextView : UITextView <UITextViewDelegate>

@property (nonatomic, getter = shouldUseSyntaxHighlighting) BOOL syntaxHighlighting;
- (void)updateSyntaxHighlighting;

@end
