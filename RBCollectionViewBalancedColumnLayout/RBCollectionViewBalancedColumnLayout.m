//
//  RBCollectionViewColumnLayout.m
//  RBColumnViewLayoutDemo
//
//  Created by Rob Booth on 2/20/14.
//

#import "RBCollectionViewColumnLayout.h"

@interface RBCollectionViewColumnLayout()

@property (nonatomic, strong) NSMutableDictionary * layoutInformation;
@property (nonatomic, strong) NSMutableArray * columns;
@property (nonatomic, strong) NSMutableArray * columnGutters;
@property (nonatomic, assign) CGFloat gutterSpace;

@end

@implementation RBCollectionViewColumnLayout

# pragma mark - Lifecycle

- (id)init
{
	self = [super init];
	if (self) {
		[self setup];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		[self setup];
	}

	return self;
}

- (void)setup
{
	self.interItemSpacingY = 5.0f;
	self.cellWidth = 300; // Defaults to full width of iPhone + 10px gutters
}

#pragma mark - Properties (Getters & Setters)

- (void)setCellWidth:(NSUInteger)cellWidth
{
	if (_cellWidth == cellWidth)
		return;

	_cellWidth = cellWidth;
	[self invalidateLayout];
}

#pragma mark - Helpers

- (UICollectionViewLayoutAttributes *)lastAttributesInColumn:(NSInteger)column
{
	return [self.layoutInformation objectForKey:[self.columns[column] lastObject]];
}

- (CGFloat)heightForColumn:(NSInteger)column
{
	UICollectionViewLayoutAttributes * attributes = [self lastAttributesInColumn:column];
	return attributes.frame.size.height + attributes.frame.origin.y + self.interItemSpacingY;
}

- (NSInteger)shortestColumn
{
	NSInteger shortestColumn = 0;
	CGFloat shortestHeight = CGFLOAT_MAX;

	for (NSInteger column = 0; column < self.columns.count; column++)
	{
		CGFloat columnHeight = [self heightForColumn:column];

		if (columnHeight < shortestHeight)
		{
			shortestHeight = columnHeight;
			shortestColumn = column;
		}
	}

	return shortestColumn;
}

#pragma mark - UICollectionViewLayout methods

- (void)prepareLayout
{
	[super prepareLayout];

	self.layoutInformation = [NSMutableDictionary dictionary];
	self.columns = [NSMutableArray array];
	self.columnGutters = [NSMutableArray array];

	NSInteger columnCount = (int)(self.collectionView.frame.size.width / self.cellWidth);

	// create gutters
	CGFloat totalWidth = self.collectionView.frame.size.width;
	CGFloat usedWidth = (columnCount * self.cellWidth);
	CGFloat remainingSpace = totalWidth - usedWidth;
	NSInteger gutterCount = columnCount + 1;
	self.gutterSpace = remainingSpace / gutterCount;

	// create column placeholders
	for (NSInteger column = 0; column < columnCount; column++)
	{
		[self.columns addObject:[NSMutableArray new]];
	}

	NSIndexPath *indexPath;
	NSInteger numSections = [self.collectionView numberOfSections];
	for(NSInteger section = 0; section < numSections; section++)
	{
		NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
		for(NSInteger item = 0; item < numItems; item++)
		{
			indexPath = [NSIndexPath indexPathForItem:item inSection:section];

			UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
			[self.layoutInformation setObject:attributes forKey:indexPath];
		}
	}
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
	[self.layoutInformation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		UICollectionViewLayoutAttributes * layoutAttributes = obj;
		if (CGRectIntersectsRect(rect, layoutAttributes.frame))
		{
			[attributes addObject:layoutAttributes];
		}
	}];

	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	id delegate = self.collectionView.delegate;
	if ([delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)])
	{
		UICollectionReusableView * view = [delegate collectionView:self.collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
	}

	return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

	CGSize itemSize = CGSizeMake(self.cellWidth, self.cellWidth);

	id delegate = self.collectionView.delegate;

	if ([delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
	{
		itemSize = [delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
	}

	if (itemSize.width > self.cellWidth)
		itemSize.width = self.cellWidth;

	NSInteger column = [self shortestColumn];

	CGFloat top = 22;
	CGFloat left = self.gutterSpace + ((self.cellWidth + self.gutterSpace) * column);

	UICollectionViewLayoutAttributes * lastAttributes = [self lastAttributesInColumn:column];

	if (lastAttributes != nil)
	{
		top = lastAttributes.center.y + (lastAttributes.size.height / 2) + self.interItemSpacingY;
	}

	CGRect itemFrame = CGRectZero;
	itemFrame.origin.x = left;
	itemFrame.origin.y = top;
	itemFrame.size = itemSize;

    attributes.size = itemFrame.size;
    attributes.center = CGPointMake(CGRectGetMidX(itemFrame), CGRectGetMidY(itemFrame));

	[[self.columns objectAtIndex:column] addObject:indexPath];

    return attributes;
}

- (CGSize)collectionViewContentSize
{
	CGFloat width = self.collectionView.frame.size.width;
	CGFloat height = 0;

	for (NSInteger column = 0; column < self.columns.count; column++)
	{
		CGFloat newHeight = [self heightForColumn:column];

		if (newHeight > height)
		{
			height = newHeight;
		}
	}

	return CGSizeMake(width, height);
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];

	attributes.alpha = 1.0;

	return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];

	if (!attributes) // If cell is moving off the screen attributes will be nil, but we want it to animate
		attributes = [self.layoutInformation objectForKey:itemIndexPath];

	attributes.alpha = 1.0;

	return attributes;
}

@end
