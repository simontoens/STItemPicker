// @author Simon Toens 05/16/13 on the way to KIX

#import <Foundation/Foundation.h>
#import "ItemAttributes.h"
#import "ItemCache.h"
#import "ItemPickerSelection.h"
#import "ItemPickerDataSource.h"
#import "ItemPickerHeader.h"

/**
 * Layer of functionality between the datasource and the UI. 
 * All data source access goes through this class.  It translates between the datasource data shape 
 * and the data shape required by the ItemPicker UI, provides item caching, etc.
 */
@interface DataSourceAccess : NSObject

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource autoSelected:(BOOL)autoSelected;

- (NSUInteger)getCount;

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

- (ItemPickerSelection *)getItemPickerSelection:(NSIndexPath *)indexPath autoSelected:(BOOL)autoSelected;

- (BOOL)getSectionsEnabled;

- (id<ItemPickerDataSource>)getDataSource;

- (BOOL)selectedShowAllItems:(ItemPickerSelection *)selection;

@property(nonatomic, strong, readonly) ItemCache *itemCache;

@end