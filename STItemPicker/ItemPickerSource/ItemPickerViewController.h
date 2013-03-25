// @author Simon Toens 12/14/12

#import <UIKit/UIKit.h>

#import "ItemPicker.h"
#import "ItemPickerDataSource.h"

@interface ItemPickerViewController : UITableViewController

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

@property (nonatomic, weak) id<ItemPickerDelegate>itemPickerDelegate;

@end