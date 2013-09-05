;;; colorify-lab.scm
;;; Author: Maxim Zakharov <maxime@maxime.net.ru>
;;; Version 0.1

(define (script-fu-colorify-lab image drawable ab-adjust l-adjust)

  ; define spline for layers A and B
  (define splineAB
    (let* (
	   (my-curve (make-vector 8 'byte))
	   )
      (vector-set! my-curve 0 0)
      (vector-set! my-curve 1 0)
      (vector-set! my-curve 2 ab-adjust)
      (vector-set! my-curve 3 0)
      (vector-set! my-curve 4 (- 255 ab-adjust))
      (vector-set! my-curve 5 255)
      (vector-set! my-curve 6 255)
      (vector-set! my-curve 7 255)
      my-curve
      )
    )

  ; define spline for layer L
  (define splineL
    (let* (
	   (my-curve (make-vector 6 'byte))
	   )
      (vector-set! my-curve 0 0)
      (vector-set! my-curve 1 0)
      (vector-set! my-curve 2 127)
      (vector-set! my-curve 3 (+ 127 l-adjust))
      (vector-set! my-curve 4 255)
      (vector-set! my-curve 5 255)
      my-curve
      )
    )

  ; begin undo group
  (gimp-undo-push-group-start image)

  ; decompose image to LAB
  (define imageLAB (car (plug-in-decompose RUN-NONINTERACTIVE image drawable "LAB" 1)))

  ; define layers L, A and B
  (define layersLAB (gimp-image-get-layers imageLAB))
  (define layerL (aref (cadr layersLAB) 0))
  (define layerA (aref (cadr layersLAB) 1))
  (define layerB (aref (cadr layersLAB) 2))

  ; apply spline to color histograms
  (gimp-curves-spline layerA HISTOGRAM-VALUE 8 splineAB)
  (gimp-curves-spline layerB HISTOGRAM-VALUE 8 splineAB)
  (gimp-curves-spline layerL HISTOGRAM-VALUE 6 splineL)

  ; set layer L as active layer
  (gimp-image-set-active-layer imageLAB layerL)

  ; recompose image
  (plug-in-recompose RUN-NONINTERACTIVE imageLAB layerL)

  ; remode temporary imageLAB
  (gimp-image-delete imageLAB)

  ; update image window
  (gimp-displays-flush)

  ; end undo group
  (gimp-undo-push-group-end image)

)

(script-fu-register "script-fu-colorify-lab"
  "<Image>/Script-Fu/Colorify LAB"
  "Smart colorify image through LAB color space"
  "Maxim Zakharov <maxime@maxime.net.ru>"
  "Maxim Zakharov"
  "2009"
  ""
  SF-IMAGE      "Image"             0
  SF-DRAWABLE   "Drawable to apply" 0
  SF-ADJUSTMENT _"A/B Adjust"       '(42    0 120 0.1 1 1 0)
  SF-ADJUSTMENT _"L Adjust"         '(-5 -120 120 0.1 1 1 0)
)
