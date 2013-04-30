// @author Simon Toens 03/31/13

#import <Foundation/Foundation.h>
#import "TableViewCell.h"

@interface TableViewCellContainer : NSObject

+ (TableViewCell *)newPlainTableViewCell;
+ (NSString *)plainTableViewCellIdentifier;

+ (TableViewCell *)newImageTableViewCell;
+ (NSString *)imageTableViewCellIdentifier;

@end