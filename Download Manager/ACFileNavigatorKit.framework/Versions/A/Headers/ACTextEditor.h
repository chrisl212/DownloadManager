//
//  ACTextEditor.h
//  ACFileNavigator
//
//  Created by Chris on 7/19/13.
//  Copyright (c) 2013 A and C Studios. All rights reserved.
//

#import "ACIDETextView.h"
#import "ACFile.h"

@interface ACTextEditor : UIViewController /* The editor used when editing text files */

@property (weak, nonatomic) IBOutlet ACIDETextView *textView; // The text view that can be edited
@property (weak, nonatomic) UIActivity *activity;

- (IBAction)cancel:(id)sender; //Closes the view controller without doing anything
- (IBAction)done:(id)sender; //Closes the view controller and saves the text in the text view to the file that was opened
- (id)initWithFile:(ACFile *)file;

@end
