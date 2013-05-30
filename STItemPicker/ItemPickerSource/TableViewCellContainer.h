// @author Simon Toens 03/31/13

#import <Foundation/Foundation.h>
#import "ItemAttributes.h"
#import "ItemPickerCell.h"

@interface TableViewCellContainer : NSObject

+ (ItemPickerCell *)newCellForTableView:(UITableView *)tableView
                                   text:(NSString *)text
                                  image:(UIImage *)image 
                            description:(NSString *)description
                         itemAttributes:(ItemAttributes *)itemAttributes;

@end