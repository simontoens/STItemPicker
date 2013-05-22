// @author Simon Toens 03/30/13

#import "ItemPickerContext.h"
#import "Preconditions.h"

@implementation ItemPickerContext

@synthesize dataSource = _dataSource;
@synthesize autoSelected, selectedIndex, selectedItem;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource 
{
    if (self = [super init]) 
    {
       [Preconditions assertNotNil:dataSource message:@"datasource cannot be nil"];
        _dataSource = dataSource;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if (![object isKindOfClass:[ItemPickerContext class]])
    {
        return NO;
    }
    ItemPickerContext *other = (ItemPickerContext *)object;
    return self.selectedIndex == other.selectedIndex && [self.selectedItem isEqualToString:other.selectedItem];
}

- (NSUInteger)hash 
{
    int prime = 31;
    int result = prime + selectedIndex;
    result = prime * result + [self.selectedItem hash];
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    ItemPickerContext *copy = [[ItemPickerContext alloc] initWithDataSource:self.dataSource];
    copy.autoSelected = self.autoSelected;
    copy.selectedIndex = self.selectedIndex;
    copy.selectedItem = [self.selectedItem copyWithZone:zone];
    return copy;
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@ %i %@", self.dataSource, self.selectedIndex, self.selectedItem];
}

@end