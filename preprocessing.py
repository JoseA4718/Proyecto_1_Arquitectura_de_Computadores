import unicodedata
import re

def preprocess_text(input_file, output_file):
    # Lee el contenido del archivo de entrada
    with open(input_file, 'r', encoding='utf-8') as file:
        text = file.read()

    # Convertir a minúsculas
    text = text.lower()

    # Quitar caracteres especiales pero mantener ñ y Ñ
    text = re.sub(r'[^a-zñ0-9\s]', '', text)

    # Quitar tildes pero mantener ñ
    text = ''.join(
        c for c in unicodedata.normalize('NFKD', text)
        if not unicodedata.combining(c) or c in ['ñ']
    )

    # Dividir en palabras
    words = text.split()

    # Escribir el resultado en un archivo de texto
    with open(output_file, 'w', encoding='utf-8') as file:
        for word in words:
            file.write(f"{word}\n")  # Escribe cada palabra en una nueva línea

# Usar la función
input_file = 'in_text.txt'  # Cambia esto por el nombre de tu archivo de entrada
output_file = 'input.txt'  # El archivo de salida será "input.txt"

preprocess_text(input_file, output_file)
