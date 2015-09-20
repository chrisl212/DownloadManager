//
//  ACViewSelectViewController.h
//  Download Manager
//
//  Created by Christopher Loonam on 9/19/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACViewSelectViewController;

@protocol ACViewSelectViewControllerDelegate <NSObject>

@optional
- (void)viewSelectController:(ACViewSelectViewController *)controller didSelectView:(UIView *)view;
- (void)viewSelectController:(ACViewSelectViewController *)controller didSelectViewAtIndex:(NSInteger)index;
- (void)viewSelectController:(ACViewSelectViewController *)controller didDeleteView:(UIView *)view;
- (void)viewSelectController:(ACViewSelectViewController *)controller didDeleteViewAtIndex:(NSInteger)index;
- (void)viewSelectControllerShouldCreateNewView:(ACViewSelectViewController *)controller;

@end

@interface ACViewSelectViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) id<ACViewSelectViewControllerDelegate> delegate;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *views;

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;
- (id)initWithViews:(NSArray *)views delegate:(id<ACViewSelectViewControllerDelegate>)delegate;

@end
