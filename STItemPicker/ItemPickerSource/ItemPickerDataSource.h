// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>

/**
 * The ItemPickerDataSource Protocol encapsulates data access and behavior that drives the ItemPicker UI.
 * 
 * The ItemPicker code ensures that properties are not referenced multiple times unecessarily.
 */
@protocol ItemPickerDataSource <NSObject>


@required

/**
 * The items displayed in the table view.  Must return a non-empty array.
 */
@property(nonatomic, strong, readonly) NSArray *items;

/**
 * Called when an item is selected.  Return the data source for the next table view, or nil if this 
 * item does not have any detail.
 */
- (id<ItemPickerDataSource>)getNextDataSourceForSelectedRow:(NSUInteger)row selectedItem:(NSString *)item;

/**
 * The view's title and the tab's title.  Must return a valid value.
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
 * Optional images to display next to each item.  The length of the returned NSArray
 * must have the same length as the items NSArray.  Elements in the returned NSArray
 * may be NSNull for those items that don't have an image.
 */
@property(nonatomic, strong, readonly) NSArray *itemImages;

/**
 * Optional table view header image, return nil if no header image.
 */
@property(nonatomic, strong, readonly) UIImage *headerImage;

/**
 * Optional image to display in the tab.
 */
@property(nonatomic, assign, readonly) UIImage *tabImage;

/**
 * If items for this data source have a single element, automatically select it.  Defaults to NO.
 */
@property(nonatomic, assign, readonly) BOOL autoSelectSingleItem;

@end