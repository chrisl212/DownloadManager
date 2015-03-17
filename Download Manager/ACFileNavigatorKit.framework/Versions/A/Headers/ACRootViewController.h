//
//  ACRootViewController.h
//  ACFileNavigator
//
//  Created by Chris on 7/18/13.
//  Copyright (c) 2013 A and C Studios. All rights reserved.
//

#import "ACDirectoryViewController.h"

/* !!!For this header's documentation, look at ACDirectoryViewController.h!!! */
/* An ACDirectoryViewController, but usually needs to be the only one that you present since it starts out in the Documents directory */
/* You should really only use this class to set up the view controller in an XIB, otherwise use ACDirectoryViewController since you can change the starting directory */
@interface ACRootViewController : ACDirectoryViewController

@end
