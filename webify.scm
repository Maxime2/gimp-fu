; webify.scm
; rescale an image for the Web
; Script-fu for Gimp

(script-fu-register
	"script-fu-webify"
	"<Image>/Script-Fu/Webify"
	"Rescale an image for Web."
	"Maxim Zakharov <dp.maxime@gmail.com>"
	"Maxim Zakharov"
	"2009"
	"*"
	SF-IMAGE "Image" 0
	SF-DRAWABLE "Drawable" 0
	SF-VALUE "Long side (px)" "1024"
)

(define (get-dimension img long-side)
  (let*
      (
       (w (car (gimp-image-width img)))
       (h (car (gimp-image-height img)))
       (w2 w)
       (h2 h)
       )
    
    (print w2)
    (print h2)
    (print long-side)
    (if (not (= long-side 0))
        (begin
          (cond
           ((> w h)
            (set! w2 long-side)
            (set! h2 (/ (* h long-side) w))
            )
           ((< w h)
            (set! w2 (/ (* w long-side) h))
            (set! h2 long-side)
            )
           )
          )
    )
    (list w2 h2)
  )
)

(define (script-fu-webify image drawable long-side)

	; begin undo group
	(gimp-undo-push-group-start image)

	(define dimensions (get-dimension image long-side))
	(define width (car dimensions))
	(define height (cadr dimensions))
	(gimp-image-set-resolution image 72 72)
	(if (not (= long-side 0)) (gimp-image-scale image width height))

	(plug-in-normalize RUN-NONINTERACTIVE image drawable)
	
	; update image window
	(gimp-displays-flush)
		
	; end undo group
	(gimp-undo-push-group-end image)
		
)

; Adapted from discussions:
; http://www.flickr.com/groups/e510/discuss/72157606554624290/
; http://www.flickr.com/groups/gimpusers/discuss/72157606496961906/
