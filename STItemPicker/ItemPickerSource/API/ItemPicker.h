// @author Simon Toens 03/17/13

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ItemPickerDataSource.h"

@protocol ItemPickerDelegate;

@interface ItemPicker : NSObject

/**
 * Create an item picker instance with the specified ItemPickerDataSource instances.
 * If there is more than one ItemPickerDataSource, the table views for each data source
 * will each have their own tab (using a UITabBarController).
 */
- (id)initWithDataSources:(NSArray *)dataSources;

/**
 * The underlying item picker view controller.  The easiest way to render the picker is to show it as
 * a modal view controller, for example using something like: 
 * <pre>[self.navigationController presentModalViewController:itemPicker.viewController animated:YES]</pre>
 */
@property(nonatomic, strong, readonly) UIViewController *viewController;

/**
 * This delegate receives callbacks from the picker.  Must be set.
 */
@property(nonatomic, weak) id<ItemPickerDelegate> delegate;

/**
 * If YES, display a "Done" button on the right in the navigation bar.  Defaults to NO.
 */
@property(nonatomic, assign) BOOL showDoneButton;

/**
 * The maximum number of items that can be selected in a single ItemPicker session.  If more than
 * 1, a "Done" button (see above) is added to the right in the navigation bar.  Defaults to 1.
 */
@property(nonatomic, assign) NSUInteger maxSelectableItems;

/**
 * The maximum number of items that are loaded from the data source and cached.  Defaults to 500.
 */
@property(nonatomic, assign) NSUInteger itemLoadRangeLength;

/**
 * Post this notification using NSNotificationCenter to force a UI refresh when data in the underlying data source changes.
 */
extern NSString *ItemPickerDataSourceDidChangeNotification;

@end


@protocol ItemPickerDelegate <NSObject>

/**
 * Called when a leaf item is selected from the ItemPicker's viewController.
 *
 * @param itemPickerSelections  An array, one for each selection, of ItemPickerSelection arrays.  
 * The outer array will only have multiple elements if multiSelect is enabled.
 * Within an array of ItemPickerSelection instances, the ItemPickerSelection instance at the
 * beginning (index 0) of the array represents the first selection, the instance at the end of the array 
 * represents the final leaf item selection.
 */
- (void)onItemPickerPickedItems:(NSArray *)itemPickerSelections;

@end
