#!/usr/bin/env python3

# Wr# Write your code here :-)
from guizero import App, Text, PushButton
import subprocess as sub
import os

os.chdir("/home/pi/LCD-show") # change directory
sub.call("ls", shell=True) # ls

app = App("ScreenModeChange",300,300)
app.bg = (251, 251, 208)

title_text = Text(app, "ScreenMode", 16, "black")

def changeToHdmi():
    sub.call('sudo ./system_restore.sh', shell=True)

def changeToTft():
    sub.call('sudo ./MHS35-show', shell=True)

hdmi_button = PushButton(app, changeToHdmi, text="Select Hdmi")
tft_button = PushButton(app, changeToTft, text="Select 3.5 screen")

app.display()