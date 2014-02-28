//
//  ViewController.m
//  RBColumnViewLayoutDemo
//
//  Created by Rob Booth on 2/20/14.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "RBCollectionViewBalancedColumnLayout.h"

@interface ViewController () < RBCollectionViewBalancedColumnLayoutDelegate >

@property (nonatomic, strong) NSMutableDictionary * cellHeights;
@property (nonatomic, strong) NSArray * imageHeights;
@property (nonatomic, strong) NSArray * data;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.cellHeights = [NSMutableDictionary dictionary];

	RBCollectionViewBalancedColumnLayout * layout = (id)self.collectionView.collectionViewLayout;
	layout.interItemSpacingY = 10;
	layout.stickyHeader = YES;

	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewBalancedColumnHeaderKind withReuseIdentifier:@"header"];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewBalancedColumnFooterKind withReuseIdentifier:@"footer"];


	// Setup Data - I know ugly data structure, but this is just a demo
	self.data = @[
		@[
			@{ @"name" : @"Archangel", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/8/03/526165ed93180" },
			@{ @"name" : @"Colossus", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/6/e0/51127cf4b996f" },
			@{ @"name" : @"Cyclops", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/6/70/526547e2d90ad" },
			@{ @"name" : @"Domino", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/f/60/526031dc10516" },
			@{ @"name" : @"Emma Frost", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/9/80/51151ef7cf4c8" },
			@{ @"name" : @"Gambit", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/a/40/52696aa8aee99" },
			@{ @"name" : @"Ghost Rider (Johnny Blaze)", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/3/80/52696ba1353e7" },
			@{ @"name" : @"Jubilee", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/6/c0/4e7a2148b6e59" },
			@{ @"name": @"Iceman", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/1/d0/52696c836898c"},
		],
		@[
			@{ @"name" : @"Doctor Doom", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/8/90/5273cac0ac417" },
			@{ @"name": @"Sabretooth (Ultimate)", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/8/c0/4c0033dfc318e" },
			@{ @"name": @"Magneto", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/3/b0/5261a7e53f827" },
			@{ @"name": @"Mastermind", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/7/d0/4c003d43b02ab" },
			@{ @"name": @"Black Cat (Ultimate)", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/5/80/4c00357da502e" },
			@{ @"name" : @"Dracula", @"path" : @"http://i.annihil.us/u/prod/marvel/i/mg/a/03/526955af18612" },
			@{ @"name": @"Scalphunter", @"path": @"http://i.annihil.us/u/prod/marvel/i/mg/9/10/4ce5a473b81b3" },
		]
	];

	self.imageHeights = @[
		@{ @"name" : @"standard_fantastic", @"height" : @( 250 ) },
		@{ @"name" : @"portrait_uncanny", @"height" : @( 450 ) },
		@{ @"name" : @"landscape_xlarge", @"height" : @( 200 ) }
	];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.data count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.data[section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView * reuseView;

	if (kind == RBCollectionViewBalancedColumnHeaderKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];

		reuseView.backgroundColor = (indexPath.section == 0) ? [UIColor whiteColor] : [UIColor blackColor];

		UILabel * label = (id)[reuseView viewWithTag:1];
		if (label == nil)
		{
			label = [[UILabel alloc] init];
			label.tag = 1;
			label.frame = CGRectMake(0, 0, reuseView.frame.size.width, reuseView.frame.size.height);
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.textAlignment = NSTextAlignmentCenter;
			[reuseView addSubview:label];
		}

		label.text = @"Heroes";
		label.textColor = [UIColor blackColor];
		if (indexPath.section == 1)
		{
			label.text = @"Villains";
			label.textColor = [UIColor whiteColor];
		}
	}

	if (kind == RBCollectionViewBalancedColumnFooterKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];

		reuseView.backgroundColor = [UIColor colorWithRed:0xdc/255.0 green:0xdc/255.0 blue:0xdc/255.0 alpha:1];

		UILabel * label = (id)[reuseView viewWithTag:1];
		if (label == nil)
		{
			label = [[UILabel alloc] init];
			label.tag = 1;
			label.frame = CGRectMake(0, 0, reuseView.frame.size.width, reuseView.frame.size.height);
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.textAlignment = NSTextAlignmentCenter;
			[reuseView addSubview:label];
		}

		label.text = @"Data provided by Marvel. © 2014 Marvel";
	}

	return reuseView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

	NSDictionary * portrait;
	portrait = self.data[indexPath.section][indexPath.row];

	NSDictionary * imageType = self.imageHeights[indexPath.row % 3];
	NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.jpg", portrait[@"path"], imageType[@"name"]]];

	// @TODO: don't do things this way, the UI thread hates it!
	UIImageView * imageView = (id)[cell viewWithTag:1];
	imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];

	UILabel * label = (id)[cell viewWithTag:2];
	label.text = portrait[@"name"];

	cell.layer.masksToBounds = NO;
	cell.layer.shadowOpacity = 0.4f;
	cell.layer.shadowRadius = 2.0f;
	cell.layer.shadowOffset = CGSizeMake(0, 1);
	cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;

	return cell;
}

#pragma mark - RBCollectionViewBalancedColumnLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
	return 50.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary * imageType = self.imageHeights[indexPath.row % 3];
	CGFloat height = [imageType[@"height"] floatValue];
	return height;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
	return 25.0;
}

@end
