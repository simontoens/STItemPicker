// @author Simon Toens 07/14/13

#import <OCMock/OCMock.h>
#import <SenTestingKit/SenTestingKit.h>
#import "ItemCache.h"
#import "ItemPickerDataSource.h"

@interface ItemCacheTest : SenTestCase
{
    @private
    id dataSource;
    ItemCache *itemCache;
}

@end

@implementation ItemCacheTest

- (void)setUp
{
    [super setUp];
    dataSource = [OCMockObject mockForProtocol:@protocol(ItemPickerDataSource)];
    itemCache = [[ItemCache alloc] initForDataSource:dataSource];
}

- (void)assertItemsAreCachedAtStartIndex:(NSUInteger)startIndex
{
    for (int i = startIndex; i < startIndex + itemCache.size; i++)
    {
        STAssertEquals([itemCache ensureAvailability:i], (NSUInteger)i - startIndex, @"Bad index returned");
        [dataSource verify];      
    }
}

- (void)testCacheSizeHigherThanItemCount
{
    int itemCount = 5;
    itemCache.size = 10;
    
    [self mockDataSourceForRange:NSMakeRange(0, itemCount) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:0], (NSUInteger)0, @"Bad index returned");
    [dataSource verify];

    // cached, nothing should be called on data source
    STAssertEquals([itemCache ensureAvailability:0], (NSUInteger)0, @"Bad index returned");
    [dataSource verify];
    
    // cached, nothing should be called on data source
    STAssertEquals([itemCache ensureAvailability:4], (NSUInteger)4, @"Bad index returned");
    [dataSource verify];
    
    // cached, nothing should be called on data source
    STAssertEquals([itemCache ensureAvailability:2], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];
}

- (void)testCacheSizeLowerThanItemCount
{
    int itemCount = 11;
    itemCache.size = 4;
    
    [self mockDataSourceForRange:NSMakeRange(0, 4) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:0], (NSUInteger)0, @"Bad index returned");
    [dataSource verify];
    [self assertItemsAreCachedAtStartIndex:0];

    // cache has 0,1,2,3, keep 2,3 load 4,5
    [self mockDataSourceForRange:NSMakeRange(4, 2) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:4], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:2];    
    
    // cache has 2,3,4,5, keep 4,5 load 6,7
    [self mockDataSourceForRange:NSMakeRange(6, 2) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:6], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:4];

    // cache has 4,5,6,7 keep 6,7 load 8,9
    [self mockDataSourceForRange:NSMakeRange(8, 2) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:8], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:6];
    
    // cache has 6,7,8,9
    // only one item left at index 10 - cache only needs to load that single item 
    // cache should have the last <cache size> items
    [self mockDataSourceForRange:NSMakeRange(10, 1) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:10], (NSUInteger)3, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:7];
    
    // going backwards - datasource will get asked for items on the lower side
    // index 6 has not been loaded yet - index 7 remains in the cache - need to load 4,5,6
    [self mockDataSourceForRange:NSMakeRange(4, 3) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:6], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:4];
    
    // cache has 4,5,6,7, get index 3, load 1,2,3 keep 4
    [self mockDataSourceForRange:NSMakeRange(1, 3) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:3], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:1];
    
    // cache has 1,2,3,4 get index 0, load 0, keep 1,2,3
    [self mockDataSourceForRange:NSMakeRange(0, 1) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:0], (NSUInteger)0, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:0];
    
    // jump around - go to index 9 cache loads 7,8,9,10
    [self mockDataSourceForRange:NSMakeRange(7, 4) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:9], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:7];
    
    // jump around - go to index 1 cache loads 0,1,2,3
    [self mockDataSourceForRange:NSMakeRange(0, 4) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:1], (NSUInteger)1, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:0];
    
    // jump around - go to index 9 cache loads 7,8,9,10
    [self mockDataSourceForRange:NSMakeRange(7, 4) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:9], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:7];
    
    // jump around - go to index 2 cache loads 0,1,2,3
    [self mockDataSourceForRange:NSMakeRange(0, 4) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:2], (NSUInteger)2, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:0];
    
    // jump around - go to index 10 cache loads 7,8,9,10
    [self mockDataSourceForRange:NSMakeRange(7, 4) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:10], (NSUInteger)3, @"Bad index returned");
    [dataSource verify];    
    [self assertItemsAreCachedAtStartIndex:7];
}

