// @author Simon Toens 05/16/13 on the way to KIX

#import <Foundation/Foundation.h>
#import "ItemAttributes.h"
#import "ItemCache.h"
#import "ItemPickerSelection.h"
#import "ItemPickerDataSource.h"
#import "ItemPickerHeader.h"

/**
 * This class is layered between the data source providing raw data and the clients (UI) accessing the data.
 * It translates data shapes and provides caching.
 */
@interface DataSourceAccess : NSObject

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource autoSelected:(BOOL)autoSelected;

/**
 * Returns the number of items provided by the underlying data source, excluding meta items (ie "no data found").
 */
- (NSUInteger)getDataSourceItemCount;

- (BOOL)isLeaf;

- (NSString *)getTitle;

- (UIImage *)getTabImage;

- (ItemPickerHeader *)getHeader;

- (id)getSection:(NSUInteger)index;

- (NSString *)getItem:(NSIndexPath *)indexPath;

- (NSString *)getItemDescription:(NSIndexPath *)indexPath;

- (UIImage *)getItemImage:(NSIndexPath *)indexPath;

- (ItemAttributes *)getItemAttributes:(NSIndexPath *)indexPath;

- (NSArray *)getSectionTitles;

- (ItemPickerSelection *)getItemPickerSelection:(NSIndexPath *)indexPath;

- (BOOL)getSectionsEnabled;

- (id<ItemPickerDataSource>)getDataSource;

/**
 * Notifies this instance that the data provided by the underlying data source has changed, and needs to be reloaded.
 */
- (void)reloadData;

@property(nonatomic) NSUInteger itemCacheSize;

@end