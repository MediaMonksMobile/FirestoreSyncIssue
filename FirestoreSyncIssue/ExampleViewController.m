//
// Firestore Sync Issue Example App.
// Copyright (C) 2018 MediaMonks B.V. All rights reserved.
//

#import "ExampleViewController.h"

#import "ExampleView.h"

#import <FirebaseFirestore/FirebaseFirestore.h>

//
//
//
@interface ExampleViewController () <
	UITableViewDelegate,
	UITableViewDataSource
>
@end

@implementation ExampleViewController {

	ExampleView * __weak _view;

	BOOL _busy;

	NSMutableArray<FIRDocumentSnapshot *> *_items;
	id<FIRListenerRegistration> _top5Listener;

	FIRDocumentSnapshot *_topItem;
	id<FIRListenerRegistration> _top1Listener;

	id<FIRListenerRegistration> _topCookieListener;
}

- (id)init {

	if (self = [super initWithNibName:nil bundle:nil]) {

		NSLog(@"Example app instance ID: %@", [self exampleInstanceId]);
	}

	return self;
}

- (void)loadView {
	ExampleView *v = [[ExampleView alloc] init];
	self.view = _view = v;
}

- (void)viewDidLoad {

	[super viewDidLoad];

	_view.tableView.delegate = self;
	_view.tableView.dataSource = self;

	[_view.addCookiesButton addTarget:self action:@selector(didTapAddCookiesButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];

	[self addListenersIfNeeded];

	[self updateUI];
}

#pragma mark -

- (void)addListenersIfNeeded {

	if (!_top5Listener) {
		_top5Listener = [[[self cookiesCollection] queryLimitedTo:5]
			addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
				[self didUpdateTop5CollectionWithSnapshot:snapshot error:error];
			}
		];
	}

	// Not installing this 2nd listener won't change much, just try deleting 5th cookie a couple of times.
	if (!_top1Listener) {
		_top1Listener = [[[self cookiesCollection] queryLimitedTo:1]
			addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
				[self didUpdateTop1CollectionWithSnapshot:snapshot.documents.firstObject error:error];
			}
		];
	}
}

- (void)didUpdateTop5CollectionWithSnapshot:(FIRQuerySnapshot *)snapshot error:(NSError *)error {

	if (error) {

		NSLog(@"The top 5 query listener has failed: %@", error);

	} else {

		NSLog(
			@"Top 5 collection snapshot changed: %ld document(s) (from cache: %d)",
			(long)snapshot.documents.count,
			(int)snapshot.metadata.fromCache
		);

		_items = [snapshot.documents copy];

		NSMutableArray *names = [[NSMutableArray alloc] init];
		for (FIRDocumentSnapshot *s in _items) {
			[names addObject:s[@"name"]];
		}
		NSLog(@"Items: %@", names);

		[self updateUI];
	}
}

- (void)didUpdateTop1CollectionWithSnapshot:(FIRDocumentSnapshot *)snapshot error:(NSError *)error {

	if (error) {

		NSLog(@"The top 1 query listener has failed: %@", error);

	} else {

		_topItem = snapshot;
		[self addTopItemListener];
		[self updateUI];
	}
}

/** Installs a listener to the current top cookie. This is to reproduce the issue with `updateData:`. */
- (void)addTopItemListener {

	[_topCookieListener remove];
	_topCookieListener = nil;

	if (_topItem) {
		typeof(self) __weak weakSelf = self;
		_topCookieListener = [_topItem.reference addSnapshotListener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
			typeof(self) strongSelf = weakSelf;
			[strongSelf didUpdateTopCookieWithSnapshot:snapshot error:error];
		}];
	}
}

- (void)didUpdateTopCookieWithSnapshot:(FIRDocumentSnapshot *)snapshot error:(NSError *)error {

	if (error) {

		NSLog(@"Top cookie listener has failed: %@", error);

	} else {

		NSLog(@"Top cookie has changed: %@", snapshot.data);

		_topItem = snapshot;
		[self updateUI];
	}
}

#pragma mark -

- (NSString *)exampleInstanceIdKey {
	return @"ExampleInstanceID";
}

