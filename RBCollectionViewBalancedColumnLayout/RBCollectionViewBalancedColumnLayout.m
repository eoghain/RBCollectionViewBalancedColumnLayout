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
@property (nonatomic, strong) NSMutableDictionary * sectionColumns;
@property (nonatomic, strong) NSMutableDictionary * sectionCellWidths;
@property (nonatomic, strong) NSMutableDictionary * sectionColumnCounts;
@property (nonatomic, strong) NSMutableDictionary * sectionGutters;
@property (nonatomic, strong) NSMutableDictionary * headers;
@property (nonatomic, strong) NSMutableDictionary * footers;

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
	self.stickyHeader = NO;
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

- (CGFloat)bottomYOfSection:(NSInteger)section
{
	CGFloat bottomY = 0;

	NSInteger tallestColumn = [self tallestColumnInSection:section];
	bottomY = [self heightForColumn:tallestColumn inSection:section];

	NSInteger lastRow = [self.collectionView numberOfItemsInSection:section] - 1;
	NSIndexPath * footerIndexPath = [NSIndexPath indexPathForItem:lastRow inSection:section];
	UICollectionViewLayoutAttributes * footer = [self.footers objectForKey:footerIndexPath];

	return MAX(bottomY, CGRectGetMaxY(footer.frame));
}

- (UICollectionViewLayoutAttributes *)lastAttributesInColumn:(NSInteger)column inSection:(NSInteger)section
{
	NSArray * columns = [self.sectionColumns objectForKey:@( section )];
	__block UICollectionViewLayoutAttributes * attributes;

	[columns[column] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * objAttributes, NSUInteger idx, BOOL *stop) {
		if (CGRectGetMaxY(objAttributes.frame) > CGRectGetMaxY(attributes.frame))
		{
			attributes = objAttributes;
		}
	}];

	return attributes;
}

- (CGFloat)heightForColumn:(NSInteger)column inSection:(NSInteger)section
{
	UICollectionViewLayoutAttributes * attributes = [self lastAttributesInColumn:column inSection:section];
	return CGRectGetMaxY(attributes.frame) + self.interItemSpacingY;
}

- (NSInteger)shortestColumnInSection:(NSInteger)section
{
	NSArray * columns = [self.sectionColumns objectForKey:@( section )];
	NSInteger shortestColumn = 0;
	CGFloat shortestHeight = CGFLOAT_MAX;

	for (NSInteger column = 0; column < columns.count; column++)
	{
		CGFloat columnHeight = [self heightForColumn:column inSection:section];

		if (columnHeight < shortestHeight)
		{
			shortestHeight = columnHeight;
			shortestColumn = column;
		}
	}

	return shortestColumn;
}

- (NSInteger)tallestColumnInSection:(NSInteger)section
{
	NSArray * columns = [self.sectionColumns objectForKey:@( section )];
	NSInteger tallestColumn = 0;
	CGFloat tallestHeight = 0;

	for (NSInteger column = 0; column < columns.count; column++)
	{
		CGFloat columnHeight = [self heightForColumn:column inSection:section];

		if (columnHeight > tallestHeight)
		{
			tallestHeight = columnHeight;
			tallestColumn = column;
		}
	}

	return tallestColumn;
}

- (void)removeAttributes:(UICollectionViewLayoutAttributes *)attributes fromColumn:(NSInteger)column inSection:(NSInteger)section
{
	NSMutableArray * columns = [self.sectionColumns objectForKey:@( section )];
	[columns[column] removeObject:attributes];
}

- (void)addAttributes:(UICollectionViewLayoutAttributes *)attributes toColumn:(NSInteger)column inSection:(NSInteger)section
{
	NSMutableArray * columns = [self.sectionColumns objectForKey:@( section )];
	[columns[column] addObject:attributes];
}

