// @author Simon Toens 03/17/13

#import "DataSourceAccess.h"
#import "ItemPickerContext.h"
#import "ItemPickerDataSourceDefaults.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"

@interface ItemPicker() 
- (UIViewController *)getControllerForDataSource:(id<ItemPickerDataSource>)dataSource 
                               itemPickerContext:(ItemPickerContext *)itemPickerContext;

@property(nonatomic, strong) NSArray *dataSources;

@end

@implementation ItemPicker

@synthesize dataSources = _dataSources;
@synthesize delegate;
@synthesize itemLoadRangeLength = _itemLoadRangeLength;
@synthesize maxSelectableItems = _maxSelectableItems;
@synthesize showDoneButton = _showDoneButton;
@synthesize viewController = _viewController;

NSString *ItemPickerDataSourceDidChangeNotification = @"STItemPickerDataSourceDidUpdate";

- (id)initWithDataSources:(NSArray *)dataSources
{
    if (self = [super init]) 
    {
        [Preconditions assertNotEmpty:dataSources];
        _dataSources = dataSources;
        _itemLoadRangeLength = 500;
        _maxSelectableItems = 1;
        _showDoneButton = NO;
    }
    return self;
}

- (UIViewController *)viewController 
{
    if (_viewController) 
    {
        return _viewController;
    }
        
    ItemPickerContext *itemPickerContext = [[ItemPickerContext alloc] init];
    if ([self.dataSources count] > 1) 
    {
        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:[self.dataSources count]];
        for (id<ItemPickerDataSource> dataSource in self.dataSources) 
        {
            [viewControllers addObject:[self getControllerForDataSource:dataSource itemPickerContext:itemPickerContext]];
        }
        _viewController = [[UITabBarController alloc] init];
        [(id)_viewController setViewControllers:viewControllers];
    } 
    else 
    {
        _viewController = [self getControllerForDataSource:[self.dataSources lastObject] itemPickerContext:itemPickerContext];
    }
    return _viewController;
}

- (UIViewController *)getControllerForDataSource:(id<ItemPickerDataSource>)dataSource 
                               itemPickerContext:(ItemPickerContext *)itemPickerContext
{
    id<ItemPickerDataSource> wrappedDataSource = [[ItemPickerDataSourceDefaults alloc] initWithDataSource:dataSource];
    ItemPickerViewController *controller = [[ItemPickerViewController alloc] 
        initWithDataSource:wrappedDataSource itemPickerContext:itemPickerContext];
    controller.itemPickerDelegate = self.delegate;
    controller.maxSelectableItems = self.maxSelectableItems;
    controller.showDoneButton = self.showDoneButton;
    controller.dataSourceAccess.itemCache.size = self.itemLoadRangeLength;
    return [[UINavigationController alloc] initWithRootViewController:controller];    
}

@end