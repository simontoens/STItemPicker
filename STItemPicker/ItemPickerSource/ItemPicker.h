// @author Simon Toens 03/17/13

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ItemPickerDataSource.h"

@protocol ItemPickerDelegate;

@interface ItemPicker : NSObject

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

@property (nonatomic, strong, readonly) UIViewController *viewController;

@property (nonatomic, weak) id<ItemPickerDelegate> delegate;

@end


@protocol ItemPickerDelegate <NSObject>

- (void)pickedItem:(NSString *)item;

@end