// @author Simon Toens 12/14/12

#import "DataSourceAccess.h"
#import "ItemPicker.h"
#import "ItemPickerSelection.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "Stack.h"
#import "TableHeaderViewContainer.h"
#import "TableViewCellContainer.h"

@interface ItemPickerViewController()
- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
      itemPickerContext:(ItemPickerContext *)context
   currentSelectionStack:(Stack *)currentSelectionStack;

- (id)initWithNibName:(NSString *)nibName 
           dataSource:(id<ItemPickerDataSource>)dataSource 
    itemPickerContext:(ItemPickerContext *)itemPickerContext
currentSelectionStack:(Stack *)currentSelectionStack;

- (BOOL)moreCellsAreSelectable;
- (void)configureHeaderView;
- (void)configureNavigationItem;
- (void)configureTitle;
- (void)deselectAllItems;

- (ItemPickerSelection *)getPreviousContext;
- (void)handleSelection:(NSIndexPath *)indexPath;
- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)pushDataSource:(id<ItemPickerDataSource>)dataSource;
- (void)registerForNotifications;
- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
            contextForSelection:(ItemPickerSelection *)context
                     dataSource:(id<ItemPickerDataSource>)dataSource;
- (void)updateViewState;

@property(nonatomic, strong) Stack *currentSelectionStack;
@property(nonatomic, strong) ItemPickerContext *itemPickerContext;
@property(nonatomic, strong) DataSourceAccess *dataSourceAccess;
@property(nonatomic, strong) UIBarButtonItem *doneButton;

@end

@implementation ItemPickerViewController

@synthesize currentSelectionStack = _currentSelectionStack;
@synthesize dataSourceAccess = _dataSourceAccess;
@synthesize doneButton;
@synthesize itemPickerContext = _itemPickerContext;
@synthesize itemPickerDelegate;
@synthesize maxSelectableItems = _maxSelectableItems;
@synthesize showCancelButton = _showCancelButton;

static NSString* ReloadTableDataNotification = @"STItemPickerReloadTableDataNotification";

#pragma mark - Initializers/dealloc

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource itemPickerContext:(ItemPickerContext *)itemPickerContext
{
    return [self initWithDataSource:dataSource 
                  itemPickerContext:itemPickerContext
              currentSelectionStack:[[Stack alloc] init]];    
}

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
       itemPickerContext:(ItemPickerContext *)itemPickerContext
   currentSelectionStack:(Stack *)currentSelectionStack
{
    return [self initWithNibName:@"ItemPickerView" 
                      dataSource:dataSource 
               itemPickerContext:itemPickerContext
           currentSelectionStack:currentSelectionStack];
}

- (id)initWithNibName:(NSString *)nibName 
           dataSource:(id<ItemPickerDataSource>)dataSource
   itemPickerContext:(ItemPickerContext *)itemPickerContext
currentSelectionStack:(Stack *)currentSelectionStack
{
    if (self = [super initWithNibName:nibName bundle:nil]) 
    {
        _currentSelectionStack = currentSelectionStack;
        _itemPickerContext = itemPickerContext;
        _dataSourceAccess = [[DataSourceAccess alloc] initWithDataSource:dataSource];
        
        _maxSelectableItems = 1;
        _showCancelButton = NO;

        if (self.tabBarItem) 
        {
            self.title = [_dataSourceAccess getTitle];
            self.tabBarItem.image = [_dataSourceAccess getTabImage];
        }        
    }
    return self;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self configureHeaderView];
    [self configureNavigationItem];
    [self configureTitle];
    [self registerForNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewState];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) 
    {
        while ([[self.currentSelectionStack pop] autoSelected]);
    }
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate methods

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{    
    // hack to get rid of empty rows in table view (also see heightForFooterInSection)
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == [[self.dataSourceAccess getSectionTitles] count] - 1 ? 1 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    ItemPickerSelection *context = [self.dataSourceAccess getItemPickerContext:indexPath autoSelected:NO];
    [self selectedItemAtIndexPath:indexPath contextForSelection:context dataSource:[self.dataSourceAccess getDataSource]];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.dataSourceAccess getSectionTitles] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [[self.dataSourceAccess getSection:section] title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [[self.dataSourceAccess getSection:section] range].length;
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    UIImage *image = [self.dataSourceAccess getItemImage:indexPath];        
    NSString *description = [self.dataSourceAccess getItemDescription:indexPath];
    
    UITableViewCell *cell = [TableViewCellContainer newCellForTableView:tableView 
                                                                   text:[self.dataSourceAccess getItem:indexPath]
                                                                  image:image 
                                                            description:description
                                                         itemAttributes:[self.dataSourceAccess getItemAttributes:indexPath]];
    
    if (self.dataSourceAccess.isLeaf && self.maxSelectableItems > 1)
    {
        BOOL isCellSelected = [self isCellSelectedAtIndexPath:indexPath]; 
        cell.accessoryType = isCellSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;    
        cell.userInteractionEnabled = cell.userInteractionEnabled && (isCellSelected || [self moreCellsAreSelectable]);
    }
    
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return [self.dataSourceAccess getSectionTitles];
}

