import os
import subprocess
import preprocessing
import histogram
from PIL import Image

def run_main():
    # 1. Ejecutar el preprocesamiento (preprocessing.py)
    input_file = 'in_text.txt'  # Cambia esto por el archivo de entrada
    preprocessing.preProcessing(input_file)

    # 2. Ejecutar el ensamblador (./process_text)
    try:
        print("Ejecutando el ensamblador...")
        os.system('./process_text')
        print("Ensamblador ejecutado correctamente.")
    except subprocess.CalledProcessError as e:
        print(f"Error al ejecutar el ensamblador: {e}")
        return

    # 3. Ejecutar el postprocesado y generar el histograma (histogram.py)
    output_file = 'output.txt'  # Este es el archivo que genera el ensamblador
    histogram.process_histogram(output_file)

    # 4. Abrir la imagen generada del histograma
    try:
        img = Image.open('histograma.png')
        img.show()
    except FileNotFoundError:
        print("Imagen no encontrada. Asegúrate de que el histograma se haya generado correctamente.")

# Ejecutar el main
if __name__ == "__main__":
    run_main()
