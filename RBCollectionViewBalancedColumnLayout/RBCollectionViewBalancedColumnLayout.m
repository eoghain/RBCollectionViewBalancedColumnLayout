//
//  RBCollectionViewBalancedColumnLayout.m
//  RBColumnViewLayoutDemo
//
//  Created by Rob Booth on 2/20/14.
//

#import "RBCollectionViewBalancedColumnLayout.h"

@interface RBCollectionViewBalancedColumnLayout()

@property (nonatomic, strong) NSMutableDictionary * layoutInformation;
@property (nonatomic, strong) NSMutableArray * columns;
@property (nonatomic, strong) NSMutableArray * columnGutters;
@property (nonatomic, assign) CGFloat gutterSpace;

@property (nonatomic, strong) NSMutableArray * insertIndexPaths;
@property (nonatomic, strong) NSMutableArray * deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray * reloadIndexPaths;

@end

@implementation RBCollectionViewBalancedColumnLayout

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

- (void)removeCell:(id)cell fromColumn:(NSInteger)column
{
	[[self.columns objectAtIndex:column] removeObject:cell];
}

- (void)addCell:(id)cell toColumn:(NSInteger)column
{
	[[self.columns objectAtIndex:column] addObject:cell];
}

- (NSInteger)columnForCell:(id)cell
{
	NSInteger columnIdx = NSNotFound;

	for (NSInteger column = 0; column < self.columns.count; column++)
	{
		if ([[self.columns objectAtIndex:column] containsObject:cell])
		{
			columnIdx = column;
			break;
		}
	}

	return columnIdx;
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

	NSInteger existingColumnPosition = [self columnForCell:indexPath];

	if (existingColumnPosition != column)
	{
		if (existingColumnPosition != NSNotFound)
		{
			[self removeCell:indexPath fromColumn:existingColumnPosition];
		}
		[self addCell:indexPath toColumn:column];
	}

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

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
	// Keep track of insert and delete index paths
	[super prepareForCollectionViewUpdates:updateItems];

	self.deleteIndexPaths = [NSMutableArray array];
	self.insertIndexPaths = [NSMutableArray array];
	self.reloadIndexPaths = [NSMutableArray array];

	for (UICollectionViewUpdateItem *update in updateItems)
	{
		if (update.updateAction == UICollectionUpdateActionDelete)
		{
			[self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionInsert)
		{
			[self.insertIndexPaths addObject:update.indexPathAfterUpdate];
		}
		else if (update.updateAction == UICollectionUpdateActionReload)
		{
			[self.reloadIndexPaths addObject:update.indexPathAfterUpdate];
		}
	}
}

- (void)finalizeCollectionViewUpdates
{
	[super finalizeCollectionViewUpdates];
	// release the insert and delete index paths
	self.deleteIndexPaths = nil;
	self.insertIndexPaths = nil;
	self.reloadIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes;

	if ([self.reloadIndexPaths containsObject:itemIndexPath])
	{
		attributes = [self.layoutInformation objectForKey:itemIndexPath];
	}
	else
	{
		attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
	}

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
