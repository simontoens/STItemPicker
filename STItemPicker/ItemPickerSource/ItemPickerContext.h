// @author Simon Toens 03/30/13

#import <Foundation/Foundation.h>
#import "ItemPickerDataSource.h"

@interface ItemPickerContext : NSObject

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

@property (nonatomic, strong, readonly) id<ItemPickerDataSource>dataSource;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) NSString *selectedItem;

@end