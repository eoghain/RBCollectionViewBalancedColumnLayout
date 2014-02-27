#BalancedColumnLayout

A UICollectionViewLayout that displays your cells in a variable number of columns that fit to the bounds of the CollectionView.  Why? Cause every other layout that attempts to mimic the Pintrest waterfall layout (as this does) wants you to set the number of columns from the outside and I wanted my layout to figure that out for me so I didn't have to deal with it in the rotation logic.

## Usage

1. Copy RBCollectionViewBalancedColumnLayout .h/.m into your project
2. Set the layout on your collectionView to Custom, and set it's name to RBCollectionViewBalancedColumnLayout
3. Implement the collectionView:layout:heightForItemAtIndexPath: delegate method - if you want variable height cells

To customize the size of your cells grab the layout from the collection view and set the cellWidth property:
``` objective-c
RBCollectionViewBalancedColumnLayout * layout = (id)self.collectionView.collectionViewLayout;
layout.cellWidth = 100;
```

To make layout work with rotation invalidate it like so:
``` objective-c
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.collectionView.collectionViewLayout invalidateLayout];
}
```

####TODO

* Implement header/footer supplementary views
* Remove hardcoded top inset from layoutAttributesForItemAtIndexPath:
* Make more configurable
* Figure out how to exposed properties to IB (yeah right!)
