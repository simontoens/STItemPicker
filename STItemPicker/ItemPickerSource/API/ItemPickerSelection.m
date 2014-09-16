// @author Simon Toens 03/30/13

#import "ItemPickerSelection.h"
#import "Preconditions.h"

@implementation ItemPickerSelection

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource 
           selectedIndex:(NSUInteger)selectedIndex
            selectedItem:(NSString *)selectedItem
            autoSelected:(BOOL)autoSelected
                metaCell:(BOOL)metaCell
{
    if (self = [super init]) 
    {
       [Preconditions assertNotNil:dataSource message:@"datasource cannot be nil"];
        _autoSelected = autoSelected;
        _dataSource = dataSource;
        _metaCell = metaCell;
        _selectedIndex = selectedIndex;
        _selectedItem = selectedItem;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if (![object isKindOfClass:[ItemPickerSelection class]])
    {
        return NO;
    }
    ItemPickerSelection *other = (ItemPickerSelection *)object;
    return self.selectedIndex == other.selectedIndex && [self.selectedItem isEqualToString:other.selectedItem];
}

- (NSUInteger)hash 
{
    NSUInteger prime = 31;
    NSUInteger result = prime + self.selectedIndex;
    result = prime * result + [self.selectedItem hash];
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[ItemPickerSelection alloc] initWithDataSource:self.dataSource 
                                             selectedIndex:self.selectedIndex 
                                              selectedItem:[self.selectedItem copyWithZone:zone] 
                                              autoSelected:self.autoSelected
                                                  metaCell:self.metaCell];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@ %lu %@", self.dataSource, (unsigned long)self.selectedIndex, self.selectedItem];
}

@end