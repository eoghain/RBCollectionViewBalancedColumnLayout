#BalancedColumnLayout

A UICollectionViewLayout that displays your cells in a variable number of columns that fit to the bounds of the CollectionView.  Why? Cause every other layout that attempts to mimic the Pintrest waterfall layout (as this does) wants you to set the number of columns from the outside and I wanted my layout to figure that out for me so I didn't have to deal with it in the rotation logic.  Also I wanted a single layout setup for iPhone and iPad resolutions, and whatever comes next.

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

## Screenshots

#### Landscape
<p align="center">
<img src="https://raw.github.com/eoghain/RBCollectionViewBalancedColumnLayout/master/Images/landscape.png" alt="Landscape" title="Screenshot 5" height="600">
</p>
#### Rotating
<p align="center">
<img src="https://raw.github.com/eoghain/RBCollectionViewBalancedColumnLayout/master/Images/rotation.png" alt="Rotating" title="Screenshot 2" height="600">
</p>
#### Portrait
<p align="center">
<img src="https://raw.github.com/eoghain/RBCollectionViewBalancedColumnLayout/master/Images/portrait.png" alt="Portrait" title="Screenshot 2" height="600">
</p>

>Data provided by Marvel. © 2014 Marvel


####TODO

- [ ] Make more configurable
- [x] Replace Flowlayout delegate with our own
- [x] Implement header/footer supplementary views 
- [x] Make header views sticky like UITableView section headers
