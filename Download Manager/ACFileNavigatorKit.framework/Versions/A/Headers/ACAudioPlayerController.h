//
//  ACAudioPlayerController.h
//  ACBrowsers
//
//  Created by Chris on 1/7/14.
//  Copyright (c) 2014 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACSong.h"

/** The view controller class for playing an audio file and all other audio files in the same folder. */

@interface ACAudioPlayerController : UIViewController <AVAudioPlayerDelegate, UIGestureRecognizerDelegate>
{
    BOOL isFastForwarding; //Needed for fast forwarding to work
    BOOL isRewinding; //Needed for rewinding to work
    NSTimer *updateTimer; //Updates elapsed time on the progress bar
    NSTimer *incrementTimer; //Adds to clock or subtracts (fast forward/rewind)
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButton; //The middle button of the toolbar ONLY when it is play (changes to a different one when pause - see playPause: function)
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fastForwardBarButton; //Clicked once to begin fast forwarding, once again to stop
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rewindBarButton; //Same as above but for rewinding
@property (weak, nonatomic) IBOutlet UIButton *rewindButton;
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButton;
@property (weak, nonatomic) IBOutlet MPVolumeView *volumeSlider; //Changes system volume
@property (weak, nonatomic) IBOutlet UIProgressView *progressView; //Shows elapsed time on a progress bar
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView; //Shows album art, noart.png if none can be found
@property (weak, nonatomic) UIActivity *activity; //Necessary when presented from UIActivityViewController
@property (strong, nonatomic) AVAudioPlayer *audioPlayer; //What plays the music
@property (strong, nonatomic) ACSong *currentSong; //Song that is currently being played
@property (strong, nonatomic) NSMutableArray *songArray; //Array of songs to be played
@property (weak, nonatomic) IBOutlet UIToolbar *controlBar; //Toolbar with play, pause, fast-forward, rewind
@property (weak, nonatomic) IBOutlet UILabel *currentTime; //Label with elapsed time
@property (weak, nonatomic) IBOutlet UILabel *totalTime; //Label with total duration
@property (nonatomic) NSInteger currentSongNumber; // The number of the current song in the song array

- (id)initWithSong:(ACSong *)song; //Creates a new view controller loaded from ACAudioPlayerController.xib with the provided audio file
- (void)dismissAudioController; //Dismisses view controller and stops music
- (IBAction)playPause:(id)sender; //Pauses if the song is playing, plays if it is paused
- (IBAction)fastForward:(id)sender; //See fastForwardButton
- (IBAction)rewind:(id)sender; //See rewindButton
- (IBAction)changeSong:(id)sender;

@end
