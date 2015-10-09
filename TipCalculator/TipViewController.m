//
//  ViewController.m
//  TipCalculator
//
//  Created by Jesse Pinho on 10/1/15.
//  Copyright © 2015 Jesse Pinho. All rights reserved.
//

#import "TipViewController.h"

@interface TipViewController ()

@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipControl;
@property (weak, nonatomic) IBOutlet UILabel *currencySymbolLabel;
@property (strong) NSNumberFormatter *currencyFormatter;
@property (strong) NSUserDefaults *defaults;
@property (weak, nonatomic) IBOutlet UIView *tipUIContainer;

@end

@implementation TipViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    self.defaults = [NSUserDefaults standardUserDefaults];
    [self.defaults addObserver:self forKeyPath:@"defaultTipIndex" options:NSKeyValueObservingOptionNew context:NULL];
    [self configureCurrencyFormatter];
    [self configureCurrencySymbolLabel];
    [self setUpBillAmount];
    [self setUpTipUIContainer];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setDefaultTipIndex];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.billTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)billChanged:(id)sender {
    [self persistBillAmount];
    [self updateValues];
    [self animateTipUIContainer];
}

- (void)persistBillAmount {
    [self.defaults setFloat:[self.billTextField.text floatValue] forKey:@"lastBillAmount"];
    [self.defaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:@"lastBillAmountTime"];
    [self.defaults synchronize];
}

- (void)setUpTipUIContainer {
    [self.tipUIContainer setAlpha:0.0];
    CGPoint center = self.tipUIContainer.center;
    CGPoint newCenter = CGPointMake(center.x, center.y + 100);
    [self.tipUIContainer setCenter:newCenter];
    [self animateTipUIContainer];
}

- (void)animateTipUIContainer {
    if ([self shouldAnimateTipUIContainer]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.tipUIContainer.alpha = [self getTipUIContainerAlpha];
            self.tipUIContainer.center = [self getTipUIContainerCenter];
        }];
    }
}

- (CGFloat)getTipUIContainerAlpha {
    return [self billAmountIsPresent] ? 1 : 0;
}

- (CGPoint)getTipUIContainerCenter {
    CGPoint center = self.tipUIContainer.center;
    CGFloat newY = [self billAmountIsPresent] ? center.y - 100 : center.y + 100;
    return CGPointMake(center.x, newY);
}

- (BOOL)shouldAnimateTipUIContainer {
    if (![self billAmountIsPresent] && self.tipUIContainer.alpha != 0) {
        return YES;
    }
    if ([self billAmountIsPresent] && self.tipUIContainer.alpha == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)billAmountIsPresent {
    return [self.billTextField.text length] == 0 ? NO : YES;
}

- (void)configureCurrencyFormatter {
    if (!self.currencyFormatter) {
        self.currencyFormatter = [[NSNumberFormatter alloc] init];
    }
    [self.currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [self.currencyFormatter setLocale:[NSLocale currentLocale]];
}

- (void)configureCurrencySymbolLabel {
    NSString *currencySymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    self.currencySymbolLabel.text = currencySymbol;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self configureCurrencyFormatter];
    [self configureCurrencySymbolLabel];
    [self updateValues];
}

- (void)updateValues {
    float billAmount = [self.billTextField.text floatValue];
    NSArray *tipValues = @[@(0.15), @(0.2), @(0.25)];
    float tipAmount = [tipValues[self.tipControl.selectedSegmentIndex] floatValue] * billAmount;
    float totalAmount = billAmount + tipAmount;

    self.tipLabel.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:tipAmount]];
    self.totalLabel.text = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:totalAmount]];
}

- (void)setDefaultTipIndex {
    NSInteger defaultTipIndex = [self.defaults integerForKey:@"defaultTipIndex"];
    [self.tipControl setSelectedSegmentIndex:defaultTipIndex];
    [self updateValues];
}

- (void)setUpBillAmount {
    double lastBillAmountTime = [self.defaults doubleForKey:@"lastBillAmountTime"];
    double timeSinceLastBillAmountTime = [[NSDate date] timeIntervalSince1970] - lastBillAmountTime;
    float lastBillAmount = [self.defaults floatForKey:@"lastBillAmount"];
    int tenMinutes = 60 * 10;
    if (lastBillAmount > 0 && lastBillAmountTime && timeSinceLastBillAmountTime < tenMinutes) {
        [self.billTextField setText:[NSString stringWithFormat:@"%.2f", lastBillAmount]];
    }
}

- (IBAction)tipAmountChanged:(UISegmentedControl *)sender {
    [self updateValues];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"defaultTipIndex"]) {
        [self setDefaultTipIndex];
    }
}
@end