/** I don't want multiple instances of the example to interfere, so let's have a random ID for every instance of the app. */
- (NSString *)exampleInstanceId {

	NSString *instanceId = [[NSUserDefaults standardUserDefaults] stringForKey:[self exampleInstanceIdKey]];

	if ([instanceId length] == 0) {

		instanceId = [[NSUUID UUID] UUIDString];
		[[NSUserDefaults standardUserDefaults] setObject:instanceId forKey:[self exampleInstanceIdKey]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

	return instanceId;
}

- (NSString *)generationNumberKey {
	return @"ExampleGenerationNumber";
}

- (NSInteger)nextGenerationNumber {

	NSInteger generation = [[NSUserDefaults standardUserDefaults] integerForKey:[self generationNumberKey]];
	generation++;

	[[NSUserDefaults standardUserDefaults] setInteger:generation forKey:[self generationNumberKey]];
	// To make sure generation number grows even if the app is terminated with a debugger.
	[[NSUserDefaults standardUserDefaults] synchronize];

	return generation;
}

- (FIRDocumentReference *)rootDocument {
	return [[[FIRFirestore firestore] collectionWithPath:@"examples"] documentWithPath:[self exampleInstanceId]];
}

- (FIRCollectionReference *)cookiesCollection {
	return [[self rootDocument] collectionWithPath:@"cookies"];
}

#pragma mark -

- (void)didTapAddCookiesButton:(id)sender {

	if (_busy) {
		NSLog(@"Already adding something...");
		return;
	}

	_busy = YES;
	[self updateUI];

	NSLog(@"Started adding cookies...");

	NSArray<NSString *> *cookies = @[
		@"Almond cookie",
		@"Biscotti",
		@"Bourbon biscuit",
		@"Caramel shortbread",
		@"Charcoal biscuit",
		@"Coconut macaroon",
		@"Cream cracker",
		@"Fortune cookie",
		@"Lebkuchen",
		@"Macaroon",
		@"Oreo",
		@"Peanut butter cookie",
		@"Speculaas",
		@"Stroopwafel",
		@"Wafer"
	];

	NSInteger generation = [self nextGenerationNumber];

	NSInteger __block documentsAdded = 0;
	NSMutableArray * __block errors = [[NSMutableArray alloc] init];

	for (NSString *cookieName in cookies) {

		[[self cookiesCollection]
			addDocumentWithData:@{
				@"name" : [NSString stringWithFormat:@"%@ #%ld", cookieName, (long)generation],
				@"favorite" : @NO
			}
			completion:^(NSError * _Nullable error) {
				if (error) {
					[errors addObject:error];
				} else {
					documentsAdded++;
				}
				if (documentsAdded + [errors count] == cookies.count) {
					[self didFinishAddingCookiesWithErrors:errors];
				}
			}
		];
	}
}

- (void)didFinishAddingCookiesWithErrors:(NSArray *)errors {

	_busy = NO;
	[self updateUI];

	NSError *firstError = errors.firstObject;
	if (firstError) {
		[self showErrorWithMessage:@"Could not get more cookies" error:firstError];
	} else {
		[self showMessage:@"Got more cookies. Enjoy!"];
	}
}

#pragma mark -

- (void)updateUI {

	if (![self isViewLoaded])
		return;

	if (_topItem) {
		if ([_topItem[@"favorite"] boolValue]) {
			_view.topCookieLabel.text = [NSString stringWithFormat:@"Top: %@ ❤️", _topItem[@"name"]];
		} else {
			_view.topCookieLabel.text = [NSString stringWithFormat:@"Top: %@", _topItem[@"name"]];
		}
	} else {
		_view.topCookieLabel.text = @"No top cookie yet";
	}

	if (_busy) {
		[_view.activityIndicator startAnimating];
	} else {
		[_view.activityIndicator stopAnimating];
	}

	[_view.tableView reloadData];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *reuseIdentifier = @"normalCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
	}

	FIRDocumentSnapshot *item = _items[indexPath.row];

	cell.textLabel.text = item[@"name"];

	if ([item[@"favorite"] boolValue]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	FIRDocumentSnapshot *snapshot = _items[indexPath.row];

	NSString *name = snapshot[@"name"];

	BOOL favorite = ![snapshot[@"favorite"] boolValue];

	if (favorite) {
		NSLog(@"Marking '%@' as favorite", name);
	} else {
		NSLog(@"Unmarking '%@' as favorite", name);
	}

	[snapshot.reference
		updateData:@{ @"favorite" : @(favorite) }
		completion:^(NSError * _Nullable error) {
			if (error) {
				[self
					showErrorWithMessage:[NSString stringWithFormat:@"Could not (un)mark '%@' as favorite", name]
					error:error
				];
			} else {
				if (favorite)
					NSLog(@"Successfully marked '%@' as favorite", name);
				else
					NSLog(@"Successfully unmarked '%@' as favorite", name);
			}
		}
	];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @[
		[UITableViewRowAction
			rowActionWithStyle:UITableViewRowActionStyleDestructive
			title:@"Eat"
			handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

				FIRDocumentSnapshot *snapshot = self->_items[indexPath.row];
				NSString *name = snapshot[@"name"];

				NSLog(@"Deleting the document for '%@'", name);

				[snapshot.reference deleteDocumentWithCompletion:^(NSError * _Nullable error) {
					if (error) {
						[self showErrorWithMessage:[NSString stringWithFormat:@"Could not delete '%@'", name] error:error];
					} else {
						NSLog(@"Deleted '%@'", name);
					}
				}];
			}
		]
	];
}

#pragma mark -

- (void)showErrorWithMessage:(NSString *)message error:(NSError *)error {

	NSLog(@"Error '%@': %@", message, error);

	UIAlertController *alertController = [UIAlertController
		alertControllerWithTitle:message
		message:[error description]
		preferredStyle:UIAlertControllerStyleAlert
	];
	[alertController addAction:[UIAlertAction
		actionWithTitle:@"OK"
		style:UIAlertActionStyleCancel
		handler:^(UIAlertAction *action) {
			[alertController dismissViewControllerAnimated:YES completion:nil];
		}
	]];

	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)showMessage:(NSString *)message {

	NSLog(@"Message '%@'", message);

	UIAlertController *alertController = [UIAlertController
		alertControllerWithTitle:message
		message:nil
		preferredStyle:UIAlertControllerStyleAlert
	];
	[alertController addAction:[UIAlertAction
		actionWithTitle:@"OK"
		style:UIAlertActionStyleCancel
		handler:^(UIAlertAction *action) {
			[alertController dismissViewControllerAnimated:YES completion:nil];
		}
	]];

	[self presentViewController:alertController animated:YES completion:nil];
}

@end
