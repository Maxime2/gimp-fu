;;; unsharp-mask-LAB.scm
;;; Author: Maxim Zakharov <maxime@maxime.net.ru>
;;; Version 0.2

(define (script-fu-unsharp-mask-lab image drawable slider-radius slider-amount slider-threshold blur-radius)

  ; begin undo group
  (gimp-undo-push-group-start image)

  ; decompose image to LAB
  (define imageLAB (car (plug-in-decompose 1 image drawable "LAB" 1)))

  ; define layer L
  (define layersLAB (gimp-image-get-layers imageLAB))
  (define layerL (aref (cadr layersLAB) 0))
  (define layerA (aref (cadr layersLAB) 1))
  (define layerB (aref (cadr layersLAB) 2))

  ; set layer L as active layer
  (gimp-image-set-active-layer imageLAB layerL)

  ; run Unsharp Mask plug-in with specified parameters
  (plug-in-unsharp-mask RUN-NONINTERACTIVE imageLAB layerL slider-radius slider-amount slider-threshold)

  (if (> blur-radius 0)
      (begin
        ; set layer A as active layer
	(gimp-image-set-active-layer imageLAB layerA)
        ;- Perform 'Gaussian Blur' on the layer A
	(plug-in-gauss-iir RUN-NONINTERACTIVE imageLAB layerA blur-radius blur-radius 0)

        ; set layer B as active layer
	(gimp-image-set-active-layer imageLAB layerB)
	;- Perform 'Gaussian Blur' on the layer B
	(plug-in-gauss-iir RUN-NONINTERACTIVE imageLAB layerB blur-radius blur-radius 0)
      )
  )

  ; recompose image
  (plug-in-recompose 1 imageLAB layerL)

  ; remode temporary imageLAB
  (gimp-image-delete imageLAB)

  ; update image window
  (gimp-displays-flush)

  ; end undo group
  (gimp-undo-push-group-end image)

)

(script-fu-register "script-fu-unsharp-mask-lab"
  "<Image>/Script-Fu/Unsharp Mask LAB..."
  "Make a new image from the current layer by applying the unsharp mask method"
  "Maxim Zakharov <maxime@maxime.net.ru>"
  "Maxim Zakharov"
  "2009"
  ""
  SF-IMAGE      "Image"             0
  SF-DRAWABLE   "Drawable to apply" 0
  SF-ADJUSTMENT _"Radius"           '(6   0.1 120 0.1 1 1 0)
  SF-ADJUSTMENT _"Amount"           '(0.3   0   5 0.1 1 1 0)
  SF-ADJUSTMENT _"Threshold"        '(1     0 255   1 1 0 0)
  SF-ADJUSTMENT _"Blur radius in channels A,B"           '(0.2 0 5 0.1 1 1 0)
)
