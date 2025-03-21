;; Copyright (C) 2025 Lucky Kispotta

;; Author: Lucky Mathias Kispotta <luckymk.mcs2024@cmi.ac.in>
;; Version: 1.0.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: text, generative-ai, Google Gemini
;; URL: https://github.com/YOmaann/gnime

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package lets you fetch responses to prompts from Google Gemini API



(require 'json)

(defgroup genimi nil
  "Customization options for genimi."
    :group 'convenience)

(defcustom GeminiKey nil
  "API key for Gemini"
  :type 'string
  :group 'genimi
  )


;; uri for gemini api
(defun getResponse (prompt)
  "Get response from the server for the following prompt"
  (let ((buffer-to-write (current-buffer))
	(point-to-write (point))
	(url-to-get (format "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=%s" GeminiKey))
	(url-request-method "POST")
	(url-request-extra-headers `(("Content-Type" . "application/json")
))
	(url-request-data (format "{\n\"contents\":[{\n \"parts\":[{\"text\":\"%s\"}]}]\n}" prompt)))
  (url-retrieve url-to-get
		(lambda (status buffer-to-write point-to-write)
		  (if (plist-get status :error)
		      (message "Error while fetching data! %s" (plist-get status :error))
		    
		    (let ((response-buffer (current-buffer))
			  (_buffer-to-write buffer-to-write)
			  (_point-to-write point-to-write))
		      (unwind-protect
			  (with-current-buffer response-buffer
			    (goto-char (point-min))
			    (if (re-search-forward "\n\n" nil t)
				(let* ((_buffer-to-write buffer-to-write)
				      (response (buffer-substring (point) (point-max)))
				      (_point-to-write point-to-write)
				      (json-data (json-read-from-string response))
				      (to_write (alist-get 'text (aref (alist-get 'parts (alist-get 'content (aref (alist-get 'candidates json-data) 0))) 0))))
				 (progn
				 (set-buffer _buffer-to-write)
				 (goto-char _point-to-write)
				 
				 (insert (concat "\n-------\n" to_write "\n-------\n"))
				 (message "Gemini spoke..")))
			      
			      (error "No data found in response!"))
			    )
			  (kill-buffer response-buffer))
		      )))
		`(,buffer-to-write ,point-to-write)))
  )

(defun genimiGo ()
  "Get selected text and fetch response!"
  (interactive)
  (let ((prompt (buffer-substring (line-beginning-position) (line-end-position))))
    (message prompt)
    (getResponse prompt)))

(global-set-key (kbd "C-c g") 'genimiGo)
(setq debug-on-error t)

(provide 'genimi)
