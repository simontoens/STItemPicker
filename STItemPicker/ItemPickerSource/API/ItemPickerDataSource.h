// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>
#import "ItemPickerContext.h"
#import "ItemPickerHeader.h"

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
 * is a leaf item that does not have any detail view.
 */
- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerContext *)context;

/**
 * The view's title; used as the view tab's title, if there is more than a single top-level
 * ItemPickerDataSource.  Also used as label in the table view header, if headerImage is 
 * implemented (see below).
 */
@property(nonatomic, strong, readonly) NSString *title;


@optional

/**
 * Return YES to display a description below each item.  Defaults to NO.
 */
@property(nonatomic, assign, readonly) BOOL itemDescriptionsEnabled;

/**
 * If enabled (see above), return array of descriptions to display below each item.  
 * Elements in the returned NSArray may be NSNull for those items that don't have a description.
 */
- (NSArray *)getItemDescriptionsInRange:(NSRange)range;

/**
 * Return YES to enable showing images next to each item.  Defaults to NO.
 */
@property(nonatomic, assign, readonly) BOOL itemImagesEnabled;

/**
 * Return the image to display next to the items in the specified range.  
 * Elements in the returned NSArray may be NSNull for those items that don't have an image.
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
 * Optional table view header image.  Returning a UIImage instance enables a header section with the image
 * on the left and default labels using the value of the "title" property (see above) as well as
 * previous selections.
 *
 * For more fine-grained control of the header, see the "header" property below.
 *
 * Defaults to nil (no header enabled).
 */
@property(nonatomic, strong, readonly) UIImage *headerImage;

/**
 * Optional table view header information.  Returning an ItemPickerHeader instance enabled a header section
 * with the specified information.
 *
 * Defaults to nil (no header enabled).
 */
@property(nonatomic, strong, readonly) ItemPickerHeader *header;

@end