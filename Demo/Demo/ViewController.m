//
//  ViewController.m
//  RBColumnViewLayoutDemo
//
//  Created by Rob Booth on 2/20/14.
//

#import "ViewController.h"

#import "RBCollectionViewBalancedColumnLayout.h"

@interface ViewController () < RBCollectionViewBalancedColumnLayoutDelegate >

@property (nonatomic, strong) NSMutableDictionary * cellHeights;

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

	((RBCollectionViewBalancedColumnLayout *)self.collectionView.collectionViewLayout).interItemSpacingY = 10;

	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewBalancedColumnHeaderKind withReuseIdentifier:@"header"];
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:RBCollectionViewBalancedColumnFooterKind withReuseIdentifier:@"header"];
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
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 10;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionReusableView * reuseView;

	if (kind == RBCollectionViewBalancedColumnHeaderKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];

		reuseView.backgroundColor = (indexPath.section % 2) ? [UIColor blueColor] : [UIColor redColor];
	}

	if (kind == RBCollectionViewBalancedColumnFooterKind)
	{
		reuseView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];

		reuseView.backgroundColor = (indexPath.section % 2) ? [UIColor greenColor] : [UIColor yellowColor];
	}

	return reuseView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

	int height = [[self.cellHeights objectForKey:indexPath] floatValue];
	CGSize cellSize = CGSizeMake(300, height);

	UILabel * label = (id)[cell viewWithTag:1];
	label.text = [NSString stringWithFormat:@"%d", indexPath.row];

	UILabel * size = (id)[cell viewWithTag:2];
	size.text = NSStringFromCGSize(cellSize);

	return cell;
}

#pragma mark - RBCollectionViewBalancedColumnLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
	return 50.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
	int height = [[self.cellHeights objectForKey:indexPath] floatValue];
	if (height > 0)
		return height;

	height = 100 + rand() % 400;
	if (indexPath.row == 3) height = 1000;
	[self.cellHeights setObject:@( height ) forKey:indexPath];

	return height;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout*)collectionViewLayout heightForFooterInSection:(NSInteger)section
{
	return (section == 1) ? 25.0 : 0;
}

@end
