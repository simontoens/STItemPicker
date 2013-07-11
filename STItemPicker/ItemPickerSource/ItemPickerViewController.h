// @author Simon Toens 12/14/12

#import <UIKit/UIKit.h>

#import "ItemPicker.h"
#import "ItemPickerContext.h"
#import "ItemPickerDataSource.h"

@interface ItemPickerViewController : UITableViewController

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource itemPickerContext:(ItemPickerContext *)itemPickerContext;

@property(nonatomic, assign) BOOL showDoneButton;
@property(nonatomic, assign) NSUInteger maxSelectableItems;

@property(nonatomic, weak) id<ItemPickerDelegate>itemPickerDelegate;

@end