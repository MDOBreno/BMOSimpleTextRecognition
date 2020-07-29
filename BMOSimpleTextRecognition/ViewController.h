//
//  ViewController.h
//  BMOSimpleTextRecognition
//
//  Created by Breno Medeiros on 28/07/20.
//  Copyright © 2020 ProgramasBMO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>
#import <VisionKit/VisionKit.h>

@interface ViewController : UIViewController<VNDocumentCameraViewControllerDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;




@end

