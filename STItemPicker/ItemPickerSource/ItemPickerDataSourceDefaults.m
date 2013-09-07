// @author Simon Toens 04/22/13

#import "ItemPickerDataSourceDefaults.h"

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

- (BOOL)isLeaf
{
    return self.dataSource.isLeaf;
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [self.dataSource getItemsInRange:range];
}

- (id<ItemPickerDataSource>)getNextDataSourceForSelection:(ItemPickerSelection *)context 
                                       previousSelections:(NSArray *)selections
{
    id<ItemPickerDataSource> nextDataSource = [self.dataSource getNextDataSourceForSelection:context previousSelections:selections];
    return nextDataSource ? [[ItemPickerDataSourceDefaults alloc] initWithDataSource:nextDataSource] : nil;
}

- (NSString *)title
{
    return self.dataSource.title;
}

- (void)initForRange:(NSRange)range
{
    if ([self.dataSource respondsToSelector:@selector(initForRange:)])
    {
        [self.dataSource initForRange:range];
    }
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    return [self.dataSource respondsToSelector:@selector(getItemDescriptionsInRange:)] ? [self.dataSource getItemDescriptionsInRange:range] : nil;
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

- (NSArray *)getItemAttributesInRange:(NSRange)range
{
    return [self.dataSource respondsToSelector:@selector(getItemAttributesInRange:)] ? [self.dataSource getItemAttributesInRange:range] : nil;
}

- (ItemPickerHeader *)header
{
    return [self.dataSource respondsToSelector:@selector(header)] ? self.dataSource.header : nil;
}

- (NSString *)noItemsItemText
{
    return [self.dataSource respondsToSelector:@selector(noItemsItemText)] ? self.dataSource.noItemsItemText : nil;
}

- (NSString *)metaCellTitle
{
    return [self.dataSource respondsToSelector:@selector(metaCellTitle)] ? self.dataSource.metaCellTitle : nil;
}

@end