- (void)testCacheBoundariesLeft
{
    int itemCount = 11;
    itemCache.size = 3;
    
    // index 8: cache loads 7,8,9
    [self mockDataSourceForRange:NSMakeRange(7, 3) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:8], (NSUInteger)1, @"Bad index returned");
    [dataSource verify];
    [self assertItemsAreCachedAtStartIndex:7];
    
    // index 6: cache loads 5,6
    [self mockDataSourceForRange:NSMakeRange(5, 2) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:6], (NSUInteger)1, @"Bad index returned");
    [dataSource verify];
    [self assertItemsAreCachedAtStartIndex:5];
    
    // index 3: cache loads 2,3,4
    [self mockDataSourceForRange:NSMakeRange(2, 3) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:3], (NSUInteger)1, @"Bad index returned");
    [dataSource verify];
    [self assertItemsAreCachedAtStartIndex:2];
}

- (void)testCacheBoundariesRight
{
    int itemCount = 11;
    itemCache.size = 3;
    
    // index 3: cache loads 2,3,4
    [self mockDataSourceForRange:NSMakeRange(2, 3) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:3], (NSUInteger)1, @"Bad index returned");
    [dataSource verify];
    [self assertItemsAreCachedAtStartIndex:2];
    
    // index 5: cache loads 5,6
    [self mockDataSourceForRange:NSMakeRange(5, 2) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:5], (NSUInteger)1, @"Bad index returned");
    [dataSource verify];
    [self assertItemsAreCachedAtStartIndex:4];
    
    // index 8: cache loads 7,8,9
    [self mockDataSourceForRange:NSMakeRange(7, 3) itemCount:itemCount];
    STAssertEquals([itemCache ensureAvailability:8], (NSUInteger)1, @"Bad index returned");
    [dataSource verify];
    [self assertItemsAreCachedAtStartIndex:7];
}

- (void)testCachedItems
{
    int itemCount = 11;
    itemCache.size = 4;
    
    NSArray *items = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", nil];
    [self mockDataSourceForRange:NSMakeRange(0, 4) items:items itemCount:itemCount];
    [itemCache ensureAvailability:0];
    [dataSource verify];
    
    // now cache has 0, 1, 2, 3

    items = [NSArray arrayWithObjects:@"4", @"5", nil];
    [self mockDataSourceForRange:NSMakeRange(4, 2) items:items itemCount:itemCount];
    [itemCache ensureAvailability:4];
    [dataSource verify];
    
    // now cache has 2, 3, 4, 5

    NSArray *expectedCachedItems = [NSArray arrayWithObjects:@"2", @"3", @"4", @"5", nil];
    STAssertEqualObjects(itemCache.items, expectedCachedItems, @"Unexpected items");

    
    items = [NSArray arrayWithObjects:@"a", @"b", nil];
    [self mockDataSourceForRange:NSMakeRange(0, 2) items:items itemCount:itemCount];
    [itemCache ensureAvailability:1];
    [dataSource verify];

    // now cache has a, b, 2, 3
    
    expectedCachedItems = [NSArray arrayWithObjects:@"a", @"b", @"2", @"3", nil];
    STAssertEqualObjects(itemCache.items, expectedCachedItems, @"Unexpected items");
}

- (void)testInvalidate
{
    int itemCount = 11;
    itemCache.size = 4;    
    NSArray *items = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", nil];
    
    [self mockDataSourceForRange:NSMakeRange(0, 4) items:items itemCount:itemCount];
    [itemCache ensureAvailability:0];
    [dataSource verify];
    
    [itemCache invalidate];
    
    [self mockDataSourceForRange:NSMakeRange(0, 4) items:items itemCount:itemCount];
    [itemCache ensureAvailability:0];
    [dataSource verify];
}

- (void)mockDataSourceForRange:(NSRange)range itemCount:(NSUInteger)itemCount
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:range.length];
    for (int i = 0; i < range.length; i++) {
        [items addObject:@"thing"];
    }
    
    [self mockDataSourceForRange:range items:items itemCount:itemCount];
}

- (void)mockDataSourceForRange:(NSRange)range items:(NSArray *)items itemCount:(NSUInteger)itemCount
{
    [[dataSource expect] initForRange:range];
    [[[dataSource stub] andReturnValue:OCMOCK_VALUE((NSUInteger){itemCount})] count];    
    [[[dataSource expect] andReturn:items] getItemAttributesInRange:range];
    [[[dataSource expect] andReturn:items] getItemDescriptionsInRange:range];    
    [[[dataSource expect] andReturn:items] getItemImagesInRange:range];    
    [[[dataSource expect] andReturn:items] getItemsInRange:range];
}

@end