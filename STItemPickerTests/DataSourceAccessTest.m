// @author Simon Toens 06/02/13

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "DataSourceAccess.h"
#import "ItemPickerDataSource.h"

@interface DataSourceAccessTest : XCTestCase
{
    @private
    NSArray *_items;
    NSArray *_itemDescriptions;
    NSArray *_itemImages;
    NSArray *_itemAttributes;
    BOOL _sectionsEnabled;
    id _dataSource;
    DataSourceAccess *_dataSourceAccess;
    
    BOOL _initForRangeCalled;
    BOOL _otherRangeMethodsCalled;
}
@end

@implementation DataSourceAccessTest

- (void)setUp
{
    [super setUp];
    _items = @[@"2", @"1"];
    _sectionsEnabled = NO;
    _dataSource = [OCMockObject mockForProtocol:@protocol(ItemPickerDataSource)];
    _dataSourceAccess = [[DataSourceAccess alloc] initWithDataSource:_dataSource autoSelected:NO];
    _dataSourceAccess.itemCacheSize = 1;
    _otherRangeMethodsCalled = NO;
    _initForRangeCalled = NO;
}    

- (void)testInitForRangeCalledOnceWithoutSections
{
    _sectionsEnabled = NO;
    NSRange range = NSMakeRange(0, 1);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockDataSourceForRange:range];
    
    [self callMethodsOn:_dataSourceAccess withIndexPath:indexPath expectedItem:@"2"];
    XCTAssertTrue(_initForRangeCalled, @"Expected initForRange to be called");
    XCTAssertTrue(_otherRangeMethodsCalled, @"Expected other range methods to be called");
    
    _initForRangeCalled = NO;
    _otherRangeMethodsCalled = NO;
    
    [self callMethodsOn:_dataSourceAccess withIndexPath:indexPath expectedItem:@"2"];
    XCTAssertFalse(_initForRangeCalled, @"Did not expect initForRange to be called again");
    XCTAssertFalse(_otherRangeMethodsCalled, @"Did not expect other range methods to be called");

    _otherRangeMethodsCalled = NO;
    range = NSMakeRange(1, 1);
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    [self mockDataSourceForRange:range];
    
    [self callMethodsOn:_dataSourceAccess withIndexPath:indexPath expectedItem:@"1"];
    XCTAssertTrue(_initForRangeCalled, @"Expected initForRange to be called");
    XCTAssertTrue(_otherRangeMethodsCalled, @"Expected other range methods to be called");
}

- (void)testInitForRangeCalledOnceWithCalculatedSections
{
    _sectionsEnabled = YES;
    NSRange range = NSMakeRange(0, 2);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockDataSourceForRange:range];
    
    [self callMethodsOn:_dataSourceAccess withIndexPath:indexPath expectedItem:@"1"];
    XCTAssertTrue(_initForRangeCalled, @"Expected initForRange to be called");
    XCTAssertTrue(_otherRangeMethodsCalled, @"Expected other range methods to be called");
    
    _initForRangeCalled = NO;
    _otherRangeMethodsCalled = NO;
    
    [self callMethodsOn:_dataSourceAccess withIndexPath:indexPath expectedItem:@"1"];
    XCTAssertFalse(_initForRangeCalled, @"Did not expect initForRange to be called again");
    XCTAssertFalse(_otherRangeMethodsCalled, @"Did not expect other range methods to be called");
    
    _otherRangeMethodsCalled = NO;
    range = NSMakeRange(1, 1);
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    [self callMethodsOn:_dataSourceAccess withIndexPath:indexPath expectedItem:@"2"];
    XCTAssertFalse(_initForRangeCalled, @"Did not expect initForRange to be called again");
    XCTAssertFalse(_otherRangeMethodsCalled, @"Did not expect other range methods to be called");
}

- (void)assertPropertyValue:(SEL)property atIndex:(int)index expectedValue:(id)expectedValue
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id val = [_dataSourceAccess performSelector:property withObject:indexPath];
#pragma clang diagnostic pop        

    if (expectedValue == [NSNull null])
    {
        XCTAssertNil(val, @"Expected nil but got %@", val);    
    }
    else
    {
        XCTAssertEqual(val, expectedValue, @"Unexpected desc");
    }
}

