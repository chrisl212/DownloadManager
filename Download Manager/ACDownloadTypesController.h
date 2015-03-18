//
//  ACDownloadTypesController.h
//  ACDownloadManager
//
//  Created by Chris on 1/26/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ACFileNavigatorKit/ACAlertView.h>
#import <ACFileNavigatorKit/ACFile.h>

@interface ACDownloadTypesController : UITableViewController <ACAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *typesArray;
@property (strong, nonatomic) NSMutableArray *mimeTypesArray;

@end
