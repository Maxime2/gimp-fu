;;; unsharp-mask-YCbCr.scm
;;; Author: Maxim Zakharov <maxime@maxime.net.ru>
;;; Version 0.3
; --------------------------------------------------------------------
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.  
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, you can view the GNU General Public
; License version 3 at the web site http://www.gnu.org/licenses/gpl-3.0.html
; Alternatively you can write to the Free Software Foundation, Inc., 675 Mass
; Ave, Cambridge, MA 02139, USA.
;
;
;

(define (script-fu-unsharp-mask-ycbcr image drawable slider-radius slider-amount slider-threshold blur-radius inNorm inStre inEdge inOpacity shOpacity)
  (let*
      (
       (imageWidth (car (gimp-image-width image)))
       (imageHeight (car (gimp-image-height image)))
       (highOpacity inOpacity)
       (shadOpacity shOpacity)
       (highColour '(255 255 255))
       (shadColour '(0 0 0))
       )

    ;define helper function    
    (define (layer-colour-add TheImage layer layermask
                              name width height
                              colour opacity
                              invertMask)
      (let* ((layerCopy (car (gimp-layer-copy layer 1)))
             (newLayer (car (gimp-layer-new TheImage width height 1 "Overlay" 100 5)))
             (mergedLayer 0)
             (mask 0)
             )
        ;main layer
        (gimp-context-set-background colour)
        (gimp-image-add-layer TheImage layerCopy 0)
        (gimp-drawable-set-name layerCopy name)
        
        ;overlay layer
        (gimp-image-add-layer TheImage newLayer 0)
        (gimp-layer-set-mode newLayer 5)
        (gimp-edit-fill newLayer 1)
        (set! mergedLayer (car (gimp-image-merge-down TheImage newLayer 0)))
        
        ;Add a layer mask
        (set! mask (car (gimp-layer-create-mask layermask 5)))
        (gimp-layer-add-mask mergedLayer mask)
        (if (= invertMask TRUE) (gimp-invert mask))
        
        ;Change the merged layers opacity
        (gimp-layer-set-opacity mergedLayer opacity)
        )

      ) ;end of layer-colour-add 

  ; begin undo group
  (gimp-undo-push-group-start image)

  (if (= inEdge TRUE) 
      (let* (
	     (ColourImg (car (gimp-image-duplicate image)))
	     (inLayer 0)
	     (Rcomp 127)
	     (Gcomp 127)
	     (Bcomp 127)
	     )

					; find highlights and shadows colours from image average
	(set! inLayer (car (gimp-image-merge-visible-layers ColourImg EXPAND-AS-NECESSARY)))
;	(plug-in-color-enhance RUN-NONINTERACTIVE ColourImg inLayer)
	(set! Rcomp (round (car (gimp-histogram inLayer HISTOGRAM-RED 0 255)))) 
	(set! Gcomp (round (car (gimp-histogram inLayer HISTOGRAM-GREEN 0 255)))) 
	(set! Bcomp (round (car (gimp-histogram inLayer HISTOGRAM-BLUE 0 255)))) 

	(set! highColour
	      (list (+ Rcomp (round (/ (- 255 Rcomp) 3)))
		    (+ Gcomp (round (/ (- 255 Gcomp) 3)))
		    (+ Bcomp (round (/ (- 255 Bcomp) 3)))
		    )
	      )
	(set! shadColour
	      (list (- Rcomp (round (/ Rcomp 3)))
		    (- Gcomp (round (/ Gcomp 3)))
		    (- Bcomp (round (/ Bcomp 3)))
		    )
	      )

	(gimp-image-delete ColourImg)

;	(gimp-message (string-append "Highlights Colour"
;				     " R:" (number->string (car highColour))
;				     " G:" (number->string (cadr highColour))
;				     " B:" (number->string (caddr highColour))))

;	(gimp-message (string-append "Shadows Colour"
;				     " R:" (number->string (car shadColour))
;				     " G:" (number->string (cadr shadColour))
;				     " B:" (number->string (caddr shadColour))))
	)
      )

  ; decompose image to YCbCr
  (define imageYbr (car (plug-in-decompose 1 image drawable "YCbCr_ITU_R709" 1)))

  ; define layers Y, b and r
  (define layersYbr (gimp-image-get-layers imageYbr))
  (define layer-Y (aref (cadr layersYbr) 0))
  (define layer-b (aref (cadr layersYbr) 1))
  (define layer-r (aref (cadr layersYbr) 2))

  (if (> blur-radius 0)
      (begin
        ; set layer Cb as active layer
	(gimp-image-set-active-layer imageYbr layer-b)
  ; run Unsharp Mask plug-in with specified parameters
  (plug-in-unsharp-mask RUN-NONINTERACTIVE imageYbr layer-b slider-radius slider-amount slider-threshold)
        ;- Perform 'Gaussian Blur' on the layer Cb
	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-b blur-radius blur-radius 0)
;  (plug-in-unsharp-mask RUN-NONINTERACTIVE imageYbr layer-b slider-radius slider-amount slider-threshold)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-b 1 1 0)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-b 2 2 0)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-b 3 3 0)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-b 4 4 0)
	; recompose image
	(plug-in-recompose 1 imageYbr layer-b)
;  (gimp-displays-flush)

        ; set layer Cr as active layer
	(gimp-image-set-active-layer imageYbr layer-r)
  ; run Unsharp Mask plug-in with specified parameters
  (plug-in-unsharp-mask RUN-NONINTERACTIVE imageYbr layer-r slider-radius slider-amount slider-threshold)
	;- Perform 'Gaussian Blur' on the layer Cr
	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-r blur-radius blur-radius 0)
