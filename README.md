#BalancedColumnLayout

A UICollectionViewLayout that displays your cells in columns (i.e. how Pintrest lays out it's views).  Why, cause I wanted to learn how to do it, and I didn't like the implementations of any of the ones I had found online.

## Usage

1. Copy RBCollectionViewBalancedColumnLayout .h/.m into your project
2. Set the layout on your collectionView to Custom, and set it's name to RBCollectionViewBalancedColumnLayout
3. Implement the collectionView:layout:sizeForItemAtIndexPath: delegate method
4. Run - if you want the default of 300pt wide cells (i.e. 1 column for iPhone portrait/landscape, 2 for iPad portrait, 3 for iPad landscape)

To customize the size of your cells grab the layout from the collection view and set the cellWidth property.

####TODO

* Create our own protocol instead of piggybacking on the UICollectionViewFlowLayoutDelegate protocol
* Implement header/footer supplementary views
* Remove hardcoded top inset from layoutAttributesForItemAtIndexPath:
* Make more configurable
* Figure out how to exposed properties to IB (yeah right!)