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

- (NSUInteger)count
{
    return self.dataSource.count;
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [self.dataSource getItemsInRange:range];
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerContext *)context
{
    id<ItemPickerDataSource> nextDataSource = [self.dataSource getNextDataSourceForSelection:context];
    return nextDataSource ? [[ItemPickerDataSourceDefaults alloc] initWithDataSource:nextDataSource] : nil;
}

- (NSString *)title
{
    return self.dataSource.title;
}

- (BOOL)itemDescriptionsEnabled
{
    return [self.dataSource respondsToSelector:@selector(itemDescriptionsEnabled)] ? self.dataSource.itemDescriptionsEnabled : NO;
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    return [self.dataSource respondsToSelector:@selector(getItemDescriptionsInRange:)] ? [self.dataSource getItemDescriptionsInRange:range] : nil;
}

- (UIImage *)headerImage
{
    return [self.dataSource respondsToSelector:@selector(headerImage)] ? self.dataSource.headerImage : nil;
}

- (BOOL)itemImagesEnabled
{
    return [self.dataSource respondsToSelector:@selector(itemImagesEnabled)] ? self.dataSource.itemImagesEnabled : NO;
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    return [self.dataSource respondsToSelector:@selector(getItemImagesInRange:)] ? [self.dataSource getItemImagesInRange:range]  : nil;
}

- (BOOL)sectionsEnabled
{
    return [self.dataSource respondsToSelector:@selector(sectionsEnabled)] ? self.dataSource.sectionsEnabled : NO;
}

- (NSArray *)sections
{
    return [self.dataSource respondsToSelector:@selector(sections)] ? self.dataSource.sections : nil;
}

- (UIImage *)tabImage
{
    return [self.dataSource respondsToSelector:@selector(tabImage)] ? self.dataSource.tabImage : nil;
}

- (BOOL)autoSelectSingleItem
{
    return [self.dataSource respondsToSelector:@selector(autoSelectSingleItem)] ? self.dataSource.autoSelectSingleItem : NO;
}

@end