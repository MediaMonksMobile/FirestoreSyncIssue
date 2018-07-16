//
// Firestore Sync Issue Example App.
// Copyright (C) 2018 MediaMonks B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExampleView : UIView

@property (nonatomic, readonly) UILabel *topCookieLabel;
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UIButton *addCookiesButton;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

- (id)init NS_DESIGNATED_INITIALIZER;

- (id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (id)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end
