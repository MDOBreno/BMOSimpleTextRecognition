//
//  ViewController.m
//  BMOSimpleTextRecognition
//
//  Created by Breno Medeiros on 28/07/20.
//  Copyright © 2020 ProgramasBMO. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end



@implementation ViewController

NSArray<VNRequest *> *requests;
dispatch_queue_t textRecognitionWorkQueue;

NSString *resultingText;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    // Parar e esconder o Indicador de atividade do OCR
    [self->activityIndicator stopAnimating];
    self->activityIndicator.hidden = YES;
    
    // Solicitar que o Vision seja executado em cada página do documento digitalizado.
    requests = [[NSArray<VNRequest *> alloc] init];
    
    // Cria a fila de expedição para executar solicitações do Vision.
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    textRecognitionWorkQueue = dispatch_queue_create("TextRecognitionQueue", qos);
    
    resultingText = @"";
    
    
    
    [self setupVision];
}

// Solicita o Setup do Vision, pois a solicitação pode ser reutilizada
- (void)setupVision {
    VNRecognizeTextRequest *textRecognitionRequest = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        NSMutableArray *observations;
        @try {
            observations  = [[NSMutableArray alloc] init];
            for (VNRecognizedTextObservation *obs in request.results) {
                [observations addObject:(VNRecognizedTextObservation *)obs];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"As observações são de um tipo inesperado.");
        }
        @finally {
            //NSLog(@"Condição final");
        }
        
        // Concatena o texto reconhecido de todas as observações.
        NSInteger *maximumCandidates = 1;
        for (VNRecognizedTextObservation *observation in observations) {
            VNRecognizedText *candidate = [observation topCandidates:maximumCandidates].firstObject;
            resultingText = [NSString stringWithFormat:@"%@%@",
                             resultingText,
                             candidate.string];
        }
    }];
    // Especifica o nível de reconhecimento
    textRecognitionRequest.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
    requests = @[textRecognitionRequest];
}

- (IBAction)scanReceipts:(id)sender {
    //Cria uma instancia da Classe de Leitura de Docs da Vision, e abre ela
    VNDocumentCameraViewController *documentCameraViewController = [[VNDocumentCameraViewController alloc] init];
    documentCameraViewController.delegate = self;
    
    [self presentModalViewController:documentCameraViewController animated:YES];
}


// MARK: VNDocumentCameraViewControllerDelegate


- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFinishWithScan:(VNDocumentCameraScan *)scan {
    // Limpe qualquer texto existente.
    self->textView.text = @"";
    // Descartar a câmera de documentos
    [controller dismissModalViewControllerAnimated:YES];
    
    self->activityIndicator.hidden = NO;
    [self->activityIndicator startAnimating];
    
    dispatch_async(textRecognitionWorkQueue, ^{
        resultingText = @"";
        for (int pageIndex=0; pageIndex<scan.pageCount; pageIndex++) {
            struct CGImage *image = [scan imageOfPageAtIndex:pageIndex].CGImage;
            NSDictionary *d = [[NSDictionary alloc] init];
            VNImageRequestHandler *requestHandler = [[VNImageRequestHandler alloc] initWithCGImage:image options:d];
            NSError *error = nil;
            @try {
                [requestHandler performRequests:requests error:&error];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            @finally {
                NSLog(@"Condição final");
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self->textView.text = resultingText;
            [self->activityIndicator stopAnimating];
            self->activityIndicator.hidden = YES;
        });
    });
}


@end
