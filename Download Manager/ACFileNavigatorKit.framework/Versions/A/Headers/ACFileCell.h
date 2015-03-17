//
//  ACFileCell.h
//  ACFileNavigator
//
//  Created by Chris on 7/18/13.
//  Copyright (c) 2013 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileName; //Displays the name of the file (last part of file path)
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel; //Displays the file's size string (eg. 3.12 MB)
@property (weak, nonatomic) IBOutlet UILabel *dateLabel; //Displays the file's creation data (eg. 12/4/13)
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView; //Displays the icon representing the file

@end
