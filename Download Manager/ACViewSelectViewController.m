//
//  ACViewSelectViewController.m
//  Download Manager
//
//  Created by Christopher Loonam on 9/19/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import "ACViewSelectViewController.h"

@implementation ACViewSelectViewController

- (id)initWithViews:(NSArray *)views delegate:(id<ACViewSelectViewControllerDelegate>)delegate
{
    if (self = [super init])
    {
        _views = views;
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.scrollView.delegate = self;

        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
        self.pageControl.numberOfPages = self.views.count;
        self.pageControl.currentPage = 0;
        
        self.delegate = delegate;
    }
    return self;
}

- (void)createView
{
    if ([self.delegate respondsToSelector:@selector(viewSelectControllerShouldCreateNewView:)])
        [self.delegate viewSelectControllerShouldCreateNewView:self];
}

- (void)deleteView
{
    NSInteger currentPage = self.pageControl.currentPage;
    if ([self.delegate respondsToSelector:@selector(viewSelectController:didDeleteView:)])
        [self.delegate viewSelectController:self didDeleteView:self.views[currentPage]];
    if ([self.delegate respondsToSelector:@selector(viewSelectController:didDeleteViewAtIndex:)])
        [self.delegate viewSelectController:self didDeleteViewAtIndex:currentPage];
}

- (void)setUpScrollView
{
    self.scrollView.contentSize = CGSizeMake((self.scrollView.frame.size.width * self.views.count), self.scrollView.frame.size.height);
    NSInteger counter = 1;
    for (UIView *view in self.views)
    {
        view.userInteractionEnabled = NO;
        view.frame = CGRectMake(0, 0, self.scrollView.frame.size.width/2.0, self.scrollView.frame.size.height/2.0);
        view.center = CGPointMake((self.scrollView.frame.size.width * counter) - (self.scrollView.frame.size.width)/2.0, CGRectGetMidY(self.scrollView.frame));
        
        [self.scrollView addSubview:view];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [deleteButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        deleteButton.frame = CGRectMake(0, 0, 30, 30);
        deleteButton.center = view.frame.origin;
        [deleteButton addTarget:self action:@selector(deleteView) forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setTintColor:[UIColor blackColor]];
        [self.scrollView addSubview:deleteButton];
        
        UIButton *createButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [createButton setTitle:@"+" forState:UIControlStateNormal];
        createButton.titleLabel.font = [UIFont systemFontOfSize:28.0];
        createButton.frame = CGRectMake(0, 0, (self.scrollView.frame.size.width/4.0), 100.0);
        createButton.center = CGPointMake(view.center.x + (view.frame.size.width/2.0) + (createButton.frame.size.width/2.0), CGRectGetMidY(self.scrollView.frame));
        [createButton addTarget:self action:@selector(createView) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:createButton];
        counter++;
    }
    [self.view addSubview:self.scrollView];
    self.pageControl.numberOfPages = self.views.count;
    self.pageControl.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 10.0);
    self.pageControl.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.scrollView.frame) + (self.scrollView.frame.size.height/4.0) + 10.0);
    [self.view addSubview:self.pageControl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewSelected)];
    [self.scrollView addGestureRecognizer:tapGesture];

    self.scrollView.backgroundColor = [UIColor grayColor];
    
    self.scrollView.frame = self.view.bounds;
    self.scrollView.pagingEnabled = YES;
    [self setUpScrollView];
    
    self.pageControl.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 10.0);
    self.pageControl.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.scrollView.frame) + (self.scrollView.frame.size.height/4.0) + 10.0);
    [self.view addSubview:self.pageControl];
}

- (void)setViews:(NSArray *)views
{
    _views = views;
    for (UIView *subview in self.scrollView.subviews)
    {
        [subview removeFromSuperview];
    }
    [self setUpScrollView];
    [self setSelectedIndex:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewSelected
{
    if ([self.delegate respondsToSelector:@selector(viewSelectController:didSelectView:)])
        [self.delegate viewSelectController:self didSelectView:self.views[self.pageControl.currentPage]];
    if ([self.delegate respondsToSelector:@selector(viewSelectController:didSelectViewAtIndex:)])
        [self.delegate viewSelectController:self didSelectViewAtIndex:self.pageControl.currentPage];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    NSInteger currentPage = (offset.x*self.views.count)/scrollView.contentSize.width;
    self.pageControl.currentPage = currentPage;
}

- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated
{
    self.pageControl.currentPage = index;
    [self.scrollView setContentOffset:CGPointMake((self.scrollView.contentSize.width*index)/self.views.count, 0) animated:animated];
}

@end
