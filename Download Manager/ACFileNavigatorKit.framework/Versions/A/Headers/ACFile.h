//
//  ACFile.h
//  testIDE
//
//  Created by Chris on 7/9/13.
//  Copyright (c) 2013 A and C Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ACFileSize)
{
    /* For use in determining file size */
    ACFileSizeBytes,
    ACFileSizeKB,
    ACFileSizeMB,
    ACFileSizeGB
};

/* Probably the most important class in this file browser, contains all the information for items whether they be a file or directory */
@interface ACFile : NSObject <NSCopying>

@property (strong, nonatomic) NSString *filePath; //The path to the file being represented
@property (strong, nonatomic) NSString *fileName; //The name of the file
@property (strong, nonatomic) NSString *mimeType;
@property (strong, nonatomic) NSString *dateString; //The creation date of the file
@property (strong, nonatomic) NSString *sizeString; //A string containing the size (eg. 3.12 MB)
@property (strong, nonatomic) NSString *iconPath; //The path to the proper icon for the file type (eg. txt.ico)
@property (strong, nonatomic) NSString *fileDescription; //A string describing the file (eg. Text File)
@property (strong, nonatomic) NSURL *fileURL; //The URL to the file
@property (strong, nonatomic) NSString *parentDirectory; //The parent directory of the file
@property (nonatomic) long double fileSize; //The size of the file in bytes
@property (nonatomic, getter = isDirectory) BOOL directory; //A BOOL indicating of the item is a file or directory
@property (strong, nonatomic) id contents; //The data representing the contents of the file
@property (strong, nonatomic) id modifiedContents; //Needed for the text editor
@property (nonatomic) ACFileSize sizeType; //What would be the best way to represent the size (KB, MB, GB)
@property (nonatomic, getter = shouldUseHighlighting) BOOL syntaxHighlighting; //Also for the text editor. Limited syntax highlighting is available in files that have extensions such as .c, .cpp, .m. Only highlights C keywords.

+ (id)fileWithPath:(NSString *)path recursive:(BOOL)recursive;
- (id)initWithFilePath:(NSString *)path recursive:(BOOL)recursive; //Makes an ACFile from the file at that path. recursive is a bool indicating whether or not the contents of every directory in the current directory should be added to an ACFile. Setting it to YES does this, but can have speed and memory issues if there are many directories in one folder.
- (void)updateFileContents;

@end
