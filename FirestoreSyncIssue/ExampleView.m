//
// Firestore Sync Issue Example App.
// Copyright (C) 2018 MediaMonks B.V. All rights reserved.
//

#import "ExampleView.h"

//
//
//
@implementation ExampleView

- (id)init {

	if (self = [super initWithFrame:CGRectZero]) {

		self.translatesAutoresizingMaskIntoConstraints = NO;
		self.backgroundColor = [UIColor whiteColor];

		_topCookieLabel = [[UILabel alloc] init];
		_topCookieLabel.translatesAutoresizingMaskIntoConstraints = NO;
		_topCookieLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
		_topCookieLabel.textColor = [UIColor blackColor];
		_topCookieLabel.textAlignment = NSTextAlignmentCenter;
		_topCookieLabel.numberOfLines = 0;
		[self addSubview:_topCookieLabel];

		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, M_E, M_PI) style:UITableViewStylePlain];
		_tableView.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_tableView];

		_addCookiesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		_addCookiesButton.translatesAutoresizingMaskIntoConstraints = NO;
		[_addCookiesButton setTitle:@"Get More Cookies" forState:UIControlStateNormal];
		[_addCookiesButton setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
		[_addCookiesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_addCookiesButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
		[self addSubview:_addCookiesButton];

		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:_activityIndicator];

		//
		//
		//
		NSDictionary *views = NSDictionaryOfVariableBindings(
			_topCookieLabel,
			_tableView,
			_addCookiesButton,
			_activityIndicator
		);
		NSDictionary *metrics = @{
			@"paddingTop" : @50,
			@"paddingLeft" : @20,
			@"paddingRight" : @20,
			@"paddingBottom" : @20,
			@"spacing" : @10
		};

		[NSLayoutConstraint activateConstraints:[NSLayoutConstraint
			constraintsWithVisualFormat:@"H:|-paddingLeft-[_topCookieLabel]-paddingRight-|"
			options:0 metrics:metrics views:views
		]];

		[NSLayoutConstraint activateConstraints:[NSLayoutConstraint
			constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
			options:0 metrics:metrics views:views
		]];

		[NSLayoutConstraint activateConstraints:[NSLayoutConstraint
			constraintsWithVisualFormat:@"H:|-(>=paddingLeft)-[_activityIndicator]-spacing-[_addCookiesButton]-(>=paddingRight)-|"
			options:0 metrics:metrics views:views
		]];
		[NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint
			constraintWithItem:_addCookiesButton attribute:NSLayoutAttributeCenterX
			relatedBy:NSLayoutRelationEqual
			toItem:_addCookiesButton.superview attribute:NSLayoutAttributeCenterX
			multiplier:1 constant:0
		]]];

		[NSLayoutConstraint activateConstraints:@[[NSLayoutConstraint
			constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterY
			relatedBy:NSLayoutRelationEqual
			toItem:_addCookiesButton attribute:NSLayoutAttributeCenterY
			multiplier:1 constant:0
		]]];

		[NSLayoutConstraint activateConstraints:[NSLayoutConstraint
			constraintsWithVisualFormat:@"V:|-paddingTop-[_topCookieLabel]-spacing-[_tableView]-spacing-[_addCookiesButton]-paddingBottom-|"
			options:0 metrics:metrics views:views
		]];
	}

	return self;
}

@end
