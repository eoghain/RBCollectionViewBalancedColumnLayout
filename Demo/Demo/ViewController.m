//
//  ViewController.m
//  RBColumnViewLayoutDemo
//
//  Created by Rob Booth on 2/20/14.
//

#import "ViewController.h"

#import "RBCollectionViewBalancedColumnLayout.h"

@interface ViewController ()

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
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 10;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	int height = [[self.cellHeights objectForKey:indexPath] floatValue];
	if (height > 0)
		return CGSizeMake(300, height);

	height = 100 + rand() % 400;
	if (indexPath.row == 3) height = 1000;
	CGSize cellSize = CGSizeMake(300, height);
	[self.cellHeights setObject:@( height ) forKey:indexPath];

	return cellSize;
}


@end