- (void)testNSNullForDescriptions
{
    _itemDescriptions = @[[NSNull null], @"desc"];
    _dataSourceAccess.itemCacheSize = 2; // <- results in call to initWithRange:[0,2]
    [self mockDataSourceForRange:NSMakeRange(0, 2)];
    
    [self assertPropertyValue:@selector(getItemDescription:) atIndex:0 expectedValue:[NSNull null]];
    [self assertPropertyValue:@selector(getItemDescription:) atIndex:1 expectedValue:@"desc"];
}

- (void)testNSNullForImages
{
    _itemImages = @[[NSNull null]];
    [self mockDataSourceForRange:NSMakeRange(0, 1)];
    [self assertPropertyValue:@selector(getItemImage:) atIndex:0 expectedValue:[NSNull null]];        
}

- (void)testNSNullForAttributes
{
    _itemAttributes = @[[NSNull null]];
    [self mockDataSourceForRange:NSMakeRange(0, 1)];
    [self assertPropertyValue:@selector(getItemAttributes:) atIndex:0 expectedValue:[NSNull null]];
}

- (void)testInvalidate
{
    _items = @[@"1", @"2", @"3"];
    [self mockDataSourceForRange:NSMakeRange(0, 1)];
    XCTAssertEqual(_dataSourceAccess.getDataSourceItemCount, 3);
    
    _items = @[@"1", @"2", @"3", @"4"];
    XCTAssertEqual(_dataSourceAccess.getDataSourceItemCount, 3);
    
    [_dataSourceAccess reloadData];

    [self mockDataSourceForRange:NSMakeRange(0, 1)];
    XCTAssertEqual(_dataSourceAccess.getDataSourceItemCount, 4);
}

- (void)callMethodsOn:(DataSourceAccess *)dataSourceAccess withIndexPath:(NSIndexPath *)indexPath expectedItem:(NSString *)expectedItem
{
    NSString *item = [dataSourceAccess getItem:indexPath];
    XCTAssertEqualObjects(item, expectedItem, @"getItem returned an unexpected item");
    
    [dataSourceAccess getItemDescription:indexPath];
    [dataSourceAccess getItemImage:indexPath];
    [dataSourceAccess getItemAttributes:indexPath];    
}

- (void)mockDataSourceForRange:(NSRange)range
{
    [[[_dataSource stub] andCall:@selector(dataSourceCount) onObject:self] count];
    [[[_dataSource stub] andCall:@selector(dataSourceInitForRange:) onObject:self] initForRange:range];
    [[[_dataSource stub] andCall:@selector(dataSourceGetItemsInRange:) onObject:self] getItemsInRange:range];
    [[[_dataSource stub] andCall:@selector(dataSourceGetDescriptionsInRange:) onObject:self] getItemDescriptionsInRange:range];
    [[[_dataSource stub] andCall:@selector(dataSourceGetImagesInRange:) onObject:self] getItemImagesInRange:range];
    [[[_dataSource stub] andCall:@selector(dataSourceGetAttributesInRange:) onObject:self] getItemAttributesInRange:range];
    [[[_dataSource stub] andCall:@selector(dataSourceSectionsEnabled) onObject:self] sectionsEnabled];
    [[_dataSource expect] isLeaf];
    [[_dataSource expect] metaCellTitle];
    [[_dataSource expect] metaCellDescription];
    if (_sectionsEnabled)
    {
        [[[_dataSource stub] andReturn:nil] sections];
    }
}

- (NSUInteger)dataSourceCount
{
    return [_items count];
}

- (BOOL)dataSourceSectionsEnabled
{
    return _sectionsEnabled;
}

- (void)dataSourceInitForRange:(NSRange)range
{
    _initForRangeCalled = YES;
    XCTAssertFalse(_otherRangeMethodsCalled, @"initForRange should be called before any other range methods");
}

- (NSArray *)dataSourceGetItemsInRange:(NSRange)range
{
    _otherRangeMethodsCalled = YES;
    return [_items subarrayWithRange:range];
}

- (NSArray *)dataSourceGetDescriptionsInRange:(NSRange)range 
{
    return _itemDescriptions ? [_itemDescriptions subarrayWithRange:range] : [self dataSourceGetItemsInRange:range];
}

- (NSArray *)dataSourceGetImagesInRange:(NSRange)range 
{
    return _itemImages ? [_itemImages subarrayWithRange:range] : [self dataSourceGetItemsInRange:range];
}

- (NSArray *)dataSourceGetAttributesInRange:(NSRange)range 
{
    return _itemAttributes ? [_itemAttributes subarrayWithRange:range] : [self dataSourceGetItemsInRange:range];
}

@end
