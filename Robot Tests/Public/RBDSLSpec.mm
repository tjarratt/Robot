#import "RBDSL.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RBDSLSpec)

describe(@"RBDSL", ^{
    __block UIView *view;
    __block UIView *viewWithZeroSize;
    __block UIView *randomOtherView;
    __block UIView *invisibleView;
    __block UILabel *label;
    __block UITextField *textField;

    beforeEach(^{
        CGRect size = CGRectMake(0, 0, 100, 50);
        view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        randomOtherView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];

        label = [[UILabel alloc] initWithFrame:size];
        label.text = @"label1";

        textField = [[UITextField alloc] initWithFrame:size];
        textField.accessibilityLabel = @"label1";

        invisibleView = [[UIView alloc] initWithFrame:size];
        invisibleView.hidden = YES;

        viewWithZeroSize = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        viewWithZeroSize.clipsToBounds = YES;
    });

    describe(@"finding views", ^{
        it(@"should be able to find views by class", ^{
            [view addSubview:textField];
            [view addSubview:label];
            [view addSubview:randomOtherView];

            allViews(ofExactClass([UILabel class]), view) should equal(@[label]);
        });

        it(@"should be able to find views by accessibility label", ^{
            [view addSubview:label];
            [view addSubview:textField];
            [view addSubview:randomOtherView];

            allViews(withLabel(@"label1"), view) should equal(@[label, textField]);
            theFirstView(withLabel(@"label1"), view) should equal(label);
        });

        it(@"should be able to find views by predicate", ^{
            [view addSubview:textField];
            [view addSubview:randomOtherView];

            allViews(where(@"self == %@", textField), view) should equal(@[textField]);
        });

        it(@"should be able to find visible views", ^{
            [view addSubview:label];
            [view addSubview:invisibleView];

            allViews(withVisibility(YES), view) should equal(@[view, label]);
            allViews(withVisibility(NO), view) should equal(@[invisibleView]);
        });

        it(@"should be able to exclude the root view", ^{
            [view addSubview:label];
            [view addSubview:invisibleView];

            allSubViews(withVisibility(YES), view) should equal(@[label]);
        });

        it(@"should be able to find views that have all its parentViews matching the predicate", ^{
            [view addSubview:invisibleView];
            [invisibleView addSubview:label];

            [view addSubview:label];
            allViews(includingSuperViews(withVisibility(YES)), view) should equal(@[view, label]);
        });

        it(@"should be able to identify views that can be seen", ^{
            [view addSubview:viewWithZeroSize];
            [view addSubview:invisibleView];
            [view addSubview:randomOtherView];
            UIView *viewOffTheScreen = [[UIView alloc] initWithFrame:CGRectMake(-10, -10, 5, 5)];
            [view addSubview:viewOffTheScreen];

            [invisibleView addSubview:label];

            allSubViews(thatCanBeSeen(YES), view) should equal(@[randomOtherView]);
            allSubViews(thatCanBeSeen(NO), view) should equal(@[viewWithZeroSize,
                                                                invisibleView,
                                                                label,
                                                                viewOffTheScreen]);
        });
    });

    describe(@"view interaction", ^{
    });
});

SPEC_END
