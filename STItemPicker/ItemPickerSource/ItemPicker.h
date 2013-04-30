// @author Simon Toens 03/17/13

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ItemPickerDataSource.h"

@protocol ItemPickerDelegate;

@interface ItemPicker : NSObject

- (id)initWithDataSources:(NSArray *)dataSource;

@property (nonatomic, strong, readonly) UIViewController *viewController;

/**
 * This delegate receives callbacks from the picker.  Must be set.
 */
@property (nonatomic, weak) id<ItemPickerDelegate> delegate;

/**
 * Whether to show a cancel button on the right of the navigation bar.  Defaults to NO.
 */
@property (nonatomic, assign) BOOL showCancelButton;

@end

@protocol ItemPickerDelegate <NSObject>

- (void)onPickItem:(NSString *)item atIndex:(NSUInteger)index;

- (void)onCancel;

@end