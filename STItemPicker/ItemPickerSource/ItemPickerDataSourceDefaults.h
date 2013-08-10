// @author Simon Toens 04/22/13

#import <Foundation/Foundation.h>
#import "ItemPickerDataSource.h"

/**
 * Default values for ItemPickerDataSource's optional methods and properties.
 */
@interface ItemPickerDataSourceDefaults : NSObject <ItemPickerDataSource>

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

@property (nonatomic, strong) id<ItemPickerDataSource> dataSource;

@end