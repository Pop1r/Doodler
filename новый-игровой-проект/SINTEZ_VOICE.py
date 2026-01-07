import pyttsx3
import sys
import os

def speak_text(text):
    """Озвучивает текст на английском с правильными настройками"""
    try:
        # Инициализация движка
        engine = pyttsx3.init()
        
        # Настройки для лучшего английского произношения
        engine.setProperty('rate', 500)     # Оптимальная скорость для английского
        engine.setProperty('volume', 0.9)   # Громкость
        
        # Поиск английского голоса
        voices = engine.getProperty('voices')
        for voice in voices:
            # Ищем голос с английской локализацией
            if 'english' in voice.name.lower() or 'en_' in voice.id.lower():
                engine.setProperty('voice', voice.id)
                print(f"Using voice: {voice.name}")
                break
        else:
            # Если английский голос не найден, используем первый доступный
            print("English voice not found, using default voice")
        
        # Озвучивание
        engine.say(text)
        engine.runAndWait()
        return True
        
    except Exception as e:
        print(f"Error in speech synthesis: {e}")
        return False



if __name__ == "__main__":
    FIXED_TEXT = """
    The frame-by-frame animation program provides the following functionality.

Project management. To create a new project, select the "File" menu item and click "New Project". To save the current project, select "File" and click "Save Project". To load a previously created project, select "File" and click "Open Project". To export the finished animation, select "File" and click "Export", then select the desired file format.

Frame management. To add a new frame, press the "Add Frame" button. To delete the current frame, press the "Delete Frame" button. The timeline panel is used to switch between frames.

Layer management. To create a new layer, press the "Add Layer" button. To delete the current layer, press the "Delete Layer" button. 

Onion skin function. To enable or disable the display of previous frames, use the "Show Previous Frames" toggle. To enable or disable the display of subsequent frames, use the "Show Next Frames" toggle. To set the number of displayed frames, use the "Frame Count" numeric field.

Drawing tools. To select a brush color, use the color palette. To change the brush size, use the "Brush Size" slider. 

Animation preview. To play the animation, press the "Play" button. To stop playback, press the "Stop" button. To adjust the playback speed, use the "Frame Rate" slider.
    """
    
    print("Starting English text-to-speech...")
    
    # Используем улучшенную версию
    success = speak_text(FIXED_TEXT)
    
    if success:
        print("Speech completed successfully!")
    else:
        print("Speech synthesis failed!")
