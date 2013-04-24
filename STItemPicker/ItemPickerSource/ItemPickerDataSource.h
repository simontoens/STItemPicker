// @author Simon Toens 03/16/13

#import <Foundation/Foundation.h>

/**
 * The ItemPickerDataSource Protocol encapsulates data access to the data that drives the ItemPicker UI.
 * 
 * Many of the properties are optional.
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
 * Return YES if items are sorted alphanumerically, NO otherwise.
 */
@property(nonatomic, assign, readonly) BOOL itemsAlreadySorted;

/**
 * Optional table view header image, return nil if no header image.
 */
@property(nonatomic, strong, readonly) UIImage *headerImage;

/**
 * Optional images to display next to each item.  The length of the returned NSArray
 * must have the same length as the items NSArray.  Elements in the returned NSArray
 * may be NSNull for those items that don't have an image.  Return nil if 
 * there aren't any images to display for any items.
 */
@property(nonatomic, strong, readonly) NSArray *itemImages;

/**
 * Return YES to show section headers and a section index.
 */
@property(nonatomic, assign, readonly) BOOL sectionsEnabled;

/**
 * Return YES to skip intermediary item lists with only a single item.
 */
@property(nonatomic, assign, readonly) BOOL skipIntermediaryLists;

/**
 * The image to display in the tab, nil for no image.
 */
@property(nonatomic, assign, readonly) UIImage *tabImage;

@end