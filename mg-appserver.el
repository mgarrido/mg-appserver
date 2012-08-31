;;; mg-appserver.el --- Enlace con servidor de aplicaciones desde emacs

(defgroup mg-as nil
  "Configuración del servidor de aplicaciones."
  :prefix "mg-as-")

(defcustom mg-as-program-dir ""
  "Directorio en el que se encuentra el ejecutable del servidor de aplicaciones."
  :group 'mg-as
  :type 'directory)

(defcustom mg-as-program ""
  "Archivo ejecutable del servidor de aplicaciones."
  :group 'mg-as
  :type 'file)

(defcustom mg-as-started-string ""
  "Mensaje que muestra el servidor de aplicaciones una vez que ha terminado el arranque."
  :group 'mg-as
  :type 'string)

(defconst mg-as-buffer-name "*appserver*"
  "Nombre del buffer en el que estará la salida de servidor de aplicaciones")

(defconst mg-as-on-msg (propertize " AS " 'face 'highlight)
  "Cadena que se usará para mostrar el estado del servidor de aplicaciones en la línea de modo")

(defvar mg-as-is-on ""
  "Variable con la que se mostrará en la línea de modo el estado del servidor")

(put 'mg-as-is-on 'risky-local-variable t)	;; Properties of strings in modeline are ignored in
						;; emacs 22+ unless the
						;; variable is risky.

(defvar mg-as-delete-starting-log nil
  "Indica si se deben eliminar los mensajes de los del inicio de servidor de aplicaciones")

; Para mostrar el estado del servidor en la línea de modo
(setq global-mode-string (append global-mode-string '(mg-as-is-on)))

(defun mg-as-filter (proc string)
  "Analiza la salida del servidor de aplicaciones y detecta cuándo está arrancado"
  (save-excursion
    (set-buffer (process-buffer proc))
    (goto-char (point-max))
    (insert string)
    (if (string-match mg-as-started-string string)
        (progn
          (setq mg-as-is-on mg-as-on-msg)
          (if mg-as-delete-starting-log
              (delete-region (point-min) (point)))
          ; Ya puedo desactivar el filtro
          (set-process-filter (get-process "appserver") nil)))))

(defun mg-as ()
  "Arranca el servidor de aplicaciones"
  (interactive)
  (let ((cur-dir default-directory))
    (cd mg-as-program-dir)
    (message "Arrancando el servidor de aplicaciones")
    (set-process-filter (start-process "appserver" mg-as-buffer-name shell-file-name 
                                       (concat mg-as-program))
                        'mg-as-filter)
    (cd cur-dir)))

(defun mg-as-start-or-stop ()
  "Arranca o para el servidor de aplicaciones"
  (interactive)
  (if (process-status "appserver")
      (progn (mg-as-stop) (setq mg-as-is-on ""))
    (mg-as)))

(defun mg-as-stop ()
  "Para el servidor de aplicaciones"
  (interactive)
  (message "Parando el servidor de aplicaciones")
  (interrupt-process "appserver"))

(defun mg-as-status ()
  "Informa del estado del servidor"
  (interactive)
  (message "App server status: %s" (process-status "appserver")))

(defun mg-as-clean-buffer ()
  "Borra el contenido del buffer de salida del servidor de aplicaciones"
  (interactive)
  (save-excursion
    (set-buffer mg-as-buffer-name)
    (erase-buffer)))

(provide 'mg-appserver)
