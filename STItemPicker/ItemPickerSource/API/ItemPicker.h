// @author Simon Toens 03/17/13

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ItemPickerDataSource.h"

@protocol ItemPickerDelegate;

@interface ItemPicker : NSObject

- (id)initWithDataSources:(NSArray *)dataSource;

@property(nonatomic, strong, readonly) UIViewController *viewController;

/**
 * This delegate receives callbacks from the picker.  Must be set.
 */
@property(nonatomic, weak) id<ItemPickerDelegate> delegate;

/**
 * If YES, show a "Cancel" button on the right in the navigation bar.  Defaults to NO.
 */
@property(nonatomic, assign) BOOL showCancelButton;

/**
 * The maximum number of items that can be selected in a single ItemPicker "session".  If more than
 * 1, a "Done" button is added to the right in the navigation bar.  Defaults to 1.
 */
@property(nonatomic, assign) NSUInteger maxSelectableItems;

@end

@protocol ItemPickerDelegate <NSObject>

/**
 * Called when a leaf item is selected from the ItemPicker's viewController.
 *
 * @param pickedItemContexts  An array, one for each selection, of ItemPickerContext arrays.  
 * The outer array will only have multiple elements if multiSelect is enabled.
 * Within an ItemPickerContext array, the ItemPickerContext instance at the
 * beginning of the array represents the first selection, the instance at the end of the array 
 * represents the final "leaf item" selection.
 */
- (void)onPickItems:(NSArray *)pickedItemContexts;

/**
 * Callback for the cancel button, if enabled (see showCancelButton above).
 */
- (void)onCancel;

@end