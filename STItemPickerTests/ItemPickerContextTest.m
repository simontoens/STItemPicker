// @author Simon Toens 05/11/13

#import <XCTest/XCTest.h>
#import "ItemPickerSelection.h"
#import "SampleCityDataSource.h"

@interface ItemPickerContextTest : XCTestCase
@end

@implementation ItemPickerContextTest

- (void)testEqualityAndHash
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerSelection *ctx1 = [[ItemPickerSelection alloc] initWithDataSource:ds 
                                                              selectedIndex:10 
                                                               selectedItem:@"item1" 
                                                               autoSelected:NO
                                                               metaCell:NO];
    
    ItemPickerSelection *ctx2 = [[ItemPickerSelection alloc] initWithDataSource:ds 
                                                              selectedIndex:10 
                                                               selectedItem:@"item1"
                                                               autoSelected:NO
                                                               metaCell:NO];
    
    XCTAssertEqualObjects(ctx1, ctx2, @"bad equality");
    
    ItemPickerSelection *ctx3 = [[ItemPickerSelection alloc] initWithDataSource:ds 
                                                              selectedIndex:13 
                                                               selectedItem:@"item3" 
                                                               autoSelected:NO
                                                               metaCell:NO];
                               
    NSArray *array = @[ctx1, ctx2, ctx3];
    XCTAssertTrue([array containsObject:ctx1], @"Where's the ctx?");
    XCTAssertTrue([array containsObject:ctx2], @"Where's the ctx?");
    XCTAssertTrue([array containsObject:ctx3], @"Where's the ctx?");
    XCTAssertFalse([array containsObject:[[ItemPickerSelection alloc] initWithDataSource:ds selectedIndex:1 selectedItem:@"1" autoSelected:NO metaCell:NO]], @"No way");
    
    XCTAssertEqual([ctx1 hash], [ctx2 hash], @"bad hash");
}

- (void)testCopy
{
    SampleCityDataSource *ds = [[SampleCityDataSource alloc] init];
    
    ItemPickerSelection *ctx = [[ItemPickerSelection alloc] initWithDataSource:ds selectedIndex:4 selectedItem:@"a" 
                                                                  autoSelected:NO metaCell:NO];
    ItemPickerSelection *copy = [ctx copy];
    XCTAssertFalse(ctx == copy, @"Copy, what did you do?");
    XCTAssertEqualObjects(ctx, copy, @"Bad copy!");
}

@end
