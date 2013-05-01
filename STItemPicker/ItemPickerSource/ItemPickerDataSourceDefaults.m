// @author Simon Toens 04/22/13

#import "ItemPickerDataSourceDefaults.h"

@interface ItemPickerDataSourceDefaults()
@property (nonatomic, strong) id<ItemPickerDataSource> dataSource;
@end

@implementation ItemPickerDataSourceDefaults

@synthesize dataSource = _dataSource;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (self = [super init])
    {
        _dataSource = dataSource;
    }
    return self;
}

- (NSArray *)items
{
    return self.dataSource.items;
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelectedRow:(NSUInteger)row selectedItem:(NSString *)item
{
    id<ItemPickerDataSource> nextDataSource = [self.dataSource getNextDataSourceForSelectedRow:row selectedItem:item];
    return nextDataSource ? [[ItemPickerDataSourceDefaults alloc] initWithDataSource:nextDataSource] : nil;
}

- (NSString *)title
{
    return self.dataSource.title;
}

- (BOOL)itemsAlreadySorted
{
    return [self.dataSource respondsToSelector:@selector(itemsAlreadySorted)] ? self.dataSource.itemsAlreadySorted : NO;
}

- (UIImage *)headerImage
{
    return [self.dataSource respondsToSelector:@selector(headerImage)] ? self.dataSource.headerImage : nil;
}

- (NSArray *)itemImages
{
    return [self.dataSource respondsToSelector:@selector(itemImages)] ? self.dataSource.itemImages : nil;
}

- (BOOL)sectionsEnabled
{
    return [self.dataSource respondsToSelector:@selector(sectionsEnabled)] ? self.dataSource.sectionsEnabled : NO;
}

- (UIImage *)tabImage
{
    return [self.dataSource respondsToSelector:@selector(tabImage)] ? self.dataSource.tabImage : nil;
}

@end