// @author Simon Toens 03/23/13

#import <SenTestingKit/SenTestingKit.h>

#import "ItemAttributes.h"
#import "TableSectionHandler.h"
#import "Tuple.h"

@interface SectionItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSRange range;
@end

@implementation SectionItem
@synthesize title, range;
@end

@interface TableSectionHandlerTest : SenTestCase
@end

@implementation TableSectionHandlerTest

- (void)testBasicSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"a", @"b", @"c", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 1}];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"bb", @"cc", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 1}];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"bb", @"cc", @"ccc", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", @"B", @"C", nil]
    expectedItemCounts:(int[]){1, 1, 2}];
    
    [self runTestItems:[NSArray arrayWithObjects:@"aa", @"AABB", @"AACC", @"cc", @"ccc", @"CCCAABB", nil]
      expectedSections:[NSArray arrayWithObjects:@"A",@"C", nil]
    expectedItemCounts:(int[]){3, 3}];
}

- (void)testNonEnglishAlphabetSections
{
    [self runTestItems:[NSArray arrayWithObjects:
        @"äa", @"ÄB", @"éa", @"üC", @"ßa", @"øa", @"Øa", @"åa", @"Å", @"Œa", @"Ücc", @"あんまり", 
        @"œa", @"öc", @"ça", @"Ça", @"ÖB", nil]
      expectedSections:[NSArray arrayWithObjects:
        @"A", @"C", @"E", @"O", @"S", @"U", kTableSectionHandlerNonLatinLetterSymbolHeader, nil]
    expectedItemCounts:(int[]){4, 2, 1, 6, 1, 2, 1}];
    
    [self runTestItems:[NSArray arrayWithObjects:@"(äÄÜ)", nil]
      expectedSections:[NSArray arrayWithObjects:@"A", nil]
    expectedItemCounts:(int[]){1}];
}

- (void)testNumberSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"3", @"3003", nil]
      expectedSections:[NSArray arrayWithObjects:kTableSectionHandlerNumberHeader, nil]
    expectedItemCounts:(int[]){2}];
}

- (void)testSymbolSections 
{
    [self runTestItems:[NSArray arrayWithObjects:@"*a", @"(zzz)", @"!44", @"@444", @"%$#", nil]
      expectedSections:[NSArray arrayWithObjects:kTableSectionHandlerSymbolHeader, kTableSectionHandlerNumberHeader, @"A", @"Z", nil]
    expectedItemCounts:(int[]){1, 2, 1, 1}];
}

- (void)testAllLetters 
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    STAssertEquals([alphabet length], (NSUInteger)26, @"bad number of letters");
    NSMutableArray *lowerCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    NSMutableArray *upperCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    int counts[[alphabet length]];
    for (int i = 0; i < [alphabet length]; i++) 
    {
        NSRange r;
        r.location = i;
        r.length = 1;
        counts[i] = 1;
        NSString *letter = [alphabet substringWithRange:r];
        [lowerCaseItems addObject:[letter lowercaseString]];
        [upperCaseItems addObject:[letter uppercaseString]];
    }

    [self runTestItems:lowerCaseItems expectedSections:upperCaseItems expectedItemCounts:counts];
    [self runTestItems:upperCaseItems expectedSections:upperCaseItems expectedItemCounts:counts];
}

- (void)testAllNumbers 
{
    NSString *numbers = @"0123456789";
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[numbers length]];
    for (int i = 0; i < [numbers length]; i++) {
        NSRange r;
        r.location = i;
        r.length = 1;
        [items addObject:[numbers substringWithRange:r]];
    }
    
    [self runTestItems:items 
      expectedSections:[NSArray arrayWithObject:kTableSectionHandlerNumberHeader] 
    expectedItemCounts:(int[]){10}];
}

- (void)testItemImagesSort 
{
    NSArray *items = [NSArray arrayWithObjects:@"3", @"2", @"1", nil];
    NSArray *images = [NSArray arrayWithObjects:@"aa", @"bb", @"cc", nil];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.itemImages = images;

    NSArray *expectedItems = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedImages = [NSArray arrayWithObjects:@"cc", @"bb", @"aa", nil];
    STAssertEqualObjects(handler.itemImages, expectedImages, @"Bad sort order");
}

- (void)testItemDescriptionsSort 
{
    NSArray *items = [NSArray arrayWithObjects:@"3", @"2", @"1", @"3", nil];
    NSArray *descriptions = [NSArray arrayWithObjects:@"aa", @"bb", @"cc", @"dd", nil];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.itemDescriptions = descriptions;
    
    NSArray *expectedItems = [NSArray arrayWithObjects:@"1", @"2", @"3", @"3", nil];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedDescriptions = [NSArray arrayWithObjects:@"cc", @"bb", @"aa", @"dd", nil];
    STAssertEqualObjects(handler.itemDescriptions, expectedDescriptions, @"Bad sort order");
}

- (void)testItemAttributesSort
{
    ItemAttributes *a1 = [[ItemAttributes alloc] init];
    ItemAttributes *a2 = [[ItemAttributes alloc] init];
    ItemAttributes *a3 = [[ItemAttributes alloc] init];
    NSArray *items = [NSArray arrayWithObjects:@"3", @"1", @"2", nil];
    NSArray *ItemAttributes = [NSArray arrayWithObjects:a1, a2, a3, nil];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.ItemAttributes = ItemAttributes;
    
    NSArray *expectedItems = [NSArray arrayWithObjects:@"1", @"2", @"3", nil];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedAttributes = [NSArray arrayWithObjects:a2, a3, a1, nil];
    STAssertEqualObjects(handler.itemAttributes, expectedAttributes, @"Bad sort order");
}

- (void)runTestItems:(NSArray *)items
    expectedSections:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts 
{
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    [self runTestItems:expectedSections expectedItemCounts:expectedItemCounts tableSectionHandler:handler];
}

- (void)runTestItems:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts 
 tableSectionHandler:(TableSectionHandler *)handler
{
    STAssertEquals([handler.sections count], [expectedSections count], @"Unexpected number of sections");

    int expectedLocation = 0;
    for (int numSection = 0; numSection < [handler.sections count]; numSection++) {
        id section = [handler.sections objectAtIndex:numSection];
        NSString *title = [section title];
        NSRange range = [section range];
        STAssertEqualObjects(title, [expectedSections objectAtIndex:numSection], @"Unexpected section title for section: %@", section);        
        STAssertEquals(range.location, (NSUInteger)expectedLocation, @"Unexpected section location for section: %@", section);
        STAssertEquals(range.length, (NSUInteger)expectedItemCounts[numSection], @"Unexpected item count for section: %@", section);
        expectedLocation += range.length;
    }
}

@end