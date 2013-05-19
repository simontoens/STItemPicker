// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>
#import "ItemPickerContext.h"

/**
 * The ItemPickerDataSource Protocol encapsulates data access and behavior that drives the ItemPicker UI.
 */
@protocol ItemPickerDataSource <NSObject>


@required

/**
 * The total number of items for this ItemPicker TableView.
 */
@property(nonatomic, assign, readonly) NSUInteger count;

/**
 * The items in the specified range.  Must return a non-nil, non-empty array.
 */
- (NSArray *)getItemsInRange:(NSRange)range;

/**
 * Called when an item is selected.  Return the data source for the next table view, or nil if this 
 * item does not have any detail.
 */
- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerContext *)context;

/**
 * The view's title and tab's title.  Must return a valid value.
 */
@property(nonatomic, strong, readonly) NSString *title;


@optional

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
 * Return YES to enable showing images next to each item.  Defaults to NO.
 */
@property(nonatomic, assign) BOOL itemImagesEnabled;

/**
 * Return the image to display next to the items in the specified range.  Elements in the returned NSArray
 * may be NSNull for those items that don't have an image.
 */
- (NSArray *)getItemImagesInRange:(NSRange)range;

/**
 * Optional table view header image, return nil if no header image.
 */
@property(nonatomic, strong, readonly) UIImage *headerImage;

/**
 * Optional image to display in the tab.
 */
@property(nonatomic, strong, readonly) UIImage *tabImage;

/**
 * If items for this data source have a single element, automatically select it.  Defaults to NO.
 */
@property(nonatomic, assign, readonly) BOOL autoSelectSingleItem;

@end