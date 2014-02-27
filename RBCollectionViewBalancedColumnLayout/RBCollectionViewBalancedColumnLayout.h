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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(RBCollectionViewBalancedColumnLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section;
@end

@interface RBCollectionViewBalancedColumnLayout : UICollectionViewLayout

@property (nonatomic, assign) NSUInteger cellWidth;
@property (nonatomic, assign) CGFloat interItemSpacingY;

@end