- (NSInteger)columnForAttributes:(UICollectionViewLayoutAttributes *)attributes inSection:(NSInteger)section
{
	NSMutableArray * columns = [self.sectionColumns objectForKey:@( section )];
	NSInteger columnIdx = NSNotFound;

	for (NSInteger column = 0; column < columns.count; column++)
	{
		if ([columns[column] containsObject:attributes])
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

	id delegate = self.collectionView.delegate;
	NSInteger numSections = [self.collectionView numberOfSections];
	self.headers = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.footers = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.sectionColumns = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.sectionColumnCounts = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.sectionCellWidths = [NSMutableDictionary dictionaryWithCapacity:numSections];
	self.sectionGutters = [NSMutableDictionary dictionaryWithCapacity:numSections];

	for (NSInteger section = 0; section < numSections; section++)
	{
		CGFloat width = self.cellWidth;
		if ([delegate respondsToSelector:@selector(collectionView:layout:widthForCellsInSection:)])
		{
			width = [delegate collectionView:self.collectionView layout:self widthForCellsInSection:section];
		}

		NSInteger columnCount = (int)(self.collectionView.frame.size.width / width);
		[self.sectionCellWidths setObject:@( width ) forKey:@( section )];
		[self.sectionColumnCounts setObject:@( columnCount ) forKey:@( section )];

		// create gutters
		CGFloat totalWidth = self.collectionView.frame.size.width;
		CGFloat usedWidth = (columnCount * width);
		CGFloat remainingSpace = totalWidth - usedWidth;
		NSInteger gutterCount = columnCount + 1;
		[self.sectionGutters setObject:@( remainingSpace / gutterCount ) forKey:@( section )];
	}

	NSIndexPath *indexPath;
	for(NSInteger section = 0; section < numSections; section++)
	{
		// create column placeholders
		NSMutableArray * columns = [NSMutableArray array];
		NSInteger columnCounts = [[self.sectionColumnCounts objectForKey:@( section )] intValue];
		for (NSInteger column = 0; column < columnCounts; column++)
		{
			[columns addObject:[NSMutableArray array]];
		}
		[self.sectionColumns setObject:columns forKey:@( section )];

		indexPath = [NSIndexPath indexPathForItem:0 inSection:section];

		NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
		for(NSInteger item = 0; item < numItems; item++)
		{
			indexPath = [NSIndexPath indexPathForItem:item inSection:section];

			// Header
			if (indexPath.item == 0 && [delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)])
			{
				UICollectionViewLayoutAttributes * headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewBalancedColumnHeaderKind atIndexPath:indexPath];

				[headerLayoutDictionary setObject:headerAttributes forKey:indexPath];
				[self.headers setObject:headerAttributes forKey:indexPath];
            }

			UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
			[cellLayoutDictionary setObject:attributes forKey:indexPath];

			// Footer
			if(item == numItems - 1 && [delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)])
			{
				UICollectionViewLayoutAttributes * footerAttributes = [self layoutAttributesForSupplementaryViewOfKind:RBCollectionViewBalancedColumnFooterKind atIndexPath:indexPath];

				[footerLayoutDictionary setObject:footerAttributes forKey:indexPath];
				[self.footers setObject:footerAttributes forKey:indexPath];
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

			if (CGRectIntersectsRect(rect, layoutAttributes.frame) || [elementIdentifier isEqualToString:RBCollectionViewBalancedColumnHeaderKind])
			{
				[attributes addObject:layoutAttributes];
			}
		}];
	}];

	if (self.stickyHeader == NO)
	{
		return attributes;
	}

	[attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * layoutAttributes, NSUInteger idx, BOOL *stop) {
		if (layoutAttributes.representedElementKind == RBCollectionViewBalancedColumnHeaderKind)
		{
			layoutAttributes.zIndex = 1024;

			CGFloat top = MAX(layoutAttributes.frame.origin.y, self.collectionView.contentOffset.y);
			CGFloat left = layoutAttributes.frame.origin.x;
			CGFloat width = self.collectionView.bounds.size.width;
			CGFloat height = layoutAttributes.frame.size.height;

			NSInteger section = layoutAttributes.indexPath.section;
			CGFloat bottomY = [self bottomYOfSection:section];
			top = MIN(top, bottomY - height);

			layoutAttributes.frame = CGRectMake(left, top, width, height);
		}
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
		}

		if (indexPath.section != 0)
		{
			top = [self bottomYOfSection:indexPath.section - 1];
		}
	}

	if (kind == RBCollectionViewBalancedColumnFooterKind)
	{
		if ([delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)])
		{
			height = [delegate collectionView:self.collectionView layout:self heightForFooterInSection:indexPath.section];
		}

		top = [self heightForColumn:[self tallestColumnInSection:indexPath.section] inSection:indexPath.section];
	}

	attributes.frame = CGRectMake(left, top, width, height);

	return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

	NSInteger column = [self shortestColumnInSection:indexPath.section];

	CGFloat cellWidth = [[self.sectionCellWidths objectForKey:@( indexPath.section )] floatValue];
	CGFloat gutterSpace = [[self.sectionGutters objectForKey:@( indexPath.section )] floatValue];
	CGFloat top = [self heightForColumn:column inSection:indexPath.section];
	CGFloat left = gutterSpace + ((cellWidth + gutterSpace) * column);
	CGFloat height = cellWidth;
	CGFloat width = cellWidth;

	id delegate = self.collectionView.delegate;

	if ([delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:)])
	{
		height = [delegate collectionView:self.collectionView layout:self heightForItemAtIndexPath:indexPath];
	}

	if (top == self.interItemSpacingY) // We are the first cell
	{
		top -= self.interItemSpacingY; // No spaceing on first cell in column

		// Add height of previous section
		if (indexPath.section != 0)
		{
			top = [self bottomYOfSection:indexPath.section - 1];
		}

		// Add header height if appropriate
		NSIndexPath * sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];

		if ([self.headers objectForKey:sectionIndexPath])
		{
			UICollectionViewLayoutAttributes * headerAttributes = [self.headers objectForKey:sectionIndexPath];
			if (headerAttributes.frame.size.height != 0)
			{
				top += headerAttributes.frame.size.height + self.interItemSpacingY;
			}
		}
	}

	attributes.frame = CGRectMake(left, top, width, height);

	NSInteger existingColumnPosition = [self columnForAttributes:attributes inSection:indexPath.section];

	if (existingColumnPosition != column)
	{
		if (existingColumnPosition != NSNotFound)
		{
			[self removeAttributes:attributes fromColumn:existingColumnPosition inSection:indexPath.section];
		}
		[self addAttributes:attributes toColumn:column inSection:indexPath.section];
	}

    return attributes;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    if (self.stickyHeader)
    {
        return YES;
    }
    
    if (newBound.size.width != self.collectionView.bounds.size.width)
    {
        return YES;
    }
    
    return NO;
}

- (CGSize)collectionViewContentSize
{
	CGFloat width = self.collectionView.frame.size.width;

	__block CGFloat maxY = 0;

	[self.sectionColumns enumerateKeysAndObjectsUsingBlock:^(id key, NSArray * columns, BOOL *stop) {
		for (NSInteger column = 0; column < columns.count; column++)
		{
			CGFloat newHeight = [self heightForColumn:column inSection:[key integerValue]];

			if (newHeight > maxY)
			{
				maxY = newHeight;
			}
		}
	}];

	__block CGFloat footerMaxY = 0;

	[self.footers enumerateKeysAndObjectsUsingBlock:^(id key, UICollectionViewLayoutAttributes * obj, BOOL *stop) {

		CGFloat objMaxY = CGRectGetMaxY(obj.frame);
		if (objMaxY > footerMaxY)
		{
			footerMaxY = objMaxY;
		}
	}];

	if (footerMaxY > maxY)
	{
		maxY = footerMaxY;
	}

	return CGSizeMake(width, maxY);
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
