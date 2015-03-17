//
//  ACSong.h
//  ACBrowsers
//
//  Created by Chris on 1/9/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ACFile.h"

/* Similar to ACFile's purpose, but for a song instead. Instrumental in the audio player's function. (All properties here outside of file are only available if they are provided by the sound file.) */

@interface ACSong : NSObject

@property (strong, nonatomic) NSString *songTitle; //The title of the song
@property (strong, nonatomic) NSString *songArtist; //The artist of the song
@property (strong, nonatomic) NSString *albumName; //The name of the album that the song is on
@property (strong, nonatomic) MPMediaItemArtwork *albumArtwork; //The artwork of the album
@property (strong, nonatomic) UIImage *albumImage; //albumArtwork's UIImage representation
@property (strong, nonatomic) ACFile *file; //The file the song is in

- (id)initWithFile:(ACFile *)file;
+ (id)songWithFile:(ACFile *)file;

@end
