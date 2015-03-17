//
//  ACPropertyViewController.h
//  ACBrowsers
//
//  Created by Chris on 1/9/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACFile.h"

/* A view controller for viewing basic properties of a file and renaming them. Rename the files by tapping on the name of the file, which is a text field and can be edited. */

@interface ACPropertyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView; //Table view where the properties will be shown
@property (weak, nonatomic) IBOutlet UIImageView *iconView; //Image view where the icon for the file will be shown
@property (weak, nonatomic) IBOutlet UITextField *nameField; //Where the name is shown. Can be edited to rename file
@property (strong, nonatomic) ACFile *file; //File to show the properties of
@property (strong, nonatomic) UIActivity *activity; //Necessary when presented from a UIActivityViewController
@property (strong, nonatomic) NSString *selectedText; //Necessary for copying the text of a table view cell

- (id)initWithFile:(ACFile *)file;
- (void)dismiss;
- (IBAction)dismissKeyboard:(id)sender;

@end