;  (plug-in-unsharp-mask RUN-NONINTERACTIVE imageYbr layer-r slider-radius slider-amount slider-threshold)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-r 1 1 0)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-r 2 2 0)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-r 3 3 0)
;	(plug-in-gauss-iir RUN-NONINTERACTIVE imageYbr layer-r 4 4 0)
	; recompose image
	(plug-in-recompose 1 imageYbr layer-r)
;  (gimp-displays-flush)
      )
  )

  ; set layer L as active layer
  (gimp-image-set-active-layer imageYbr layer-Y)

  ; normalize layer-Y if it needs
  (if (= inNorm TRUE) (plug-in-normalize RUN-NONINTERACTIVE imageYbr layer-Y) ())

  ; stretch levels for layer-Y if it needs
  (if (= inStre TRUE) (gimp-levels-stretch layer-Y) ())
  
  ; run Unsharp Mask plug-in with specified parameters
  (plug-in-unsharp-mask RUN-NONINTERACTIVE imageYbr layer-Y slider-radius slider-amount slider-threshold)

  ; recompose image
  (plug-in-recompose 1 imageYbr layer-Y)

  ; edge detection
  (if (= inEdge TRUE) 
      (let* (
	     (layerEdgeDetect (car (gimp-layer-copy drawable FALSE)))
	     (Ycopy (car (gimp-layer-copy drawable FALSE)))
	     )
	(gimp-image-add-layer image layerEdgeDetect 1)
	(gimp-image-add-layer image Ycopy 1)
	(plug-in-edge 1 image layerEdgeDetect 5.0 1 0)
					;Desaturate the layer
;	(gimp-desaturate Ycopy)
;	(gimp-desaturate layerEdgeDetect)
					;Add the shadows layer
	(layer-colour-add image Ycopy layerEdgeDetect
			  "Shadows"
			  imageWidth imageHeight
			  shadColour shadOpacity
			  TRUE)
    
					;Add the highlights layer
	(layer-colour-add image Ycopy layerEdgeDetect
			  "Highlights"
			  imageWidth imageHeight
			  highColour highOpacity
			  FALSE)
 	(gimp-image-remove-layer image layerEdgeDetect)
 	(gimp-image-remove-layer image Ycopy)
    	
	(gimp-image-merge-visible-layers image 1)

	)
      )
  

  ; remove temporary imageLAB
  (gimp-image-delete imageYbr)

  ; update image window
  (gimp-displays-flush)

  ; end undo group
  (gimp-undo-push-group-end image)
  )
)

(script-fu-register "script-fu-unsharp-mask-ycbcr"
  "<Image>/Script-Fu/Unsharp Mask YCbCr..."
  "Make a new image from the current layer by applying the unsharp mask method"
  "Maxim Zakharov <maxime@maxime.net.ru>"
  "Maxim Zakharov"
  "2009-2011"
  "RGB*"
  SF-IMAGE      "Image"             0
  SF-DRAWABLE   "Drawable to apply" 0
  SF-ADJUSTMENT _"Radius"           '(6   0.1 120 0.1 1 1 0)
  SF-ADJUSTMENT _"Amount"           '(0.2   0   5 0.1 1 1 0)
  SF-ADJUSTMENT _"Threshold"        '(1     0 255   1 1 0 0)
  SF-ADJUSTMENT _"Blur radius in channels Cb,Cr"           '(0.2 0 50 0.1 1 1 0)
  SF-TOGGLE     _"Do Normalize for Y channel"     FALSE
  SF-TOGGLE     _"Do Stretch levels for Y channel"     FALSE
  SF-TOGGLE     _"Split tone"     FALSE
  SF-ADJUSTMENT _"Split tone: highlights opacity"    '(20 1 100 1 1 0 0)
  SF-ADJUSTMENT _"Split tone: shadows opacity"    '(80 1 100 1 1 0 0)
)
