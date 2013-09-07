// @author Simon Toens 09/06/13 on the train to Vancouver

#import <Foundation/Foundation.h>
#import "ItemPickerDataSourceDefaults.h"
#import "ItemPickerDataSource.h"

/**
 * DataSource used when the 'real' data source doesn't have any items but wants to show a default item message.
 */
@interface NoItemsDataSource : ItemPickerDataSourceDefaults <ItemPickerDataSource>

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

@end