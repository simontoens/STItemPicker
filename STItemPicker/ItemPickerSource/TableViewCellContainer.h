// @author Simon Toens 03/31/13

#import <Foundation/Foundation.h>
#import "ItemPickerCell.h"

@interface TableViewCellContainer : NSObject

+ (ItemPickerCell *)newCellForTableView:(UITableView *)tableView image:(UIImage *)image description:(NSString *)description;

@end