#pragma mark - Private methods

- (void)reloadDataForAllTableViews
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ReloadTableDataNotification object:nil];
}

- (BOOL)moreCellsAreSelectable
{
    return [self.itemPickerContext.selectedItems count] < self.maxSelectableItems;    
}

- (void)updateViewState
{
    self.doneButton.enabled = [self.itemPickerContext.selectedItems count] > 0;
}

- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.itemPickerContext.selectedItems count] == 0)
    {
        // if nothing is selected, this cell is not selected for sure
        return NO;
    }
    
    // review how we determine that a cell has been previously selected - 
    // this is creating a lot of ItemPickerContext instances
    ItemPickerSelection *ctx = [self.dataSourceAccess getItemPickerContext:indexPath autoSelected:NO];
    [self.currentSelectionStack push:ctx];
    NSArray *selectionPath = [self.currentSelectionStack allObjects];
    BOOL selected = [self.itemPickerContext.selectedItems containsObject:selectionPath];
    [self.currentSelectionStack pop];
    return selected;
}

- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
            contextForSelection:(ItemPickerSelection *)context
                     dataSource:(id<ItemPickerDataSource>)dataSource 
{
    NSArray *prevSelections = [[self.currentSelectionStack allObjects] copy];
    id<ItemPickerDataSource> nextDataSource = [dataSource getNextDataSourceForSelection:context previousSelections:prevSelections];
    
    [self.currentSelectionStack push:context];

    if (nextDataSource)
    {
        [self pushDataSource:nextDataSource];    
    } 
    else
    {
        [self handleSelection:indexPath];
    }
}

- (void)handleSelection:(NSIndexPath *)indexPath
{
    if (self.maxSelectableItems > 1)
    {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];            
        NSArray *selectionPath = [self.currentSelectionStack allObjects];            
        if ([self.itemPickerContext.selectedItems containsObject:selectionPath])
        {
            [self.itemPickerContext.selectedItems removeObject:selectionPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self reloadDataForAllTableViews];
        }
        else
        {
            if ([self moreCellsAreSelectable])
            {
                [self.itemPickerContext.selectedItems addObject:[selectionPath copy]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;    
            }
            else 
            {
                [self reloadDataForAllTableViews];
            }
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.currentSelectionStack pop];
        [self updateViewState];
    }
    else
    {
        [self.itemPickerDelegate onItemPickerPickedItems:[NSArray arrayWithObject:[self.currentSelectionStack allObjects]]];
    }
}

- (void)pushDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (dataSource.autoSelectSingleItem && dataSource.count == 1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        DataSourceAccess *access = [[DataSourceAccess alloc] initWithDataSource:dataSource];
        ItemPickerSelection *context = [access getItemPickerContext:indexPath autoSelected:YES];
        [self selectedItemAtIndexPath:indexPath contextForSelection:context dataSource:dataSource];
    }
    else
    {    
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] 
                                                initWithDataSource:dataSource
                                                 itemPickerContext:self.itemPickerContext
                                             currentSelectionStack:self.currentSelectionStack];
        
        controller.itemPickerDelegate = self.itemPickerDelegate;
        controller.maxSelectableItems = self.maxSelectableItems;
        controller.showCancelButton = self.showCancelButton;
        [self.navigationController pushViewController:controller animated:YES];    
    }
}

