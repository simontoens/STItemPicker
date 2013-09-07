// @author Simon Toens 09/06/13 on the train to Vancouver

#import "ItemAttributes.h"
#import "NoItemsDataSource.h"
#import "Preconditions.h"

@implementation NoItemsDataSource

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    [Preconditions assert:dataSource.noItemsItemText != nil && dataSource.count == 0 message:@"Bad delegate data source"];
    return [super initWithDataSource:dataSource];
}

- (NSUInteger)count
{
    return 1;
}

- (NSArray *)getItemsInRange:(NSRange)range
{
    return [NSArray arrayWithObject:self.dataSource.noItemsItemText];
}

- (NSArray *)getItemDescriptionsInRange:(NSRange)range
{
    return nil;
}

- (NSArray *)getItemImagesInRange:(NSRange)range
{
    return nil;
}

- (NSArray *)getItemAttributesInRange:(NSRange)range
{
    ItemAttributes *attributes = [[ItemAttributes alloc] init];
    attributes.userInteractionEnabled = NO;
    return [NSArray arrayWithObject:attributes];
}

- (NSString *)noItemsItemText
{
    return nil;
}

@end