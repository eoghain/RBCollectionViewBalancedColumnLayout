//
//  RBCollectionViewBalancedColumnLayout.m
//  RBColumnViewLayoutDemo
//
//  Created by Rob Booth on 2/20/14.
//

#import "RBCollectionViewBalancedColumnLayout.h"

static NSString *const RBCollectionViewBalancedColumnCellKind = @"RBCollectionViewBalancedColumnCellKind";
NSString *const RBCollectionViewBalancedColumnHeaderKind = @"RBCollectionViewBalancedColumnHeaderKind";
NSString *const RBCollectionViewBalancedColumnFooterKind = @"RBCollectionViewBalancedColumnFooterKind";

@interface RBCollectionViewBalancedColumnLayout()

@property (nonatomic, strong) NSMutableDictionary * layoutInformation;
@property (nonatomic, strong) NSMutableArray * columns;
@property (nonatomic, strong) NSMutableDictionary * headers;
@property (nonatomic, strong) NSMutableDictionary * footers;
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

//- (void)reOrderColumn:(NSInteger)column
//{
//	NSInteger items = [self.columns[column] count];
//	__block NSMutableArray * newOrder = [NSMutableArray arrayWithCapacity:items];
//
//	NSInteger placed = 1;
//	while (placed <= items)
//	{
//		NSInteger index = items - placed;
////		__block CGRect checkFrame = CGRectZero;
//		__block UICollectionViewLayoutAttributes * attributes;
//
//		[self.columns[column] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * objAttributes, NSUInteger idx, BOOL *stop) {
//			if (attributes.frame.origin.y < objAttributes.frame.origin.y && [newOrder containsObject:objAttributes] == NO)
//			{
////				checkFrame = objAttributes.frame;
//				attributes = objAttributes;
//			}
//		}];
//
//		[newOrder setObject:attributes atIndexedSubscript:index];
//		placed++;
//	}
//
//}

- (UICollectionViewLayoutAttributes *)lastAttributesInColumn:(NSInteger)column
{
	__block UICollectionViewLayoutAttributes * attributes;

	[self.columns[column] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * objAttributes, NSUInteger idx, BOOL *stop) {
		if (CGRectGetMaxY(objAttributes.frame) > CGRectGetMaxY(attributes.frame))
		{
			attributes = objAttributes;
		}
	}];

	return attributes;
}