- (ItemPickerSelection *)getPreviousContext
{
    NSArray *contexts = [self.currentSelectionStack allObjects];
    return [contexts count] > 0 ? [contexts objectAtIndex:[contexts count] - 1] : nil;
}

- (ItemPickerSelection *)getContextFrom:(NSArray *)contexts atOffsetFromEnd:(NSUInteger)offset
{
    return [contexts count] > offset ? [contexts objectAtIndex:[contexts count] - 1 - offset] : nil;
}

- (TableHeaderViewContainer *)getHeaderViewContainerWithImage:(UIImage *)image defaultLabels:(BOOL)defaultLabels
{
    TableHeaderViewContainer *container = [TableHeaderViewContainer newTableHeaderViewWithImage:image];
    if (defaultLabels)
    {
        NSArray *contexts = [self.currentSelectionStack allObjects];
        container.boldLabel.text = [self getContextFrom:contexts atOffsetFromEnd:1].selectedItem;        
        container.label.text = [self getContextFrom:contexts atOffsetFromEnd:0].selectedItem;
        container.smallerLabel.text = [NSString stringWithFormat:@"%i %@", [self.dataSourceAccess getCount], [self.dataSourceAccess getTitle]];
    }
    return container;
}

- (void)configureHeaderView 
{
    TableHeaderViewContainer *container = nil;
    
    ItemPickerHeader *header = [self.dataSourceAccess getHeader];    
    if (header)
    {
        container = [self getHeaderViewContainerWithImage:header.image defaultLabels:header.defaultNilLabels];
        if (header.boldLabel) 
        {
            container.boldLabel.text = header.boldLabel;
        }
        if (header.label) 
        {
            container.label.text = header.label;
        }
        if (header.smallerLabel)
        {
            container.smallerLabel.text = header.smallerLabel;
        }
        if (header.smallestLabel)
        {
            container.smallestLabel.text = header.smallestLabel;
        }
    }
    self.tableView.tableHeaderView = container.tableHeaderView;
}

- (void)configureTitle 
{
    ItemPickerSelection *prevSelection = [self getPreviousContext];
    self.title = prevSelection ? prevSelection.selectedItem : [self.dataSourceAccess getTitle];
}

- (void)configureNavigationItem
{
    UIBarButtonItem *button = nil, *cancelButton = nil;
    
    if (self.maxSelectableItems > 1)
    {
        button = self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered 
                                                                   target:self
                                                                   action:@selector(onMultiSelect)];
        [self updateViewState];
    }
    
    if (self.showCancelButton)
    {
        button = cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered 
                                                                target:self
                                                                action:@selector(onCancel)];
    }
    
    if (doneButton && cancelButton)
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, doneButton, nil];    
    }
    else
    {
        self.navigationItem.rightBarButtonItem = button;
    }
}

- (void)registerForNotifications
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (self.dataSourceAccess.isLeaf)
    {
        [defaultCenter addObserver:self.tableView selector:@selector(reloadData) name:ReloadTableDataNotification object:nil];        
    }
    [defaultCenter addObserver:self.tableView selector:@selector(reloadData) name:ItemPickerDataSourceDidChangeNotification object:nil];
}

- (void)onMultiSelect
{
    NSArray *selections = [self.itemPickerContext.selectedItems copy];
    [self deselectAllItems];
    [self.itemPickerDelegate onItemPickerPickedItems:selections];
}

- (void)onCancel
{
    [self deselectAllItems];
    [self.itemPickerDelegate onItemPickerCanceled];
}

- (void)deselectAllItems
{
    [self.itemPickerContext.selectedItems removeAllObjects];
    [self updateViewState];
    [self reloadDataForAllTableViews];
}

@end