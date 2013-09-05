;;; dalton.scm
;;; Author: Maxim Zakharov <dp.maxime@gmail.com>
;;; Version 0.1

(define (script-fu-dalton-lab image drawable)

  ; define spline for layer A
  (define splineA
    (let* (
	   (my-curve (make-vector 8 'byte))
	   )
      (vector-set! my-curve 0 0)
      (vector-set! my-curve 1 0)
      (vector-set! my-curve 2 0)
      (vector-set! my-curve 3 77)
      (vector-set! my-curve 4 255)
      (vector-set! my-curve 5 178)
      (vector-set! my-curve 6 255)
      (vector-set! my-curve 7 255)
      my-curve
      )
    )

  ; begin undo group
  (gimp-undo-push-group-start image)

  ; decompose image to LAB
  (define imageLAB (car (plug-in-decompose 1 image drawable "LAB" 1)))

  ; define layer A
  (define layersLAB (gimp-image-get-layers imageLAB))
  (define layerA (aref (cadr layersLAB) 1))

  ; set layer A as active layer
  (gimp-image-set-active-layer imageLAB layerA)

  ; apply spline to color histograms
  (gimp-curves-spline layerA HISTOGRAM-VALUE 8 splineA)

  ; recompose image
  (plug-in-recompose 1 imageLAB layerA)

  ; remode temporary imageLAB
  (gimp-image-delete imageLAB)

  ; update image window
  (gimp-displays-flush)

  ; end undo group
  (gimp-undo-push-group-end image)

)

(define (script-fu-undalton-lab image drawable)

  ; define spline for layer A
  (define splineA
    (let* (
	   (my-curve (make-vector 8 'byte))
	   )
      (vector-set! my-curve 0 0)
      (vector-set! my-curve 1 0)
      (vector-set! my-curve 2 77)
      (vector-set! my-curve 3 0)
      (vector-set! my-curve 4 178)
      (vector-set! my-curve 5 255)
      (vector-set! my-curve 6 255)
      (vector-set! my-curve 7 255)
      my-curve
      )
    )

  ; begin undo group
  (gimp-undo-push-group-start image)

  ; decompose image to LAB
  (define imageLAB (car (plug-in-decompose 1 image drawable "LAB" 1)))

  ; define layer A
  (define layersLAB (gimp-image-get-layers imageLAB))
  (define layerA (aref (cadr layersLAB) 1))

  ; set layer A as active layer
  (gimp-image-set-active-layer imageLAB layerA)

  ; apply spline to color histograms
  (gimp-curves-spline layerA HISTOGRAM-VALUE 8 splineA)

  ; recompose image
  (plug-in-recompose 1 imageLAB layerA)

  ; remode temporary imageLAB
  (gimp-image-delete imageLAB)

  ; update image window
  (gimp-displays-flush)

  ; end undo group
  (gimp-undo-push-group-end image)

)

(script-fu-register "script-fu-dalton-lab"
  "<Image>/Script-Fu/Daltonian View"
  "Make image as a daltonian see it"
  "Maxim Zakharov <dp.maxime@gmail.com>"
  "Maxim Zakharov"
  "2009"
  ""
  SF-IMAGE      "Image"             0
  SF-DRAWABLE   "Drawable to apply" 0
)

(script-fu-register "script-fu-undalton-lab"
  "<Image>/Script-Fu/UnDaltonian View"
  "Make a daltonian image like normal"
  "Maxim Zakharov <dp.maxime@gmail.com>"
  "Maxim Zakharov"
  "2009"
  ""
  SF-IMAGE      "Image"             0
  SF-DRAWABLE   "Drawable to apply" 0
)