- (CGFloat)heightForColumn:(NSInteger)column
{
	UICollectionViewLayoutAttributes * attributes = [self lastAttributesInColumn:column];
	return CGRectGetMaxY(attributes.frame) + self.interItemSpacingY;
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

- (NSInteger)tallestColumn
{
	NSInteger tallestColumn = 0;
	CGFloat tallestHeight = 0;

	for (NSInteger column = 0; column < self.columns.count; column++)
	{
		CGFloat columnHeight = [self heightForColumn:column];

		if (columnHeight > tallestHeight)
		{
			tallestHeight = columnHeight;
			tallestColumn = column;
		}
	}

	return tallestColumn;
}

- (void)removeAttributes:(UICollectionViewLayoutAttributes *)attributes fromColumn:(NSInteger)column
{
	[self.columns[column] removeObject:attributes];
}

- (void)addAttributes:(UICollectionViewLayoutAttributes *)attributes toColumn:(NSInteger)column
{
	[self.columns[column] addObject:attributes];
}

- (NSInteger)columnForAttributes:(UICollectionViewLayoutAttributes *)attributes
{
	NSInteger columnIdx = NSNotFound;

	for (NSInteger column = 0; column < self.columns.count; column++)
	{
		if ([self.columns[column] containsObject:attributes])
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

	NSMutableDictionary *newLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary *cellLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary *headerLayoutDictionary = [NSMutableDictionary dictionary];
	NSMutableDictionary *footerLayoutDictionary = [NSMutableDictionary dictionary];

	self.headers = [NSMutableDictionary dictionary];
	self.footers = [NSMutableDictionary dictionary];
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
		[self.columns addObject:[NSMutableArray array]];
	}

	NSIndexPath *indexPath;
	NSInteger numSections = [self.collectionView numberOfSections];
	for(NSInteger section = 0; section < numSections; section++)
	{
		indexPath = [NSIndexPath indexPathForItem:0 inSection:section];

		NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
		for(NSInteger item = 0; item < numItems; item++)
		{
			// Header
			if (indexPath.item == 0)
			{
				UICollectionViewLayoutAttributes * headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewBalancedColumnHeaderKind atIndexPath:indexPath];

				if (headerAttributes.frame.size.height > 0.0)
				{
					[headerLayoutDictionary setObject:headerAttributes forKey:indexPath];
					[self.headers setObject:headerAttributes forKey:indexPath];
				}
            }

			indexPath = [NSIndexPath indexPathForItem:item inSection:section];
			UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
			[cellLayoutDictionary setObject:attributes forKey:indexPath];

			// Footer
			if(item == numItems - 1)
			{
				UICollectionViewLayoutAttributes * footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewBalancedColumnFooterKind atIndexPath:indexPath];

				if (footerAttributes.frame.size.height > 0.0)
				{
					[footerLayoutDictionary setObject:footerAttributes forKey:indexPath];
					[self.footers setObject:footerAttributes forKey:indexPath];
				}
			}
		}
	}

	newLayoutDictionary[RBCollectionViewBalancedColumnCellKind] = cellLayoutDictionary;
	newLayoutDictionary[RBCollectionViewBalancedColumnHeaderKind] = headerLayoutDictionary;
	newLayoutDictionary[RBCollectionViewBalancedColumnFooterKind] = footerLayoutDictionary;

    self.layoutInformation = newLayoutDictionary;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSMutableArray * attributes = [NSMutableArray arrayWithCapacity:self.layoutInformation.count];

	[self.layoutInformation enumerateKeysAndObjectsUsingBlock:^(NSString *elementIdentifier, NSDictionary *elementsInfo, BOOL *stop) {

		[elementsInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *layoutAttributes, BOOL *innerStop) {

			if (CGRectIntersectsRect(rect, layoutAttributes.frame))
			{
				[attributes addObject:layoutAttributes];
			}
		}];
	}];
	
	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes * attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];

	CGFloat height = 0;
	CGFloat top = 0;
	CGFloat left = 0;
	CGFloat width = self.collectionView.frame.size.width;

	id delegate = self.collectionView.delegate;

	if (kind == RBCollectionViewBalancedColumnHeaderKind)
	{
		if ([delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)])
		{
			height = [delegate collectionView:self.collectionView layout:self heightForHeaderInSection:indexPath.section];

			if (indexPath.section != 0)
			{
				NSInteger lastSection = indexPath.section - 1;
				NSInteger lastRowOfLastSection = [self.collectionView numberOfItemsInSection:lastSection] - 1;
				NSIndexPath * footerIndexPath = [NSIndexPath indexPathForItem:lastRowOfLastSection inSection:lastSection];
				UICollectionViewLayoutAttributes * previousFooter = [self.footers objectForKey:footerIndexPath];
				top = CGRectGetMaxY(previousFooter.frame);
			}
		}
	}

	if (kind == RBCollectionViewBalancedColumnFooterKind)
	{
		if ([delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)])
		{
			height = [delegate collectionView:self.collectionView layout:self heightForFooterInSection:indexPath.section];

			top = [self heightForColumn:[self tallestColumn]];
		}
	}

	attributes.frame = CGRectMake(left, top, width, height);

	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

	NSInteger column = [self shortestColumn];

	CGFloat top = [self heightForColumn:column];
	CGFloat left = self.gutterSpace + ((self.cellWidth + self.gutterSpace) * column);
	CGFloat height = self.cellWidth;
	CGFloat width = self.cellWidth;

	id delegate = self.collectionView.delegate;

	if ([delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:)])
	{
		height = [delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath];
	}

	if (top == self.interItemSpacingY) // We are the first cell
	{
		NSIndexPath * sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
		top -= self.interItemSpacingY; // No spaceing on first cell in column
		if ([self.headers objectForKey:sectionIndexPath])
		{
			UICollectionViewLayoutAttributes * headerAttributes = [self.headers objectForKey:sectionIndexPath];
			top = headerAttributes.frame.size.height + self.interItemSpacingY;
		}
	}

	attributes.frame = CGRectMake(left, top, width, height);

	NSInteger existingColumnPosition = [self columnForAttributes:attributes];

	if (existingColumnPosition != column)
	{
		if (existingColumnPosition != NSNotFound)
		{
			[self removeAttributes:attributes fromColumn:existingColumnPosition];
		}
		[self addAttributes:attributes toColumn:column];
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

	if (self.footers.count)
	{
		__block CGFloat footerHeight = 0;
		__block CGFloat maxY = 0;

		[self.footers enumerateKeysAndObjectsUsingBlock:^(id key, UICollectionViewLayoutAttributes * obj, BOOL *stop) {

			CGFloat objMaxY = CGRectGetMaxY(obj.frame);
			if (objMaxY > maxY)
			{
				maxY = objMaxY;
				footerHeight += obj.frame.size.height;
			}
		}];

		height += footerHeight;
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

//	for (NSInteger column = 0; column <= self.columns.count; column++)
//	{
//		[self reOrderColumn:column];
//	}

	// release the insert and delete index paths
	self.deleteIndexPaths = nil;
	self.insertIndexPaths = nil;
	self.reloadIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
	return [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
	return [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	UICollectionViewLayoutAttributes * attributes;

	if ([self.reloadIndexPaths containsObject:itemIndexPath])
	{
		attributes = self.layoutInformation[RBCollectionViewBalancedColumnCellKind][itemIndexPath];
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
		attributes = self.layoutInformation[RBCollectionViewBalancedColumnCellKind][itemIndexPath];

	attributes.alpha = 1.0;

	return attributes;
}

@end
