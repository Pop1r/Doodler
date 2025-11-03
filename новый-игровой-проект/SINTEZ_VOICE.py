import pyttsx3
import sys
import os

def speak_text(text):
    """Озвучивает готовый текст"""
    try:
        # Инициализация движка
        engine = pyttsx3.init()
        
        # Настройки
        engine.setProperty('rate', 600)    # Скорость
        engine.setProperty('volume', 0.9)  # Громкость
        
        # Поиск русского голоса
        voices = engine.getProperty('voices')
        # Озвучивание
        engine.say(text)
        engine.runAndWait()
        return True
        
    except Exception as e:
        return False

if __name__ == "__main__":
    # Жестко заданный текст
    FIXED_TEXT = """
    The frame-by-frame animation program provides the following functionality.

Project management. To create a new project, select the "File" menu item and click "New Project". To save the current project, select "File" and click "Save Project". To load a previously created project, select "File" and click "Open Project". To export the finished animation, select "File" and click "Export", then select the desired file format.

Frame management. To add a new frame, press the "Add Frame" button. To delete the current frame, press the "Delete Frame" button. The timeline panel is used to switch between frames.

Layer management. To create a new layer, press the "Add Layer" button. To delete the current layer, press the "Delete Layer" button. 

Onion skin function. To enable or disable the display of previous frames, use the "Show Previous Frames" toggle. To enable or disable the display of subsequent frames, use the "Show Next Frames" toggle. To set the number of displayed frames, use the "Frame Count" numeric field.

Drawing tools. To select a brush color, use the color palette. To change the brush size, use the "Brush Size" slider. 

Animation preview. To play the animation, press the "Play" button. To stop playback, press the "Stop" button. To adjust the playback speed, use the "Frame Rate" slider.

    """
    
    speak_text(FIXED_TEXT)
