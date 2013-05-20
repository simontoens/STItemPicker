// @author Simon Toens 05/16/13 on the way to KIX

#import <Foundation/Foundation.h>
#import "ItemPickerContext.h"
#import "ItemPickerDataSource.h"

/**
 * Provides access to data exposed by an ItemPickerDataSource in a TableView friendly format.
 */
@interface DataSourceAccess : NSObject

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource;

- (id)getSection:(NSUInteger)index;

- (NSString *)getItem:(NSIndexPath *)indexPath;

- (NSString *)getItemDescription:(NSIndexPath *)indexPath;

- (UIImage *)getItemImage:(NSIndexPath *)indexPath;

- (NSArray *)getSectionTitles;

- (ItemPickerContext *)getItemPickerContext:(NSIndexPath *)indexPath autoSelected:(BOOL)autoSelected;

@end