//
//  RBCollectionViewBalancedColumnLayout.h
//  RBColumnViewLayoutDemo
//
//  Created by Rob Booth on 2/20/14.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const RBCollectionViewBalancedColumnHeaderKind;
FOUNDATION_EXPORT NSString *const RBCollectionViewBalancedColumnFooterKind;

@class RBCollectionViewBalancedColumnLayout;

@protocol RBCollectionViewBalancedColumnLayoutDelegate <NSObject>

/**
 *  Height of the cell for indexPath, cells will be fit to the global cellWidth set on the layout
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param indexPath            cell index path
 *
 *  @return the height of the cell
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  Height of the header for a section (0 for no header in this section)
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param section              section index
 *
 *  @return the height of the header
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;

/**
 *  Height of the footer for a section (0 for no footer in this section)
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param section              section index
 *
 *  @return the height of the footer
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;

/**
 *  Width of the cells for a section
 *
 *  @param collectionView       target collection view
 *  @param collectionViewLayout reference to layout
 *  @param section              section index
 *
 *  @return the height of the footer
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout widthForCellsInSection:(NSInteger)section;

@end

@interface RBCollectionViewBalancedColumnLayout : UICollectionViewLayout

/**
 * Width for the cells
 */
@property (nonatomic, assign) NSUInteger cellWidth;

/**
 * Vertical spaceing between cells
 */
@property (nonatomic, assign) CGFloat interItemSpacingY;

/**
 * Stick the header to top until section goes out of scope
 */
@property (nonatomic, assign) BOOL stickyHeader;

@end
