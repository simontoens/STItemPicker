// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>
#import "ItemPickerSelection.h"
#import "ItemPickerHeader.h"

/**
 * The ItemPickerDataSource Protocol encapsulates data access and behavior that drives the ItemPicker UI.
 */
@protocol ItemPickerDataSource <NSObject>


@required

/**
 * The total number of items for this ItemPicker table view.
 */
@property(nonatomic, assign, readonly) NSUInteger count;

/**
 * YES if this instance is a leaf data source, ie none of the items provided by this data source have any further 
 * detail data source.
 *
 * Note that if this property's value is YES, getNextDataSourceForSelection must return nil.
 */
@property(nonatomic, assign, readonly) BOOL isLeaf;

/**
 * Returns the items to display in the ItemPicker table view.  Must return a non-nil NSArray of NSString instances.
 * 
 * @param range  The items returned must be in the specified range.  The largest possible range asked for is [0, count-1].
 */
- (NSArray *)getItemsInRange:(NSRange)range;

/**
 * Called when an item is selected.  Return the data source for the next table view, or nil if this 
 * is a leaf item that does not have any detail view.
 *
 * @param selection  The current selection
 * @param previousSelections  ItemPickerContext instances for previous selections.  The oldest selection is at index 0
 */
- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerSelection *)selection 
                                       previousSelections:(NSArray *)previousSelections;

/**
 * The view's title; used as the view tab's title, if there is more than a single top-level
 * ItemPickerDataSource.  Also used as default header label, if the header property's value
 * returns an ItemPickerHeader instance.
 */
@property(nonatomic, strong, readonly) NSString *title;



@optional

/**
 * Called before any other methods for the specified range.
 */
- (void)initForRange:(NSRange)range;

/**
 * Return array of descriptions to display below each item; elements in the returned NSArray may be NSNull for 
 * those items that don't have a description.  Return nil if descriptions are not enabled.
 */
- (NSArray *)getItemDescriptionsInRange:(NSRange)range;

/**
 * Return the image to display next to the items in the specified range; elements in the returned NSArray may be NSNull 
 * for those items that don't have an image.  Return nil if images are not enabled.
 */
- (NSArray *)getItemImagesInRange:(NSRange)range;

/**
 * Return ItemAttributes instances to tweak the appearance of each table view cell.  Elements in the returned NSArray 
 * may be NSNull for those items that should use the default item attributes.  Return nil to not apply any attributes.
 */
- (NSArray *)getItemAttributesInRange:(NSRange)range;

/**
 * Return YES to show section headers and a section index.  Defaults to NO.
 * The items will be sorted and sections will be calculated, unless sections are explicitly specified.
 */
@property(nonatomic, assign, readonly) BOOL sectionsEnabled;

/**
 * Return an array of instances that have title and range properties (the same properties as MPMediaQuerySection has),
 * _if_ this DataSource wants to use its own logic to determine section names.
 * If this method returns sections to use, they must match the items and the items will not be sorted or otherwise modified.
 */
@property(nonatomic, strong, readonly) NSArray *sections;

/**
 * Optional image to display in the tab, if there is more than a single top-level ItemPickerDataSource.
 */
@property(nonatomic, strong, readonly) UIImage *tabImage;

/**
 * If items for this data source have a single element, automatically select it.  Defaults to NO.
 */
@property(nonatomic, assign, readonly) BOOL autoSelectSingleItem;

/**
 * Table view header information.  Returning an ItemPickerHeader instance enables a header section
 * with the specified information.
 *
 * Defaults to nil (no header enabled).
 */
@property(nonatomic, strong, readonly) ItemPickerHeader *header;

/**
 * A fake, non-selectable item to show when this datasource does not have any items, for example "No cities found".
 * Defauls to nil (don't show anything if this datasource does not have any items).
 */
@property(nonatomic, strong, readonly) NSString *noItemsItemText;

/**
 * If not nil, add an extra first cell to the table view with this title.  When this cell is selected, 
 * the ItemPickerSelection instance in the getNextDataSourceForSelection callback
 * has the "metaCell" property set to YES.  This can be used to implement functionalty
 * such as the Music.app's "All Songs" special cell.
 * 
 * Defaults to nil.
 */
@property(nonatomic, strong, readonly) NSString *metaCellTitle;

/**
 * The description for the metaCell.
 *
 * Defaults to nil.
 */
@property(nonatomic, strong, readonly) NSString *metaCellDescription;

@end