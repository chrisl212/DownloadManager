//
//  AppDelegate.h
//  Download Manager
//
//  Created by Chris on 3/17/15.
//  Copyright (c) 2015 A and C Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) UIWindow *window;

- (NSNumber *)allFeaturesUnlocked;
- (void)unlockFeatures;
- (void)restorePurchase;

@end
