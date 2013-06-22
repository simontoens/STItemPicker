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
 * YES if this instance is a leaf data source, ie all items provided by this data source are selectable
 * and none of them has any further detail data source.
 *
 * If this property's value is YES, getNextDataSourceForSelection must return nil and vice-versa; if this 
 * property's value is NO, then getNextDataSourceForSelection must return a valid data source instance.
 */
@property(nonatomic, assign, readonly) BOOL isLeaf;

/**
 * The items in the specified range.  Must return a non-nil array.
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
 * Return YES to show section headers and a section index.  Defaults to NO.
 * The items will be sorted and sections will be calculated, unless sections are explicitly specified.
 */
@property(nonatomic, assign, readonly) BOOL sectionsEnabled;

/**
 * Return an array of instances that have title and range properties (the same properties as MPMediaQuerySection has),
 * _if_ this DataSource wants to use its own logic to determine section names.
 * If this method returns sections to use, they must match the items; if this method returns a non nil value, the items
 * will not be sorted or otherwise modified.
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
 * Optional table view header information.  Returning an ItemPickerHeader instance enables a header section
 * with the specified information.
 *
 * Defaults to nil (no header enabled).
 */
@property(nonatomic, strong, readonly) ItemPickerHeader *header;

/**
 * Optional attributes to tweak the appearance of each table view cell.
 */
- (NSArray *)getItemAttributesInRange:(NSRange)range;

@end