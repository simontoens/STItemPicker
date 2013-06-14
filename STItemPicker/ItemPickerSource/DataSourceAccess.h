// @author Simon Toens 05/16/13 on the way to KIX

#import <Foundation/Foundation.h>
#import "ItemAttributes.h"
#import "ItemPickerSelection.h"
#import "ItemPickerDataSource.h"
#import "ItemPickerHeader.h"

/**
 * All data source access goes through this class.  Encapsulates how we ask for data.
 */
@interface DataSourceAccess : NSObject

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

- (NSUInteger)getCount;

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

- (id<ItemPickerDataSource>)getDataSource;

@end