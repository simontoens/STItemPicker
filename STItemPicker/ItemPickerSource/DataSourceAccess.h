// @author Simon Toens 05/16/13 on the way to KIX

#import <Foundation/Foundation.h>
#import "ItemAttributes.h"
#import "ItemCache.h"
#import "ItemPickerSelection.h"
#import "ItemPickerDataSource.h"
#import "ItemPickerHeader.h"

/**
 * All data source access goes through this class.  It translates between the data shape provided by the 
 * data source and the data shape required by the ItemPicker UI.
 */
@interface DataSourceAccess : NSObject

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

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

- (ItemPickerSelection *)getItemPickerContext:(NSIndexPath *)indexPath autoSelected:(BOOL)autoSelected;

- (BOOL)getSectionsEnabled;

- (id<ItemPickerDataSource>)getDataSource;

@property(nonatomic, strong, readonly) ItemCache *itemCache;

@end