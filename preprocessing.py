import re


def preProcessing(file_path):
    try:
        # Leer el archivo de entrada
        with open(file_path, 'r', encoding='utf-8') as file:
            text = file.read()
        
        # Convertir el texto a minúsculas y eliminar caracteres no alfanuméricos
        text = text.lower()
        text = re.sub(r'[^a-zA-Z0-9\sñáéíóú]', '', text)

        # Reemplazar tildes y ñ
        text = text.replace('á', 'a').replace('é', 'e').replace('í', 'i').replace('ó', 'o').replace('ú', 'u').replace('ñ', 'n')

        # Dividir el texto en palabras
        words = text.split()

        # Crear el archivo txt de salida
        output_file_path = file_path.replace('.txt', '_assembly.txt')
        
        with open(output_file_path, 'wb') as output_file:
            # Crear una cadena con las palabras separadas por saltos de línea
            newline_words = '\n'.join(words)
            
            # Convertir la cadena a bytes y escribir en el archivo binario
            output_file.write(newline_words.encode('utf-8'))
        
        print(f"Preprocesamiento completado. Archivo guardado como: {output_file_path}")
    
    except FileNotFoundError:
        print("Archivo no encontrado. Por favor, verifica la ruta e intenta nuevamente.")
    except Exception as e:
        print(f"Ha ocurrido un error: {e}")
