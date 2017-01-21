#!/usr/bin/python

# import the necessary packages
from picamera.array import PiRGBArray
from picamera import PiCamera
import argparse
import datetime
import imutils
import time
import cv2
import numpy as np
 
# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-a", "--min-area", type=int, default=500, help="minimum area size")
args = vars(ap.parse_args())
 
# initialize the camera and grab a reference to the raw camera capture
camera = PiCamera()
camera.resolution = (320, 240)
camera.framerate = 32
rawCapture = PiRGBArray(camera, size=(320, 240))

# allow the camera to warmup
time.sleep(0.25)
 
# initialize the first frame in the video stream
firstFrame = None

lower = np.array([0, 30, 80], dtype="uint8")
upper = np.array([20, 150, 255], dtype="uint8")

# loop over the frames of the video
for frame in camera.capture_continuous(rawCapture, format="bgr", use_video_port=True):
	# resize the frame, convert it to grayscale, and blur it
	image = frame.array

	hsvimg = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
	skinmask = cv2.inRange(hsvimg, lower, upper)
	
	# show the frame and record if the user presses a key
	cv2.imshow("image", image)
	cv2.imshow("mask", skinmask)
	key = cv2.waitKey(1) & 0xFF

	# clear the stream in preparation for the next frame
	rawCapture.truncate(0)
 
	# if the `q` key is pressed, break from the lop
	if key == ord("q"):
		break
 
# cleanup the camera and close any open windows
cv2.destroyAllWindows()
